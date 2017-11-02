require 'rails_helper'

describe Portable, type: :model do

  before :each do
    @repository = Fabricate :repository
    @portal = @repository.portals.last
  end

  it 'has portals assigned properly' do
    expect(@repository.portals).to eq [@portal]
    expect(@repository.collections.first.portals).to eq [@portal]
    expect(@repository.items.first.portals).to eq [@portal]
  end

  context 'for Items' do
    # it 'adds a Portal and sets updated_at' do
    #   old_updated_at = @item.updated_at
    #   @item.portals << @portal2
    #   expect(@item.portals).to include @portal1, @portal2
    #   expect(@item.updated_at).not_to eq old_updated_at
    # end
    # it 'removes a Portal and sets updated_at' do
    #   old_updated_at = @item.updated_at
    #   @item.portals = []
    #   expect(@item.portals).not_to include @portal1, @portal2
    #   expect(@item.updated_at).not_to eq old_updated_at
    # end
    # before :each do
    #   @portal = Fabricate :portal
    #   @item = Fabricate :item
    #   @portaled_collection = Fabricate :collection
    #   @unportaled_collection = Fabricate :collection
    #   @portaled_collection.portals = [@portal]
    #   @item.portals = [@portal]
    #   @item.collection = @portaled_collection
    # end
    # it 'is setup correctly' do
    #   expect(@item.collection).to eq @portaled_collection
    #   expect(@portaled_collection.portals).to eq [@portal]
    #   expect(@unportaled_collection.portals).not_to include @portal
    # end
    # it 'cannot add a portal that is not assigned to parent Collection' do
    #   @item.portals << Fabricate(:portal)
    #   expect do
    #     @item.save
    #   end.to raise_error ActiveRecord::Validations
    # end
    # it 'can add a portal that is assigned to parent Collection' do
    #   new_portal = Fabricate :portal
    #   @portaled_collection.portals <<
    # end
  end

  # context 'for Collections' do
  #   it 'adds a Portal and sets updated_at' do
  #     old_updated_at = @collection.updated_at
  #     @collection.portals << @portal2
  #     expect(@collection.portals).to include @portal1, @portal2
  #     expect(@collection.updated_at).not_to eq old_updated_at
  #   end
  #   it 'removes a Portal and sets updated_at' do
  #     old_updated_at = @collection.updated_at
  #     @collection.portals = []
  #     expect(@collection.portals).not_to include @portal1, @portal2
  #     expect(@collection.updated_at).not_to eq old_updated_at
  #   end
  #   it 'removes portal from child item and touches' do
  #     old_updated_at = @item.updated_at
  #     @collection.portals = []
  #     @item.reload
  #     expect(@item.portals).not_to include @portal1, @portal2
  #     expect(@item.updated_at).not_to eq old_updated_at
  #   end
  # end

  # context 'for Repositories' do
  #   before :each do
  #     @repository = Fabricate :repository
  #     @portal = @repository.portals.first
  #   end
  # end
end