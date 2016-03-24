require 'rails_helper'
include SunspotMatchers

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
    i = Fabricate(:item) {
      repository
    }
    expect(i.repository).to be_kind_of Repository
  end

  # duh
  it 'belongs to a Collection' do
    i = Fabricate(:item) {
      collection
    }
    expect(i.collection).to be_kind_of Collection
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

  it 'disallows creating two items with the same slug related to the same collection' do
    c = Fabricate(:collection)
    i1 = Fabricate(:item) {
      collection c
      slug 'same'
    }
    i2 = Fabricate.build(:item) {
      collection c
      slug 'same'
    }
    expect { i2.save! }.to raise_exception(ActiveRecord::RecordInvalid)
    expect(i2.errors).to include(:slug)
  end

  it 'allows creating two items with the same slug related to different collection' do
    c1 = Fabricate(:collection)
    c2 = Fabricate(:collection)
    i1 = Fabricate(:item) {
      collection c1
      slug 'same'
    }
    i2 = Fabricate.build(:item) {
      collection c2
      slug 'same'
    }
    expect { i2.save! }.not_to raise_exception
  end

  describe 'Item searchable fields' do
    it { expect(Item).to have_searchable_field :slug }
    it { expect(Item).to have_searchable_field :sunspot_id }
    it { expect(Item).to have_searchable_field :collection_id }
    it { expect(Item).to have_searchable_field :repository_id }
    it { expect(Item).to have_searchable_field :collection_title }
    it { expect(Item).to have_searchable_field :dpla }
    it { expect(Item).to have_searchable_field :dc_title }
    it { expect(Item).to have_searchable_field :dc_format }
    it { expect(Item).to have_searchable_field :dc_publisher }
    it { expect(Item).to have_searchable_field :dc_identifier }
    it { expect(Item).to have_searchable_field :dc_right }
    it { expect(Item).to have_searchable_field :dc_contributor }
    it { expect(Item).to have_searchable_field :dc_coverage_temporal }
    it { expect(Item).to have_searchable_field :dc_coverage_spatial }
    it { expect(Item).to have_searchable_field :dc_date }
    it { expect(Item).to have_searchable_field :dc_source }
    it { expect(Item).to have_searchable_field :dc_subject }
    it { expect(Item).to have_searchable_field :dc_type }
    it { expect(Item).to have_searchable_field :dc_description }
    it { expect(Item).to have_searchable_field :dc_creator }
    it { expect(Item).to have_searchable_field :dc_language }
    it { expect(Item).to have_searchable_field :dc_relation }
    it { expect(Item).to have_searchable_field :format }
  end

end
