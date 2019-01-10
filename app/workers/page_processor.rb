# job to ingest a JSON file of Page records
class PageProcessor
  @queue = :page_ingest_queue
  @slack = Slack::Notifier.new Rails.application.secrets.slack_worker_webhook

  def self.perform(page_ingest_id)
    @pi = Page.find page_ingest_id
    unless @pi
      @results[:status] = 'failed'
      @results[:message] = "Page Ingest with ID = #{page_ingest_id} could not be found."
      @slack.ping "Page ingest (#{@pi.title}) failed: Page Ingest with ID = #{page_ingest_id} could not be found." if Rails.env.production?
      @pi.results = @results
      @pi.save
      exit
    end
    errors = 0
    init_results
    begin
      # get json
      # parse json
      # create page objects
      # profit
    rescue StandardError => e
      @results[:status] = 'failed'
      @results[:message] = e.message
      @slack.ping "Page ingest (#{@pi.title}) failed: #{e.message}" if Rails.env.production?
      @pi.results = @results
      @pi.save
      exit
    end
    Sunspot.commit
    if errors.zero?
      @results[:status] = 'success'
      @results[:message] = "#{@files} items updated."
    # elsif
    end
    @pi.finished_at = Time.zone.today
    @pi.results = @results
    @slack.ping "Page ingest complete: `#{@pi.title}`" if Rails.env.production?
    @pi.save
  end

  def self.init_results
    @results = { status: nil, message: nil, items: [] }
  end
end