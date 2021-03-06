# job to ingest a ZIP file of fulltext records
class FulltextProcessor
  # require 'fulltext_helper'
  require 'zip'

  @queue = :fulltext_ingest_queue
  @slack = Slack::Notifier.new Rails.application.secrets.slack_worker_webhook

  def self.perform(fulltext_ingest_id)
    @fti = FulltextIngest.find fulltext_ingest_id
    unless @fti
      @results[:status] = 'failed'
      @results[:message] = "Fulltext Ingest with ID = #{fulltext_ingest_id} could not be found."
      @slack.ping "Fulltext ingest (#{@fti.title}) failed: Fulltext Ingest with ID = #{fulltext_ingest_id} could not be found." if Rails.env.production? || Rails.env.staging?
      @fti.results = @results
      @fti.save
      exit
    end
    errors = 0
    init_results
    begin
      Zip::File.open(@fti.file.current_path) do |zip_file|
        @files = zip_file.count
        if @files.zero?
          @results[:status] = 'failed'
          @results[:message] = 'Empty ZIP file'
          @slack.ping "Fulltext ingest (#{@fti.title}) failed: Empty Zip file" if Rails.env.production? || Rails.env.staging?
          @fti.results = @results
          @fti.save
          exit
        end
        zip_file.each do |file|
          record_id = File.basename(file.name, '.*')
          unless File.extname(file.name) == '.txt'
            errors += 1
            failed_file_results(record_id, 'File must be a .txt file')
            next
          end
          item = Item.find_by_record_id record_id
          unless item
            errors += 1
            failed_file_results(record_id, 'No Item exists matching record_id')
            next
          end
          file_contents = contents_of(file)
          item.fulltext = FulltextUtils.whitelisted file_contents
          begin
            item.save!(validate: false)
            success_file_results item.id
          rescue StandardError => e
            errors += 1
            failed_file_results record_id, e.message
          end
        end
      end
    rescue StandardError => e
      @results[:status] = 'failed'
      @results[:message] = e.message
      @slack.ping "Fulltext ingest (#{@fti.title}) failed: #{e.message}" if Rails.env.production? || Rails.env.staging?
      @fti.results = @results
      @fti.save
      exit
    end
    Sunspot.commit
    if errors.zero?
      @results[:status] = 'success'
      @results[:message] = "#{@files} items updated."
    elsif errors.positive? && errors < @files
      @results[:status] = 'partial failure'
      @results[:message] = "#{errors} of #{@files} items failed to update."
    elsif errors == @files
      @results[:status] = 'failure'
      @results[:message] = 'All items failed to update.'
    end
    @fti.finished_at = Date.today
    @fti.results = @results
    @slack.ping "Fulltext ingest complete: `#{@fti.title}`" if Rails.env.production? || Rails.env.staging?
    @fti.save
  end

  # save text stripping any non utf-8 characters and other garbage
  def self.contents_of(file)
    file.get_input_stream.read.encode(
      Encoding.find('UTF-8'),
      invalid: :replace, undef: :replace, replace: ''
    )
  end

  def self.failed_file_results(file_name, message)
    @results[:files][:failed][file_name] = message.truncate(100)
  end

  def self.success_file_results(item_id)
    @results[:files][:succeeded] << item_id
  end

  def self.init_results
    @results = { status: nil, message: nil, files: { succeeded: [], failed: {} } }
  end
end
