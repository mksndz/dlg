require 'rails_helper'

RSpec.describe Collection, type: :model do

  it 'has none to begin with' do
    expect(Collection.count).to eq 0
  end
  
  it 'has one after adding one' do
    Fabricate(:collection)
    expect(Collection.count).to eq 1
  end

  # duh
  it 'belongs to a Repository' do
    r = Fabricate(:repository)
    expect(r.collections.first.repository).to be_kind_of Repository
  end
  
  it 'has a title' do
    c = Fabricate(:collection)
    expect(c.display_title).not_to be_empty
  end
  
  it 'has a slug' do
    c = Fabricate(:collection)
    expect(c.slug).not_to be_empty
  end
  
  it 'contains Items' do
    c = Fabricate(:collection)
    expect(c.items.first).to be_kind_of Item
  end

  it 'respond to Public Items' do
    expect(Fabricate(:collection)).to respond_to :dpla_items
  end

  it 'respond to DPLA Items' do
    expect(Fabricate(:collection)).to respond_to :public_items
  end
  
  after(:all) { Repository.destroy_all }
  after(:all) { Collection.destroy_all }
  
end
