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
      expect(fti.processed_files.length).to eq 3
      expect(fti.processed_files['r1_c1_i1']).to(
        eq('status' => 'success',
           'item' => Item.find_by_record_id('r1_c1_i1').id)
      )
      expect(fti.processed_files['r1_c1_i2']).to(
        eq('status' => 'success',
           'item' => Item.find_by_record_id('r1_c1_i2').id)
      )
      expect(fti.processed_files['invalid_record_id']).to(
        eq('status' => 'failed',
           'reason' => 'No Item exists matching record_id')
      )
    end
  end
end