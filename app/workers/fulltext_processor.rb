# frozen_string_literal: true

# job to ingest a ZIP file of fulltext records
class FulltextProcessor
  require 'zip'

  @queue = :fulltext_ingest_queue
  @slack = Slack::Notifier.new Rails.application.secrets.slack_worker_webhook

  def self.perform(fulltext_ingest)
    @fti = fulltext_ingest
    errors = 0
    init_results

    begin
      Zip::File.open(@fti.file) do |zip_file|
        @files = zip_file.count
        if @files.zero?
          @results[:status] = 'failed'
          @results[:message] = 'Empty ZIP file'
          @slack.ping "Fulltext ingest failed: #{@fti.title}" if Rails.env.production?
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
          item.fulltext = file.get_input_stream.read
          success = item.save(validate: false)
          if success
            success_file_results record_id, item.id
          else
            errors += 1
            failed_file_results record_id, item.errors.join(',')
          end
        end
      end
    rescue StandardError => e
      @results[:status] = 'failed'
      @results[:message] = e.message
      @slack.ping "Fulltext ingest failed: #{@fti.title}" if Rails.env.production?
      exit
    end
    Sunspot.commit
    if errors.zero?
      @results[:status] = 'success'
      @results[:message] = "#{@files} items updated."
    elsif errors > 0 && errors < @files
      @results[:status] = 'partial failure'
      @results[:message] = "#{errors} of #{@files} items failed to update."
    elsif errors == @files
      @results[:status] = 'failure'
      @results[:message] = 'All items failed to update.'
    end
    @fti.finished_at = Date.today
    @fti.results = @results
    @slack.ping "Fulltext ingest complete: #{@fti.title}" if Rails.env.production?
    @fti.save
  end

  def self.failed_file_results(file_name, message)
    @results[:files][file_name] = {
      status: 'failed',
      reason: message
    }
  end

  def self.success_file_results(file_name, item)
    @results[:files][file_name] = {
      status: 'success',
      item: item
    }
  end

  def self.init_results
    @results = { status: nil, message: nil, files: {} }
  end
end