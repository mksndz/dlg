# job to ingest a JSON file of Page records
# FULLTEXT and FILE TYPE can be set at Item level in JSON
# FULLTEXT conflicts between Item and Page will result in errors
# FILE TYPE values set at Page level will be overridden if set at Item level
class PageProcessor
  # require 'fulltext_helper'

  @queue = :page_ingest_queue
  @slack = Slack::Notifier.new Rails.application.secrets.slack_worker_webhook

  def self.perform(page_ingest_id)
    @pi = PageIngest.find page_ingest_id
    init_results
    @pi.page_json.each do |item_data|
      record_id = item_data.delete('id')
      item = Item.find_by record_id: record_id
      unless item
        page_failed record_id, 'No Item for record_id'
        next
      end
      if item.fulltext.present? && includes_item_fulltext(item_data)
        page_failed(
          record_id,
          'Item already has full text added - remove it from the Item if you want to update via this process.'
        )
        next
      elsif includes_item_fulltext(item_data)
        item.fulltext = FulltextUtils.whitelisted item_data['fulltext']
      end
      item_file_type = item_data.key?('file_type') ? item_data['file_type'] : nil
      item_data['pages'].each do |page_data|
        begin
          raise StandardError, 'Item already has full text added - remove it if you want to add paginated full text' if item.fulltext? && includes_page_fulltext(page_data)

          existing_page = item.pages.find_by(number: page_data['number'])
          if existing_page
            # update
            existing_page.number = page_data['number'] if page_data.key? 'number'
            existing_page.file_type = page_data['file_type'] if page_data.key? 'file_type'
            existing_page.title = page_data['title'] if page_data.key? 'title'
            existing_page.fulltext = FulltextUtils.whitelisted(page_data['fulltext']) if page_data.key? 'fulltext'
            existing_page.save ? page_updated(item.id, existing_page) : page_failed(record_id, existing_page)
          else
            page = Page.create page_data.merge(item: item)
            page.file_type = item_file_type if item_file_type
            page.save ? page_added(item.id, page) : page_failed(record_id, page)
          end

        rescue StandardError => e
          page_failed record_id, "Problem creating Page for #{record_id}: #{e}"
          next
        end
      end
      Sunspot.index item
    end
    Sunspot.commit
    judge_job_outcome
    @pi.finished_at = Time.zone.today
    @pi.results_json = @results
    @slack.ping "Page ingest complete: `#{@pi.title}`" if Rails.env.production? || Rails.env.staging?
    @pi.save!
  rescue StandardError => e
    if @pi
      @slack.ping "Page ingest (#{@pi.title}) failed: #{e}" if Rails.env.production? || Rails.env.staging?
      @pi.results_json = @results
      @pi.save
    else
      if Rails.env.production? || Rails.env.staging?
        @slack.ping "Page ingest could not be found by PageProcessor: #{e}"
      end
    end
  end

  class << self
    private

    def init_results
      @results = { status: nil, message: nil, added: [], updated: [], errors: [] }
    end

    # @param [Hash] item_data
    def includes_item_fulltext(item_data)
      item_data.key?('fulltext') && item_data['fulltext'].present?
    end

    def includes_page_fulltext(page_data)
      page_data.key?('fulltext') && page_data['fulltext'].present?
    end

    def page_added(item_id, page)
      @results[:added] << {
        id: page.id,
        message: "Page #{page.number} successfully added.",
        item_id: item_id
      }
    end

    def page_updated(item_id, page)
      @results[:updated] << {
        id: page.id,
        message: "Page #{page.number} successfully updated.",
        item_id: item_id
      }
    end

    def page_failed(record_id, message)
      @results[:errors] << {
        item_id: record_id,
        message: "Page save failed: #{message}"
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