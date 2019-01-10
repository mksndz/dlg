require 'rails_helper'

describe PageProcessor, type: :model do
  describe '#perform' do
    let(:page_ingest) { Fabricate :page_ingest_with_json }
    before(:each) do
      r = Fabricate :empty_repository, slug: 'r1'
      c = Fabricate(
        :empty_collection,
        slug: 'c1', repository: r, portals: r.portals
      )
      Fabricate(:item, slug: 'i1') do
        collection c
        portals c.portals
      end
      Fabricate(:item, slug: 'i2') do
        collection c
        portals c.portals
      end
    end
    it 'builds pages and saves results' do
      performed = PageProcessor.perform(page_ingest.id)
      page_ingest.reload
      expect(performed).to be_truthy
    end
  end
end