require 'rails_helper'

describe PageProcessor, type: :model do
  describe '#perform' do
    it 'builds pages and saves results' do
      page_ingest = Fabricate :page_ingest_with_json_and_results
      performed = PageProcessor.perform(page_ingest.id)
      page_ingest.reload
      expect(performed).to be_truthy
      expect(page_ingest.success?).to be_truthy
      expect(page_ingest.failed?).to be_falsey
    end
    it 'handles non-JSON input' do
      page_ingest = Fabricate :page_ingest_with_bad_json

    end
  end
end