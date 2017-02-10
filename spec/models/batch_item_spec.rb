require 'rails_helper'

RSpec.describe BatchItem, type: :model do

  let(:bi) {
    Fabricate(:batch_item)
  }

  it 'has none to begin with' do
    expect(BatchItem.count).to eq 0
  end

  it 'has some after creating a batch' do
    Fabricate(:batch_item)
    expect(BatchItem.count).to be 1
  end

  it 'has a Batch' do
    expect(bi.batch).to be_kind_of Batch
  end

  it 'has a String title' do
    expect(bi.title).to be_kind_of String
  end

  it 'has a slug' do
    expect(bi.slug).not_to be_empty
  end

  it 'is not an Item' do
    expect(bi).not_to be_kind_of Item
  end

  it 'creates an Item copy of itself using commit' do
    b = Fabricate(:batch) { batch_items(count: 1) }
    i = b.batch_items.first.commit
    expect(i).to be_an Item
  end

  it 'replaces an existing Item with its attributes using commit' do
    i = Fabricate(:item)
    bi = Fabricate(:batch_item)
    bi.item = i
    bi.save
    ni = bi.commit
    expect(ni).to be_an Item
    expect(ni.slug).to eq bi.slug
  end

  it 'responds to next with the next batch_item in a batch ordered by id' do
    b = Fabricate(:batch) { batch_items(count: 3) }
    n = b.batch_items.first.next
    expect(n).to eq b.batch_items[1]
  end

  it 'responds to previous with the previous batch_item in a batch ordered by id' do
    b = Fabricate(:batch) { batch_items(count: 3) }
    p = b.batch_items.last.previous
    expect(p).to eq b.batch_items[1]
  end

  it 'responds to previous with nil if there is no previous item' do
    b = Fabricate(:batch) { batch_items(count: 2) }
    p = b.batch_items.first.previous
    expect(p).to eq nil
  end

  it 'responds to next with nil if there is no next item' do
    b = Fabricate(:batch) { batch_items(count: 2) }
    n = b.batch_items.last.next
    expect(n).to eq nil
  end

  # validations

  it 'should require a Collection' do
    i = Fabricate.build(:batch_item, collection: nil)
    i.valid?
    expect(i.errors).to have_key :collection
  end

  it 'should require a dc_date value' do
    i = Fabricate.build(:batch_item, dc_date: [])
    i.valid?
    expect(i.errors).to have_key :dc_date
  end

  it 'should require a dcterms_spatial value' do
    i = Fabricate.build(:batch_item, dcterms_spatial: [])
    i.valid?
    expect(i.errors).to have_key :dcterms_spatial
  end

  it 'should require one of the dcterms_type values to be in a standardized set' do
    i = Fabricate.build(:batch_item, dcterms_type: ['Some Random Silly Type'])
    i.valid?
    expect(i.errors).to have_key :dcterms_type
  end

  it 'should require each of the dcterms_temporal values use a limited character set' do
    i = Fabricate.build(:batch_item, dcterms_temporal: ['Text'])
    i.valid?
    expect(i.errors).to have_key :dcterms_temporal
  end

  context 'coordinate lookup on commit' do

    it 'finds matching coordinates in existing Items' do

      Fabricate :item
      bi = Fabricate.build(:batch_item, dcterms_spatial: ['United States, Georgia, Clarke County, Athens'])
      bi.save
      expect(bi.dcterms_spatial).to eq ['United States, Georgia, Clarke County, Athens, 33.960948, -83.3779358']

    end

    it 'saves original value if no match found in existing Items' do

      bi = Fabricate.build(:batch_item, dcterms_spatial: ['United States, Georgia, Clarke County, Athens'])
      bi.save
      expect(bi.dcterms_spatial).to eq ['United States, Georgia, Clarke County, Athens']

    end

    it 'finds matching coordinates in existing Items and picks the right one' do

      Fabricate :item
      Fabricate(:item) do
        dcterms_spatial [['United States, Georgia, Clarke County, Athens, Winterville, 33.960999, -83.3779399']]
      end
      bi = Fabricate.build(:batch_item, dcterms_spatial: ['United States, Georgia, Clarke County, Athens'])
      bi.save
      bi2 = Fabricate.build(:batch_item, dcterms_spatial: ['United States, Georgia, Clarke County, Athens, Winterville, 33.960999, -83.3779399'])
      bi2.save
      expect(bi.dcterms_spatial).to eq ['United States, Georgia, Clarke County, Athens, 33.960948, -83.3779358']
      expect(bi2.dcterms_spatial).to eq ['United States, Georgia, Clarke County, Athens, Winterville, 33.960999, -83.3779399']

    end

  end

end
