require 'rails_helper'

describe Resaver, type: :model do
  describe '#perform' do
    context 'with an empty array' do
      it 'should fail gracefully' do
        collection = Fabricate :empty_collection
        expect {
          Resaver.perform(collection.items.map(&:id))
        }.not_to raise_exception
      end
    end
    context 'with a populated collection' do
      it 'should update record_ids of all items' do
        collection = Fabricate(:repository).collections.first
        Resaver.perform(collection.items.map(&:id))
        expect {
          Item.last.updated_at
        }.not_to raise_exception
      end
    end
  end
end