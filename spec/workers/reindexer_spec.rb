require 'rails_helper'

describe Reindexer, type: :model do
  describe '#perform' do
    before(:each) { Fabricate :repository }
    context 'with a reindexable model' do
      it 'should not fail' do
        expect {
          Reindexer.perform('Collection')
        }.not_to raise_exception
      end
    end
    context 'with a reindexable object_ids' do
      it 'should not fail' do
        expect {
          Reindexer.perform('Item', Item.all.map(&:id))
        }.not_to raise_exception
      end
    end
  end
end