require 'rails_helper'

RSpec.describe BatchItem, type: :model do

  it 'has none to begin with' do
    expect(BatchItem.count).to eq 0
  end

  it 'has some after creating a batch' do
    Fabricate(:batch) { batch_items(count: 1) }
    expect(BatchItem.count).to be 1
  end
  it 'has a Batch' do
    b = Fabricate(:batch) { batch_items(count: 1) }
    expect(b.batch_items.first.batch).to be_kind_of Batch
  end

  it 'has a String title' do
    b = Fabricate(:batch) { batch_items(count: 1) }
    expect(b.batch_items.first.title).to be_kind_of String
  end

  it 'has a slug' do
    b = Fabricate(:batch) { batch_items(count: 1) }
    expect(b.batch_items.first.slug).not_to be_empty
  end

  it 'is not an Item' do
    b = Fabricate(:batch) { batch_items(count: 1) }
    expect(b.batch_items.first).not_to be_kind_of Item
  end

  it 'creates an Item copy of itself using commit' do
    b = Fabricate(:batch) { batch_items(count: 1) }
    i = b.batch_items.first.commit
    expect(i).to be_an Item
  end

  it 'replaces an existing Item with its attributes using commit' do
    i = Fabricate(:item)
    b = Fabricate(:batch) { batch_items(count: 1) }
    bi = b.batch_items.first
    bi.item = i
    bi.save
    ni = bi.commit
    expect(ni).to be_an Item
    expect(ni.slug).to eq bi.slug
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

end
