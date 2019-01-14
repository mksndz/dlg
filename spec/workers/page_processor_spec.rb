require 'rails_helper'

describe PageProcessor, type: :model do
  describe '#perform' do
    let(:page_ingest) { Fabricate :page_ingest_with_json }
    it 'builds pages and saves results' do
      performed = PageProcessor.perform(page_ingest.id)
      page_ingest.reload
      expect(performed).to be_truthy
      expect(page_ingest.success?).to be_truthy
      expect(page_ingest.failed?).to be_falsey
    end

  end
end