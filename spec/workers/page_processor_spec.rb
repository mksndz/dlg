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
    it 'handles fulltext conflicts between existing Item fulltext and JSON
        item fulltext' do
      page_ingest = Fabricate :page_ingest_with_fulltext_conflict
      PageProcessor.perform(page_ingest.id)
      page_ingest.reload
      expect(page_ingest.success?).to be_falsey
      expect(page_ingest.failed?).to be_truthy
      expect(page_ingest.failed.length).to eq 1
      expect(page_ingest.failed.first['message']).to match /update/
    end
    it 'handles fulltext conflicts between item fulltext and page fulltext' do
      page_ingest = Fabricate :page_ingest_with_internal_fulltext_conflict
      PageProcessor.perform(page_ingest.id)
      page_ingest.reload
      expect(page_ingest.success?).to be_falsey
      expect(page_ingest.failed?).to be_truthy
      expect(page_ingest.failed.length).to eq 1
      expect(page_ingest.failed.first['message']).to match /paginated/
    end
    it 'handles item level file_type' do
      page_ingest = Fabricate :page_ingest_with_item_file_type
      PageProcessor.perform(page_ingest.id)
      page_ingest.reload
      expect(page_ingest.success?).to be_truthy
      expect(page_ingest.failed?).to be_falsey
      expect(Page.find(page_ingest.succeeded[0]['id']).file_type).to eq 'jp2'
      expect(Page.find(page_ingest.succeeded[1]['id']).file_type).to eq 'jp2'
      expect(Page.find(page_ingest.succeeded[2]['id']).file_type).to eq 'tiff'
    end
    context 'can update existing Pages' do
      before :each do
        @ingest = Fabricate :page_ingest_for_updating_existing_page
        @page = Page.last
      end
      it 'updates number, file_type and fulltext values' do
        PageProcessor.perform(@ingest.id)
        @page.reload
        expect(@page.file_type).to eq 'jp2'
        expect(@page.fulltext).to eq 'Updated fulltext'
      end
    end
  end
end