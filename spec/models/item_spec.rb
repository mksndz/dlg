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

  it 'belongs to a Repository' do
    i = Fabricate(:item) {
      repository
    }
    expect(i.repository).to be_kind_of Repository
  end

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

  it 'has an Array dlg_subject_personal' do
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

  it 'returns an array for coordinates' do

    i = Fabricate(:item) {
      dcterms_spatial { ['United States, Georgia, DeKalb County, Decatur, 33.7748275, -84.2963123',
                         'United States, Georgia, Fulton County, 33.7902836, -84.466986'
      ] }
    }
    expect(i.coordinates).to be_a Array
    expect(i.coordinates).to eq ['33.7748275, -84.2963123','33.7902836, -84.466986']

  end

  it 'returns an array containing parseable JSON strings geojson if coordinates are found present in the dcterms_spatial field' do
    i = Fabricate(:item) {
      dcterms_spatial { ['United States, Georgia, DeKalb County, Decatur, 33.7748275, -84.2963123',
                         'United States, Georgia, Fulton County, 33.7902836, -84.466986'
      ] }
    }
    i.geojson.each do |g|
      expect(JSON.parse(g)).to be_a Hash
    end
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

  it 'has validation status as a boolean true if item is valid' do
    i1 = Fabricate :item
    expect(i1.valid_item).to be true
  end

  it 'has validation status as a boolean false if item is invalid' do
    i1 = Fabricate :item
    i1.dc_date = []
    i1.save(validate: false)
    expect(i1.valid_item).to be false
  end

  it 'has a boolean method has_thumbnail' do
    i = Fabricate :item
    expect(i.has_thumbnail?).to be false
  end

  it 'has an array of Portals' do

    i = Fabricate :item
    p = Fabricate :portal

    i.portals << p

    expect(i.portals.first).to be_a Portal

  end

  it 'has an array of unique Portals' do

    i = Fabricate :item
    p = Fabricate :portal
    p2 = Fabricate :portal

    i.portals << p
    i.portals << p2
    i.portals << p

    expect(i.portals.first).to eq p
    expect(i.portals.last).to eq p2

  end

  it 'can be associated with multiple different Portals' do

    i = Fabricate :item
    p1 = Fabricate :portal
    p2 = Fabricate :portal

    i.portals << [ p1, p2 ]

    expect(i.portals.first).to be_a Portal
    expect(i.portals.last).to be_a Portal

    expect(i.portals.first).not_to be p2
    expect(i.portals.last).not_to be p1

  end

  # validations

  it 'should require a Collection' do
    i = Fabricate.build(:item, collection: nil)
    i.valid?
    expect(i.errors).to have_key :collection
  end

  it 'should require a dc_date value' do
    i = Fabricate.build(:item, dc_date: [])
    i.valid?
    expect(i.errors).to have_key :dc_date
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

  # it 'should require rights information of some sort be set' do
  #   i = Fabricate.build(:item, dc_right: [])
  #   i.valid?
  #   expect(i.errors).to have_key :entity
  # end

  # it 'should have a valid (resolvable) URL in dc_identifier' do
  #   i = Fabricate.build(:item, dc_identifier: ['http://dlg.galileo.usg.edu/items/do:4321'])
  #   i.valid?
  #   expect(i.errors).to have_key :dc_identifier
  # end
  #
  # it 'should validate if the item has a valid (resolvable) URL in dc_identifier' do
  #   i = Fabricate.build(:item, dc_identifier: ['http://dlg.galileo.usg.edu'])
  #   i.valid?
  #   expect(i.errors).not_to have_key :dc_identifier
  # end

  # it 'should have a valid (resolvable) URL in dcterms_is_shown_at' do
  #   i = Fabricate.build(:item, dcterms_is_shown_at: ['http://dlg.galileo.usg.edu/items/do:4321'])
  #   i.valid?
  #   expect(i.errors).to have_key :dcterms_is_shown_at
  # end
  #
  # it 'should validate if the item has a valid (resolvable) URL in dcterms_is_shown_at' do
  #   i = Fabricate.build(:item, dcterms_is_shown_at: ['http://dlg.galileo.usg.edu'])
  #   i.valid?
  #   expect(i.errors).not_to have_key :dcterms_is_shown_at
  # end

end
