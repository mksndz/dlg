require 'rails_helper'
include SunspotMatchers
include DcHelper

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

  it 'has an Array dcterms_title' do
    i = Fabricate(:item)
    expect(i.dcterms_title).to be_kind_of Array
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

  # validations

  it 'should require a Collection' do
    i = Fabricate.build(:item, collection: nil)
    i.valid?
    expect(i.errors).to have_key :collection
  end

  it 'should require a dcterms_temporal value' do
    i = Fabricate.build(:item, dcterms_temporal: nil)
    i.valid?
    expect(i.errors).to have_key :dcterms_temporal
  end

  it 'should require a dcterms_spatial value' do
    i = Fabricate.build(:item, dcterms_spatial: nil)
    i.valid?
    expect(i.errors).to have_key :dcterms_spatial
  end

  it 'should require a dc_right value' do
    i = Fabricate.build(:item, dc_right: nil)
    i.valid?
    expect(i.errors).to have_key :dc_right
  end

  it 'should require a dcterms_contributor value' do
    i = Fabricate.build(:item, dcterms_contributor: nil)
    i.valid?
    expect(i.errors).to have_key :dcterms_contributor
  end

  it 'should require one of the dcterms_type values to be in a standardized set' do
    i = Fabricate.build(:item, dcterms_type: ['Some Random Silly Type'])
    i.valid?
    expect(i.errors).to have_key :dcterms_type
  end

  it 'should require each of the dcterms_temporal values use a limited character set' do
    i = Fabricate.build(:item, dcterms_temporal: ['Text'])
    i.valid?
    expect(i.errors).to have_key :dcterms_temporal
  end

end
