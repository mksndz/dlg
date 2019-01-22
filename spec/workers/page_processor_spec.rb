require 'rails_helper'

describe PageProcessor, type: :model do
  describe '#perform' do
    it 'builds pages and saves results' do
      page_ingest = Fabricate :page_ingest_with_json_and_success
      PageProcessor.perform(page_ingest.id)
      page_ingest.reload
      expect(page_ingest.success?).to be_truthy
      expect(page_ingest.failed?).to be_falsey
    end
    it 'handles non-JSON input' do
      page_ingest = Fabricate :page_ingest_with_bad_id
      PageProcessor.perform(page_ingest.id)
      page_ingest.reload
      expect(page_ingest.success?).to be_falsey
      expect(page_ingest.failed?).to be_falsey
      expect(page_ingest.partial_failure?).to be_truthy
    end
    it 'handles bad page data' do
      page_ingest = Fabricate :page_ingest_with_bad_page
      PageProcessor.perform(page_ingest.id)
      page_ingest.reload
      expect(page_ingest.success?).to be_falsey
      expect(page_ingest.failed?).to be_truthy
      expect(page_ingest.partial_failure?).to be_falsey
    end
  end
end