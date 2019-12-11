# service to generate export files in JSONL or XML and optionally upload them
class MassExporterService
  def initialize(format, fields = nil, batch_size = nil, notifier = nil, uploader = nil)
    @fields = fields || standard_fields
    @format = format
    @batch_size = batch_size || 10_000
    @notifier = notifier || NotificationService.new
    @uploader = uploader
    @file_path = File.join(Rails.application.root, 'public', 'exports')
  end

  # iterate through and build local copy of files
  def perform
    run_directory = prepare_run_directory
    solr_connection = Blacklight.default_index.connection
    last_cursor_mark = ''
    cursor_mark = '*'
    run = 1
    outcomes = []
    while last_cursor_mark != cursor_mark
      response = solr_query solr_connection, cursor_mark

      next_cursor_mark = response['nextCursorMark']
      last_cursor_mark = cursor_mark
      cursor_mark = next_cursor_mark
      break if last_cursor_mark == next_cursor_mark

      # build file name for this query response data
      set_file_name = File.join(
        run_directory,
        "set_#{run}.jsonl"
      )

      # create file
      file = File.open(set_file_name, 'w')

      # write JSON to file line
      response['response']['docs'].each do |doc|
        file.puts export_as(@format, doc)
      end

      if @uploader
        # @uploader.upload file
      end

      outcomes << {
        run: run,
        file: file.path
      }

      file.close
      run += 1
    end
    @notifier.notify "Export complete: `#{outcomes.length}` files uploaded to #{@file_path}."
  end

  private

  def doc_as(format, doc)
    case format
    when :jsonl
      doc.to_json
    when :xml
      doc.to_xml
    else
      raise(ArgumentError, 'Invalid export format')
    end
  end

  def solr_query(solr_connection, cursor_mark)
    solr_connection.post 'select', data: {
      rows: @batch_size,
      sort: 'id asc',
      fq: ['display_b:1', 'dpla_b: 1', 'class_name_ss: Item'],
      fl: @fields,
      cursorMark: cursor_mark
    }
  end

  def prepare_run_directory
    date = Time.zone.now.strftime('%m%d%Y')
    date_string = "export_of_#{date}"
    run_file_storage = File.join(@file_path, date_string)

    # create local directory if needed
    Dir.mkdir(run_file_storage) unless Dir.exist?(run_file_storage)
    run_file_storage
  end

  def standard_fields
    %w[id collection_titles_sms dcterms_provenance_display
         dcterms_title_display dcterms_creator_display dcterms_subject_display
         dcterms_description_display edm_is_shown_at_display
         edm_is_shown_by_display dc_date_display dcterms_spatial_display
         dc_format_display dc_right_display dcterms_type_display
         dcterms_language_display dlg_subject_personal_display
         dcterms_bibliographic_citation_display dcterms_identifier_display
         dc_relation_display dcterms_contributor_display
         dcterms_publisher_display dcterms_temporal_display
         dcterms_is_part_of_display dcterms_rights_holder_display
         dlg_local_right_display dcterms_medium_display dcterms_extent_display
         created_at_dts updated_at_dts]
  end
end
