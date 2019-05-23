require 'rails_helper'

RSpec.describe CollectionResource, type: :model do
  it 'has none to begin with' do
    expect(CollectionResource.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate(:collection_resource)
    expect(CollectionResource.count).to eq 1
  end
  it 'is ordered by position by default' do
    collection = Fabricate :empty_collection
    Fabricate.times(2, :collection_resource) do
      collection collection
      position { sequence(:position, 1) }
    end
    expect(CollectionResource.all.first.position).to eq 1
    expect(CollectionResource.all.last.position).to eq 2
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
  context 'when validating' do
    it 'requires a slug' do
      collection_resource = Fabricate.build :collection_resource, slug: nil
      collection_resource.valid?
      expect(collection_resource.errors).to have_key :slug
    end
    it 'requires a title' do
      collection_resource = Fabricate.build :collection_resource, title: nil
      collection_resource.valid?
      expect(collection_resource.errors).to have_key :title
    end
    it 'requires a content' do
      collection_resource = Fabricate.build :collection_resource, content: nil
      collection_resource.valid?
      expect(collection_resource.errors).to have_key :content
    end
    it 'requires a collection' do
      collection_resource = Fabricate.build :collection_resource, collection: nil
      collection_resource.valid?
      expect(collection_resource.errors).to have_key :collection_id
    end
  end

end
