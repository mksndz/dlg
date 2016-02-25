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
    r = Fabricate(:repository) {
      collections(count: 1)
    }
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
    c = Fabricate(:collection) {
      items(count: 1)
    }
    expect(c.items.first).to be_kind_of Item
  end

  it 'respond to Public Items' do
    expect(Fabricate(:collection)).to respond_to :dpla_items
  end

  it 'respond to DPLA Items' do
    expect(Fabricate(:collection)).to respond_to :public_items
  end

  it 'indexes the item in Solr' do
    c = Fabricate(:collection)
    Sunspot.commit
    results = Collection.search do
      fulltext c.title
    end.results
    expect(results).to include c
  end

  it 'deindexes the item in Solr on delete' do
    c = Fabricate(:collection)
    c.destroy
    results = Collection.search do
      fulltext c.title # todo is there a better way?
    end.results
    expect(results).to be_empty
  end

end
