require 'rails_helper'

describe FulltextProcessor, type: :model do
  describe '#perform' do
    let(:fti) { Fabricate :fulltext_ingest, file: 'spec/files/fulltext.zip' }
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
    it 'performs' do
      performed = FulltextProcessor.perform(fti)
      expect(performed).to be_truthy
      expect(fti.success?).to be_falsey
      expect(fti.partial_failure?).to be_truthy
      expect(fti.failed?).to be_falsey
    end
  end
end