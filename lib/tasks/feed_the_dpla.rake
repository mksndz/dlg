# frozen_string_literal: true

require 'rake'

## This job extracts DPLA=true records from solr, build JSON files and uploads
# them to the DPLA S3 bucket just for the DLG. AWS credentials and bucket name
# are in the secrets.yml file.
#
# Avoid using a number of rows higher than 5000 as it may lead to file sizes
# that will trigger an 'multipart' upload to S3, which will break the md5
# checksum validation in place for each upload (see DplaS3Service).

# Also, periodically remove the set_* files from /tmp

task(:feed_the_dpla, [:records_per_file] => [:environment]) do |_, args|

  # explicitly state fields to be included in Solr response, and therefore the
  # JSON for the DPLA
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

  notifier = NotificationService.new

  # build path for server file storage
  local_file_storage = File.join(Rails.application.root, 'tmp')

  # build date strings for file path and S3 folder
  date = Time.zone.now.strftime('%m%d%Y')
  date_string = "dpla_feed_#{date}"
  run_file_storage = File.join(local_file_storage, date_string)

  # create local directory if needed
  Dir.mkdir(run_file_storage) unless Dir.exist?(run_file_storage)

  # initialize s3 uploader
  s3 = DplaS3Service.new date

  # initialize Solr connection object
  solr = Blacklight.default_index.connection

  # set cursorMark variables for while loop below
  last_cursor_mark = ''
  cursor_mark = '*'
  run = 1
  outcomes = []

  # get rows from command params or use default
  rows = if defined?(args) && args[:records_per_file]
           args[:records_per_file]
         else
           '5000'
         end

  # query Solr until the end of the set is reached
  while last_cursor_mark != cursor_mark
    # do query
    # TODO: catch exception (cursorMark errors?)
    response = solr.post 'select', data: {
      rows: rows,
      sort: 'id asc',
      fq: ['display_b:1', 'dpla_b: 1', 'class_name_ss: Item'],
      fl: dpla_fields,
      cursorMark: cursor_mark
    }

    # cycle cursorMark variables
    next_cursor_mark = response['nextCursorMark']
    last_cursor_mark = cursor_mark
    cursor_mark = next_cursor_mark
    break if last_cursor_mark == next_cursor_mark

    # build file name for this query response data
    set_file_name = File.join(
      run_file_storage,
      "set_#{run}.jsonl"
    )

    # create file
    file = File.open(set_file_name, 'w')

    # write JSON to file line
    response['response']['docs'].each do |doc|
      file.puts doc.to_json
    end

    file.close

    # upload file to DPLA S3 bucket
    outcome = s3.upload file.path

    outcomes << {
      run: run,
      file: file.path,
      uploaded: outcome
    }

    run += 1
  end
  notifier.notify "DPLA feed complete: `#{outcomes.length}` files uploaded."
  outcomes.find { |o| !o[:uploaded] }.present?
end