require 'rails_helper'

describe FulltextProcessor, type: :model do
  describe '#perform' do
    let(:fti) { Fabricate :fulltext_ingest }
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
    it 'saves results and updates items' do
      performed = FulltextProcessor.perform(fti.id)
      fti.reload
      expect(performed).to be_truthy
      expect(fti.success?).to be_falsey
      expect(fti.partial_failure?).to be_truthy
      expect(fti.failed?).to be_falsey
      expect(fti.succeeded.length).to eq 2
      expect(fti.failed.length).to eq 1
      expect(fti.succeeded).to include(Item.find_by_record_id('r1_c1_i1').id, Item.find_by_record_id('r1_c1_i2').id)
      expect(fti.failed['invalid_record_id']).to(
        eq('No Item exists matching record_id')
      )
    end
    it 'retains whitespace characters' do
      FulltextProcessor.perform(fti.id)
      item = Item.find_by_record_id('r1_c1_i2')
      expect(item.fulltext).to include "\n"
    end
  end
  describe '#whitelisted' do
    it 'retains the characters we like, and rejects those we dont' do
      string = "\b\u0000[Redacted]-\n-$&£\"(Che:esE)xa/*.——%X-©"
      expect(FulltextUtils.whitelisted(string)).to(
        eq("  [Redacted]-\n-$&£\"(Che:esE)xa/*.——%X-©")
      )
    end
  end
end