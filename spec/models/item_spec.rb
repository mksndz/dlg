require 'rails_helper'

RSpec.describe Item, type: :model do

  it 'has none to begin with' do
    expect(Item.count).to eq 0
  end

  it 'has one after adding one' do
    Fabricate(:item)
    expect(Item.count).to eq 1
  end

  # duh
  it 'belongs to a Repository' do
    r = Fabricate(:repository)
    expect(r.items.first.repository).to be_kind_of Repository
  end

  # duh
  it 'belongs to a Collection' do
    r = Fabricate(:repository)
    expect(r.items.first.collection).to be_kind_of Collection
  end

  it 'has a String title' do
    i = Fabricate(:item)
    expect(i.title).to be_kind_of String
  end

  it 'has an Array dc_title' do
    i = Fabricate(:item)
    expect(i.dc_title).to be_kind_of Array
  end

  it 'has a slug' do
    i = Fabricate(:item)
    expect(i.slug).not_to be_empty
  end

  after(:all) { Repository.destroy_all }
  after(:all) { Item.destroy_all }

end
