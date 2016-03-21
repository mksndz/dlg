require 'rails_helper'

RSpec.describe Admin::Repository, type: :model do

  it 'has none to begin with' do
    expect(Admin::Repository.count).to eq 0
  end

  it 'has one after adding one' do
    Fabricate(:repository)
    expect(Admin::Repository.count).to eq 1
  end

  it 'contains a Collection' do
    r = Fabricate(:repository) {
      collections(count: 1)
    }
    expect(r.collections.count).to be > 0
    expect(r.collections.first).to be_kind_of Admin::Collection
  end

  it 'has a title' do
    r = Fabricate(:repository)
    expect(r.title).not_to be_empty
  end

  it 'has a slug' do
    r = Fabricate(:repository)
    expect(r.slug).not_to be_empty
  end

  it 'contains Items through Collection' do
    r = Fabricate(:repository) {
      collections { Fabricate.times(1, :collection) {
        items(count: 1)
      }}
    }
    expect(r.items.first).to be_kind_of Admin::Item
  end

end
