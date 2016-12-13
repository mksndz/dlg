require 'rails_helper'

RSpec.describe Portal, type: :model do
  it 'has none to begin with' do
    expect(Portal.count).to eq 0
  end

  it 'has one after adding one' do
    Fabricate(:portal)
    expect(Portal.count).to eq 1
  end

  it 'has a name' do
    s = Fabricate(:portal)
    expect(s.name).not_to be_empty
    expect(s.name).to be_a String
  end

  it 'has a code' do
    s = Fabricate(:portal)
    expect(s.name).not_to be_empty
    expect(s.name).to be_a String
  end

  it 'can have Items' do
    s = Fabricate(:portal) {
      items(count: 1)
    }
    expect(s).to respond_to 'items'
    expect(s.items.first).to be_an Item
  end

  it 'can have Collections' do
    s = Fabricate(:portal) {
      collections(count: 1)
    }
    expect(s).to respond_to 'collections'
    expect(s.collections.first).to be_a Collection
  end

  it 'can have Repositories' do
    s = Fabricate(:portal) {
      repositories(count: 1)
    }
    expect(s).to respond_to 'repositories'
    expect(s.repositories.first).to be_a Repository
  end

end
