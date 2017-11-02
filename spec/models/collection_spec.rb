require 'rails_helper'

RSpec.describe Collection, type: :model do
  it 'has none to begin with' do
    expect(Collection.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate :repository
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
  context 'when created' do
    before :each do
      @collection = Fabricate(:repository).collections.first
    end
    it 'belongs to a Repository' do
      expect(@collection.repository).to be_kind_of Repository
    end
    it 'has a Portal value' do
      expect(@collection.portals.first).to be_a_kind_of Portal
    end
    it 'has a title' do
      expect(@collection.display_title).not_to be_empty
    end
    it 'has a slug' do
      expect(@collection.slug).not_to be_empty
    end
    it 'contains Items' do
      expect(@collection.items.first).to be_kind_of Item
    end
    it 'responds to Public Items' do
      expect(@collection).to respond_to :public_items
    end
    it 'responds to DPLA Items' do
      expect(@collection).to respond_to :dpla_items
    end
    it 'can have associated Subjects' do
      @collection.subjects << Fabricate(:subject)
      expect(@collection).to respond_to 'subjects'
      expect(@collection.subjects.first).to be_a Subject
    end
    it 'can have associated Time Periods' do
      @collection.time_periods << Fabricate(:time_period)
      expect(@collection).to respond_to 'time_periods'
      expect(@collection.time_periods.first).to be_a TimePeriod
    end
    it 'prevents items with other_collection arrays containing a collection id
        from persisting after a collection is destroyed' do
      new_repo = Fabricate :repository
      i = new_repo.items.first
      i.other_collections << @collection.id.to_s
      i.save
      @collection.destroy
      i.reload
      expect(i.other_collections).to be_empty
    end
    context 'has a display value' do
      context 'for a non-public repository' do
        it 'that returns false' do
          expect(@collection.display?).to eq false
        end
      end
      context 'for a public repository' do
        before :each do
          @collection.repository.public = true
        end
        context 'and a non-public collection' do
          it 'that returns false' do
            expect(@collection.display?).to eq false
          end
        end
        context 'and a public Collection' do
          it 'that returns true' do
            @collection.public = true
            expect(@collection.display?).to eq true
          end
        end
      end
    end
  end
end
