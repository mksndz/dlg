require 'rails_helper'

RSpec.describe BatchItem, type: :model do
  it 'has none to begin with' do
    expect(BatchItem.count).to eq 0
  end
  it 'has some after creating a batch' do
    Fabricate(:batch_item)
    expect(BatchItem.count).to be 1
  end
  it 'should require a Collection' do
    i = Fabricate.build(:batch_item)
    i.collection = nil
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
  context 'when created' do
    let(:batch_item) { Fabricate :batch_item }
    it 'has a Batch' do
      expect(batch_item.batch).to be_kind_of Batch
    end
    it 'has a String title' do
      expect(batch_item.title).to be_kind_of String
    end
    it 'has a slug' do
      expect(batch_item.slug).not_to be_empty
    end
    it 'has a string for full text' do
      expect(batch_item.fulltext).to be_kind_of String
    end
    it 'is not an Item' do
      expect(batch_item).not_to be_kind_of Item
    end
    context 'has a commit method' do
      it 'creates an Item copy of itself using commit' do
        i = batch_item.commit
        expect(i).to be_an Item
      end
      it 'replaces an existing Item with its attributes using commit' do
        i = Fabricate(:repository).items.first
        batch_item.item = i
        batch_item.collection = i.collection
        batch_item.portals = i.portals
        ni = batch_item.commit
        expect(ni).to be_an Item
        expect(ni.slug).to eq batch_item.slug
      end
      it 'raises a validation exception when the commit result is saved' do
        Fabricate :repository
        batch_item.collection = Collection.first
        ni = batch_item.commit
        expect { ni.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end
    context 'has previous and next methods' do
      let(:batch) { Fabricate(:batch) { batch_items(count: 3) } }
      it 'returns the next batch_item in a batch ordered by id' do
        n = batch.batch_items.first.next
        expect(n).to eq batch.batch_items[1]
      end
      it 'returns the previous batch_item in a batch ordered by id' do
        p = batch.batch_items.last.previous
        expect(p).to eq batch.batch_items[1]
      end
      it 'returns nil if there is no previous item' do
        p = batch.batch_items.first.previous
        expect(p).to eq nil
      end
      it 'returns nil if there is no next item' do
        n = batch.batch_items.last.next
        expect(n).to eq nil
      end
    end
  end
  context 'coordinate lookup on save' do
    it 'finds matching coordinates in existing Items' do
      Fabricate :item_with_parents
      bi = Fabricate.build(
        :batch_item,
        dcterms_spatial: ['United States, Georgia, Clarke County, Athens']
      )
      bi.save
      expect(bi.dcterms_spatial).to(
        eq ['United States, Georgia, Clarke County, Athens, 33.960948, -83.3779358']
      )
    end
    it 'finds matching coordinates using Geocoder' do
      Fabricate :item_with_parents
      bi = Fabricate.build(
        :batch_item,
        dcterms_spatial: ['France, Paris']
      )
      bi.save
      expect(bi.dcterms_spatial).to(
        eq ['France, Paris, 12.3456789, -98.7654321']
      )
    end
    it 'saves original value if no match found in existing Items or via Geocoder' do
      Geocoder::Lookup::Test.add_stub('The Moon', [])
      bi = Fabricate.build(
        :batch_item,
        dcterms_spatial: ['The Moon']
      )
      bi.save
      expect(bi.dcterms_spatial).to(
        eq ['The Moon']
      )
    end
    it 'finds matching coordinates in existing Items and picks the right one' do
      Fabricate :item_with_parents
      item = Fabricate(:repository).items.first
      item.dcterms_spatial = [
        'United States, Georgia, Clarke County, Athens, Winterville, 33.960999, -83.3779399'
      ]
      bi = Fabricate.build(
        :batch_item,
        dcterms_spatial: ['United States, Georgia, Clarke County, Athens']
      )
      bi.save
      bi2 = Fabricate.build(
        :batch_item,
        dcterms_spatial: ['United States, Georgia, Clarke County, Athens, Winterville, 33.960999, -83.3779399'])
      bi2.save
      expect(bi.dcterms_spatial).to eq ['United States, Georgia, Clarke County, Athens, 33.960948, -83.3779358']
      expect(bi2.dcterms_spatial).to eq ['United States, Georgia, Clarke County, Athens, Winterville, 33.960999, -83.3779399']
    end
    it 'finds matching coordinates in existing Items and does not pick too
        many' do
      Fabricate :item_with_parents
      item = Fabricate(:repository).items.first
      item.dcterms_spatial = ['United States, Massachusetts, Shirley']
      item2 = Fabricate(:repository).items.first
      item2.dcterms_spatial = ['United States, North Carolina, Camden']
      bi = Fabricate.build(:batch_item, dcterms_spatial: ['United States'])
      bi.save
      expect(bi.dcterms_spatial).to eq ['United States, 12.3456789, -98.7654321']
    end
  end
end
