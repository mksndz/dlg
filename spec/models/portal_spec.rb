require 'rails_helper'

RSpec.describe Portal, type: :model do
  it 'has none to begin with' do
    expect(Portal.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate(:portal)
    expect(Portal.count).to eq 1
  end
  context 'when created' do
    before :each do
      @portal = Fabricate(:repository).portals.first
    end
    it 'has a name' do
      expect(@portal.name).not_to be_empty
      expect(@portal.name).to be_a String
    end
    it 'has a code' do
      expect(@portal.name).not_to be_empty
      expect(@portal.name).to be_a String
    end
    it 'has Items' do
      expect(@portal).to respond_to 'items'
      expect(@portal.items.first).to be_an Item
    end
    it 'has Collections' do
      expect(@portal).to respond_to 'collections'
      expect(@portal.collections.first).to be_a Collection
    end
    it 'has repositories' do
      expect(@portal).to respond_to 'repositories'
      expect(@portal.repositories.first).to be_a Repository
    end
  end
end
