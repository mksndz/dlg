require 'rails_helper'

describe Portable, type: :model do

  before :each do
    @collection = Fabricate(:collection, repository: Fabricate(:repository))
    @item = Fabricate(:item, collection: @collection)
    @repository = @collection.repository
    @portal1 = Fabricate :portal
    @portal2 = Fabricate :portal
    @item.portals = [@portal1]
    @collection.portals = [@portal1]
    @repository.portals = [@portal1]
  end

  it 'has portals assigned properly' do
    expect(@item.repository).to eq @repository
    expect(@collection.items).to eq [@item]
    expect(@item.portals).to eq [@portal1]
    expect(@collection.portals).to eq [@portal1]
    expect(@repository.portals).to eq [@portal1]
  end

  context 'for Items' do
    it 'adds a Portal and sets updated_at' do
      old_updated_at = @item.updated_at
      @item.portals << @portal2
      expect(@item.portals).to include @portal1, @portal2
      expect(@item.updated_at).not_to eq old_updated_at
    end
    it 'removes a Portal and sets updated_at' do
      old_updated_at = @item.updated_at
      @item.portals = []
      expect(@item.portals).not_to include @portal1, @portal2
      expect(@item.updated_at).not_to eq old_updated_at
    end
  end

  context 'for Collections' do
    it 'adds a Portal and sets updated_at' do
      old_updated_at = @collection.updated_at
      @collection.portals << @portal2
      expect(@collection.portals).to include @portal1, @portal2
      expect(@collection.updated_at).not_to eq old_updated_at
    end
    it 'removes a Portal and sets updated_at' do
      old_updated_at = @collection.updated_at
      @collection.portals = []
      expect(@collection.portals).not_to include @portal1, @portal2
      expect(@collection.updated_at).not_to eq old_updated_at
    end
    it 'removes portal from child item and touches' do
      old_updated_at = @item.updated_at
      @collection.portals = []
      @item.reload
      expect(@item.portals).not_to include @portal1, @portal2
      expect(@item.updated_at).not_to eq old_updated_at
    end
  end

  context 'for Repositories' do
    it 'adds a Portal and sets updated_at' do
      old_updated_at = @repository.updated_at
      @repository.portals << @portal2
      expect(@repository.portals).to include @portal1, @portal2
      expect(@repository.updated_at).not_to eq old_updated_at
    end
    it 'removes a Portal and sets updated_at' do
      old_updated_at = @repository.updated_at
      @repository.portals = []
      expect(@repository.portals).not_to include @portal1, @portal2
      expect(@repository.updated_at).not_to eq old_updated_at
    end
    it 'removes portal from child collection and item and touches' do
      item_old_updated_at = @item.updated_at
      collection_old_updated_at = @collection.updated_at
      @repository.portals = []
      @collection.reload
      @item.reload
      expect(@collection.portals).not_to include @portal1, @portal2
      expect(@item.portals).not_to include @portal1, @portal2
      expect(@collection.updated_at).not_to eq collection_old_updated_at
      expect(@item.updated_at).not_to eq item_old_updated_at
    end
  end
end