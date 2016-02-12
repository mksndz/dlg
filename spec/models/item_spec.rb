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

  it 'indexes the item in Solr' do
    i = Fabricate(:item)
    Sunspot.commit
    results = Item.search do
      fulltext i.title
    end.results
    expect(results).to include i
  end

  it 'deindexes the item in Solr on delete' do
    i = Fabricate(:item)
    i.destroy
    results = Item.search do
      fulltext i.title # todo is there a better way?
    end.results
    expect(results).to be_empty
  end

end
