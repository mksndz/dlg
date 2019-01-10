# job to ingest a JSON file of Page records
class PageProcessor
  @queue = :page_ingest_queue
  @slack = Slack::Notifier.new Rails.application.secrets.slack_worker_webhook

  def self.perform(page_ingest_id)
    @pi = PageIngest.find page_ingest_id
    unless @pi
      @results[:status] = 'failed'
      @results[:message] = "Page Ingest with ID = #{page_ingest_id} could not be found."
      @slack.ping "Page ingest (#{@pi.title}) failed: Page Ingest with ID = #{page_ingest_id} could not be found." if Rails.env.production?
      @pi.results = @results
      @pi.save
      exit
    end
    init_results
    begin
      @pi.page_json.each do |protopage|
        record_id = protopage.delete('id')
        item = Item.find_by record_id: record_id
        unless item
          @results.added << { "#{record_id}": 'Could not find an Item using this record ID.' }
        end
        page = Page.create protopage.merge(item: item)
        if page.save
          @results.added << { "#{item.record_id}": "Page #{page.number} successfully added." }
        else
          @results.added << { "#{item.record_id}": "Page #{page.number} save failed: #{page.errors}" }
        end
      end
    rescue StandardError => e
      # write error message to results
      @results[:status] = 'failed'
      @results[:message] = e.message
      @slack.ping "Page ingest (#{@pi.title}) failed: #{e.message}" if Rails.env.production?
      @pi.results = @results
      @pi.save
      exit
    end
    Sunspot.commit
    if @results.errors.zero?
      @results[:status] = 'success'
      @results[:message] = 'All Pages created successfully'
    elsif @results.errors.any? && @results.added.any?
      @results[:status] = 'partial failure'
      @results[:message] = 'Some Pages failed to be created'
    elsif @results.errors.any? && @results.added.zero?
      @results[:status] = 'failed'
      @results[:message] = 'All Pages failed ot be created'
    end
    @pi.finished_at = Time.zone.today
    @pi.results = @results
    @slack.ping "Page ingest complete: `#{@pi.title}`" if Rails.env.production?
    @pi.save
  end

  def self.init_results
    @results = { status: nil, message: nil, added: [], errors: [] }
  end
end