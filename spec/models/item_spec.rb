require 'rails_helper'
include MetadataHelper

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

  it 'has a record_id' do
    i = Fabricate(:item)
    expect(i.record_id).not_to be_empty
  end

  it 'has a thumbnail_url that is a url' do
    i = Fabricate(:item)
    expect { URI.parse(i.thumbnail_url) }.not_to raise_exception
  end

  it 'has a facet_years value that is an Array of years taken from dc_date' do
    i = Fabricate(:item) {
      dc_date { %w(text 991 1802 2001 1776-1791 1900/1901) }
    }
    expect(i.facet_years).to eq %w(1802 2001 1776 1791 1900 1901)
  end

  it 'returns string coordinates if one is found present in the dcterms_spatial field' do
    i = Fabricate(:item) {
      dcterms_spatial { ['United States, Georgia, DeKalb County, Decatur, 33.7748275, -84.2963123'] }
    }
    expect(i.coordinates).to eq '33.7748275, -84.2963123'
  end

  it 'returns string coordinates in alternate form if one is found present in the dcterms_spatial field' do
    i = Fabricate(:item) {
      dcterms_spatial { ['United States, Georgia, DeKalb County, Decatur, 33.7748275, -84.2963123'] }
    }
    expect(i.coordinates(true)).to eq '-84.2963123, 33.7748275'
  end

  it 'returns string placename with coordinates stripped if one is found present in the dcterms_spatial field' do
    i = Fabricate(:item) {
      dcterms_spatial { ['United States, Georgia, DeKalb County, Decatur, 33.7748275, -84.2963123'] }
    }
    expect(i.placename).to eq 'United States, Georgia, DeKalb County, Decatur'
  end

  it 'returns parseable JSON string geojson if coordinates are found present in the dcterms_spatial field' do
    i = Fabricate(:item) {
      dcterms_spatial { ['United States, Georgia, DeKalb County, Decatur, 33.7748275, -84.2963123'] }
    }
    expect(i.geojson).to eq '{"type":"Feature","geometry":{"type":"Point","coordinates":[-84.2963123, 33.7748275]},"properties":{"placename":"United States, Georgia, DeKalb County, Decatur"}}'
    expect(JSON.parse(i.geojson)).to be_a Hash
  end

  it 'returns parseable JSON string geojson if no coordinates are found present in the dcterms_spatial field with default data' do
    i = Fabricate(:item) {
      dcterms_spatial { ['United States, Georgia, Tree That Owns Itself'] }
    }
    expect(i.geojson).to eq '{"type":"Feature","geometry":{"type":"Point","coordinates":[-80.394617, 31.066399]},"properties":{"placename":"United States, Georgia, Tree That Owns Itself"}}'
    expect(JSON.parse(i.geojson)).to be_a Hash
  end

  it 'returns parseable JSON string geojson with default data if no dcterms_spatial field is present' do
    i = Fabricate(:item) {
      dcterms_spatial { ['United States, Georgia, Tree That Owns Itself'] }
    }
    expect(i.geojson).to eq '{"type":"Feature","geometry":{"type":"Point","coordinates":[-80.394617, 31.066399]},"properties":{"placename":"United States, Georgia, Tree That Owns Itself"}}'
    expect(JSON.parse(i.geojson)).to be_a Hash
  end

  it 'has an array of collection titles including the titles of other_collections, if set' do
    c1 = Fabricate(:collection)
    c2 = Fabricate(:collection)
    c3 = Fabricate(:collection)
    i = Fabricate(:item) {
      collection c1
      other_collections { [c2.id, c3.id] }
    }
    expect(i.collection_titles).to include c1.title
    expect(i.collection_titles).to include c2.title
    expect(i.collection_titles).to include c3.title
  end

  it 'has an array of repository titles including the repository titles associated with other_collections, if set' do
    c1 = Fabricate(:collection)
    c2 = Fabricate(:collection)
    c3 = Fabricate(:collection)
    i = Fabricate(:item) {
      collection c1
      other_collections { [c2.id, c3.id] }
    }
    expect(i.repository_titles).to include c1.repository.title
    expect(i.repository_titles).to include c2.repository.title
    expect(i.repository_titles).to include c3.repository.title
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

  it 'caches validation status as a boolean' do
    i1 = Fabricate :item
    expect(i1.valid_item).to be true
  end

  # validations

  it 'should require a Collection' do
    i = Fabricate.build(:item, collection: nil)
    i.valid?
    expect(i.errors).to have_key :collection
  end

  it 'should require a dcterms_temporal value' do
    i = Fabricate.build(:item, dcterms_temporal: [])
    i.valid?
    expect(i.errors).to have_key :dcterms_temporal
  end

  it 'should require a dcterms_spatial value' do
    i = Fabricate.build(:item, dcterms_spatial: [])
    i.valid?
    expect(i.errors).to have_key :dcterms_spatial
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

  it 'should require rights information of some sort be set' do
    i = Fabricate.build(:item, dc_right: [])
    i.valid?
    expect(i.errors).to have_key :entity
  end

end
