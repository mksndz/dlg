require 'rails_helper'

RSpec.describe Collection, type: :model do
  it 'has none to begin with' do
    expect(Collection.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate :empty_collection
    expect(Collection.count).to eq 1
  end
  it 'requires a Repository' do
    c = Fabricate.build(:collection)
    c.valid?
    expect(c.errors).to have_key :repository
  end
  it 'requires a display_title' do
    c = Fabricate.build(:collection, display_title: '')
    c.valid?
    expect(c.errors).to have_key :display_title
  end
  it 'requires a unique slug in the repository scope' do
    r = Fabricate :repository
    c = Fabricate.build(
      :collection,
      repository: r,
      slug: r.collections.first.slug
    )
    c.valid?
    expect(c.errors).to have_key :slug
  end
  context 'validations' do
    let(:collection) { Fabricate.build :empty_collection }
    it 'can be saved with >1 dc_right value' do
      collection.dc_right << 'http://rightsstatements.org/vocab/NKC/1.0/'
      collection.valid?
      expect(collection.errors).to be_empty
      expect(collection.dc_right.size).to eq 2
    end
    it 'is invalid if one dc_right value is not acceptable' do
      collection.dc_right << 'http://rightsstatements.org/vocab/NKC/8.0/'
      collection.valid?
      expect(collection.errors).to have_key :dc_right
    end
  end
  context 'when created' do
    let(:collection) { Fabricate :collection_with_repo_and_item }
    it 'belongs to a Repository' do
      expect(collection.repository).to be_kind_of Repository
    end
    it 'has a Portal value' do
      expect(collection.portals.first).to be_a_kind_of Portal
    end
    it 'has a title' do
      expect(collection.display_title).not_to be_empty
    end
    it 'has a slug' do
      expect(collection.slug).not_to be_empty
    end
    it 'has a record_id' do
      expect(collection.record_id).to include collection.slug
      expect(collection.record_id).to include collection.repository.slug
    end
    it 'contains Items' do
      expect(collection.items.first).to be_kind_of Item
    end
    it 'responds to Public Items' do
      expect(collection).to respond_to :public_items
    end
    it 'responds to DPLA Items' do
      expect(collection).to respond_to :dpla_items
    end
    it 'can have associated Subjects' do
      collection.subjects << Fabricate(:subject)
      expect(collection).to respond_to 'subjects'
      expect(collection.subjects.first).to be_a Subject
    end
    it 'can have associated Time Periods' do
      collection.time_periods << Fabricate(:time_period)
      expect(collection).to respond_to 'time_periods'
      expect(collection.time_periods.first).to be_a TimePeriod
    end
    it 'prevents items with other_collection arrays containing a collection id
        from persisting after a collection is destroyed' do
      new_repo = Fabricate :repository
      i = new_repo.items.first
      i.other_collections << collection.id.to_s
      i.save
      collection.destroy
      i.reload
      expect(i.other_collections).to be_empty
    end
    it 'updates record_id value when slug changes' do
      collection.slug = 'newslug'
      collection.save
      expect(collection.record_id).to include 'newslug'
    end
    context 'has a display value' do
      context 'for a non-public repository' do
        it 'that returns false' do
          expect(collection.display?).to eq false
        end
      end
      context 'for a public repository' do
        before :each do
          collection.repository.public = true
        end
        context 'and a non-public collection' do
          it 'that returns false' do
            expect(collection.display?).to eq false
          end
        end
        context 'and a public Collection' do
          it 'that returns true' do
            collection.public = true
            expect(collection.display?).to eq true
          end
        end
      end
    end
    context 'when deleting' do
      it 'is deleted even if items have come from batch_items' do
        collection = Fabricate :empty_collection
        item = Fabricate :item, collection: collection, portals: collection.portals
        batch_item = Fabricate :batch_item, item: item, collection: collection
        collection.reload
        expect(item.collection).to eq collection
        expect(batch_item.collection).to eq collection
        expect do
          collection.destroy
        end.not_to raise_exception
        batch_item.reload
        expect(batch_item.collection).to be_nil
      end
    end
  end
end
