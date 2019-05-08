require 'rails_helper'

RSpec.describe CollectionResource, type: :model do
  it 'has none to begin with' do
    expect(CollectionResource.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate(:collection_resource)
    expect(CollectionResource.count).to eq 1
  end
  context 'when a basic collection_resource is created' do
    subject(:collection_resource) { Fabricate :collection_resource }
    it 'has a slug' do
      expect(collection_resource.slug).to be_a String
    end
    it 'has a title' do
      expect(collection_resource.title).to be_a String
    end
    it 'has a position' do
      expect(collection_resource.position).to be_a Integer
    end
    it 'has content' do
      expect(collection_resource.content).to be_a String
    end
    it 'has an associated Collection' do
      expect(collection_resource.collection).to be_a Collection
    end
    it 'has timestamps' do
      collection_resource.touch
      expect(collection_resource.created_at).not_to be_nil
      expect(collection_resource.updated_at).not_to be_nil
    end
  end

end
