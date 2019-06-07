# frozen_string_literal: true

require 'rake'

task(:feed_the_dpla, [:records_per_file] => [:environment]) do |t, args|

  def dpla_fields
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

  logger = Logger.new('./log/dpla_feed.log')

  start_time = Time.now

  local_file_storage = File.join(
    Rails.application.root,
    'public'
  )

  date_string = Time.now.strftime('%Y%m%d')

  run_file_storage = File.join(
    local_file_storage,
    date_string
  )

  Dir.mkdir(run_file_storage) unless Dir.exist?(run_file_storage)

  solr = Blacklight.default_index.connection

  last_cursor_mark = '*'
  cursor_mark = ''
  run = 1

  rows = if defined?(args) && args[:records_per_file]
           args[:records_per_file]
         else
           '10000'
         end

  while last_cursor_mark != cursor_mark do
    response = solr.post 'select', data: {
      rows: rows,
      fq: ['display_b:1', 'dpla_b: 1', 'class_name_ss: Item'],
      fl: dpla_fields,
      cursorMark: cursor_mark
    }

    last_cursor_mark = cursor_mark
    cursor_mark = response['nextCursorMark'] if response['nextCursorMark']

    set_file_name = File.join(
      run_file_storage,
      "set_#{run}.jsonl"
    )
    f = File.open(set_file_name, 'w')

    response['response']['docs'].each do |doc|
      f.puts doc.to_json
    end
    f.close
    run += 1
  end

  # Upload files

  finish_time = Time.now

  logger.info 'complete!'
  logger.info "Processing took #{finish_time - start_time} seconds!"

end