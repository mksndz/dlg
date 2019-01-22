# job to ingest a JSON file of Page records
class PageProcessor
  @queue = :page_ingest_queue
  @slack = Slack::Notifier.new Rails.application.secrets.slack_worker_webhook

  def self.perform(page_ingest_id)
    @pi = PageIngest.find page_ingest_id
    init_results
    @pi.page_json.each do |item_pages|
      record_id = item_pages.delete('id')
      item = Item.find_by record_id: record_id
      unless item
        add_error record_id, 'No Item for record_id'
        next
      end
      item.fulltext = item_pages['fulltext'] if item_pages.key?('fulltext')
      item_pages['pages'].each do |protopage|
        begin
          if item.fulltext? && protopage.key?('fulltext') &&
             !protopage['fulltext'].empty?
            raise StandardError(
              'Item already has full text added - remove it if you want to add paginated full text'
            )
          end
          page = Page.create protopage.merge(item: item)
          page.save ? page_added(page) : page_failed(page)
        rescue StandardError => e
          add_error record_id, "Bad Page data for #{record_id}: #{e}"
          next
        end
      end
    end
    Sunspot.commit
    judge_job_outcome
    @pi.finished_at = Time.zone.today
    @pi.results_json = @results
    @slack.ping "Page ingest complete: `#{@pi.title}`" if Rails.env.production?
    @pi.save!
  rescue StandardError => e
    if @pi
      @slack.ping "Page ingest (#{@pi.title}) failed: #{e}" if Rails.env.production?
      @pi.results_json = @results
      @pi.save
    else
      if Rails.env.production?
        @slack.ping "Page ingest could not be found by PageProcessor: #{e}"
      end
    end
  end

  def self.init_results
    @results = { status: nil, message: nil, added: [], errors: [] }
  end

  class << self
    private

    def page_added(page)
      @results[:added] << {
        page.id => "Page #{page.number} successfully added."
      }
    end

    def page_failed(page)
      @results[:errors] << {
        page.id => "Page #{page.number} save failed: #{page.errors}"
      }
    end

    def job_success(message)
      @results[:status] = 'success'
      @results[:message] = message
    end

    def job_partial(message)
      @results[:status] = 'partial failure'
      @results[:message] = message
    end

    def job_failed(message)
      @results[:status] = 'failed'
      @results[:message] = message
    end

    def add_error(record_id, message)
      @results[:errors] << { record_id => message }
    end

    def judge_job_outcome
      if @results[:errors].empty?
        job_success 'All Pages created successfully'
      elsif @results[:errors].any? && @results[:added].any?
        job_partial 'Some Pages failed to be created'
      elsif @results[:errors].any? && @results[:added].empty?
        job_failed 'All Pages failed to be created'
      else
        job_failed 'Transcendent error state achieved'
      end
    end
  end

end