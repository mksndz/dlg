require 'rails_helper'

RSpec.describe Item, type: :model do
  it 'has none to begin with' do
    expect(Item.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate :repository
    expect(Item.count).to eq 1
  end
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
  it 'should require one of the dcterms_type values to be in a standardized
      set' do
    i = Fabricate.build(:item, dcterms_type: ['Some Random Silly Type'])
    i.valid?
    expect(i.errors).to have_key :dcterms_type
  end
  it 'should not require a dcterms_temporal value' do
    i = Fabricate.build(:item, dcterms_temporal: [])
    i.valid?
    expect(i.errors).not_to have_key :dcterms_temporal
  end
  it 'should require each of the dcterms_temporal values use a limited character
      set' do
    i = Fabricate.build(:item, dcterms_temporal: ['Text'])
    i.valid?
    expect(i.errors).to have_key :dcterms_temporal
  end
  it 'should require a dcterms_title value' do
    i = Fabricate.build(:item, dcterms_title: [])
    i.valid?
    expect(i.errors).to have_key :dcterms_title
  end
  it 'should require a subject in either subject field' do
    i = Fabricate.build(
      :item,
      dcterms_subject: [],
      dlg_subject_personal: []
    )
    i.valid?
    expect(i.errors).to have_key :dcterms_subject
  end
  it 'should not require a dcterms_subject if dlg_subject_personal is
      provided' do
    i = Fabricate.build(
      :item,
      dcterms_subject: [],
      dlg_subject_personal: ['Santa']
    )
    i.valid?
    expect(i.errors).not_to have_key :dcterms_subject
  end
  it 'should not require a dlg_subject_personal if dcterms_subject is
      provided' do
    i = Fabricate.build(
      :item,
      dcterms_subject: ['Santa'],
      dlg_subject_personal: []
    )
    i.valid?
    expect(i.errors).not_to have_key :dlg_subject_personal
  end
  it 'should require a value in dcterms_provenance' do
    i = Fabricate.build(:item, dcterms_provenance: [])
    i.valid?
    expect(i.errors).to have_key :dcterms_provenance
  end
  it 'should require a value in edm_is_shown_at' do
    i = Fabricate.build(:item, edm_is_shown_at: [])
    i.valid?
    expect(i.errors).to have_key :edm_is_shown_at
  end
  it 'should require a valid URL in edm_is_shown_at' do
    i = Fabricate.build(:item, edm_is_shown_at: ['not/a.url'])
    i.valid?
    expect(i.errors).to have_key :edm_is_shown_at
  end
  it 'should be valid if there is a valid URL in edm_is_shown_at' do
    i = Fabricate.build(
      :item,
      edm_is_shown_at: ['http://dlg.galileo.usg.edu']
    )
    i.valid?
    expect(i.errors).not_to have_key :edm_is_shown_at
  end
  it 'should require a value in edm_is_shown_by' do
    i = Fabricate.build(:item, edm_is_shown_by: [], local: true)
    i.valid?
    expect(i.errors).to have_key :edm_is_shown_by
  end
  it 'should require a valid URL in edm_is_shown_by' do
    i = Fabricate.build(
      :item,
      edm_is_shown_by: ['not/a.url'],
      local: true
    )
    i.valid?
    expect(i.errors).to have_key :edm_is_shown_by
  end
  it 'should be valid if there is a valid URL in edm_is_shown_by' do
    i = Fabricate.build(
      :item,
      edm_is_shown_by: ['http://dlg.galileo.usg.edu'],
      local: true
    )
    i.valid?
    expect(i.errors).not_to have_key :edm_is_shown_by
  end
  it 'should be valid if there is a no value in edm_is_shown_by but the item is
      not local' do
    i = Fabricate.build(:item, edm_is_shown_by: [], local: false)
    i.valid?
    expect(i.errors).not_to have_key :edm_is_shown_by
  end
  it 'should only allow valid characters in the slug' do
    invalid1 = Fabricate.build(:item, slug: 'slug/')
    invalid2 = Fabricate.build(:item, slug: 'Slug')
    invalid3 = Fabricate.build(:item, slug: 'sl ug')
    invalid4 = Fabricate.build(:item, slug: 'slug/')
    invalid5 = Fabricate.build(:item, slug: 'slug:')
    valid = Fabricate.build(:item, slug: 'valid-slug')
    invalid1.valid?
    invalid2.valid?
    invalid3.valid?
    invalid4.valid?
    invalid5.valid?
    valid.valid?
    expect(invalid1.errors).to have_key :slug
    expect(invalid2.errors).to have_key :slug
    expect(invalid3.errors).to have_key :slug
    expect(invalid4.errors).to have_key :slug
    expect(invalid5.errors).to have_key :slug
    expect(valid.errors).not_to have_key :slug
  end
  context 'when created' do
    before :each do
      @item = Fabricate(:repository).items.first
    end
    it 'has a scope that returns items updated after a provided date' do
      @item.updated_at = '2015-01-01'
      @item.save
      i2 = Fabricate(:repository).items.first
      i2.updated_at = '2017-01-01'
      i2.save
      selected_items = Item.updated_since('2016-01-01')
      expect(selected_items).to include i2
      expect(selected_items).not_to include @item
    end
    it 'belongs to a Repository' do
      expect(@item.repository).to be_kind_of Repository
    end
    it 'belongs to a Collection' do
      expect(@item.collection).to be_kind_of Collection
    end
    it 'has a String title' do
      expect(@item.title).to be_kind_of String
    end
    it 'has an Array dcterms_title' do
      expect(@item.dcterms_title).to be_kind_of Array
    end
    it 'has an Array dlg_subject_personal' do
      expect(@item.dcterms_title).to be_kind_of Array
    end
    it 'has a boolean method has_thumbnail' do
      expect(@item.has_thumbnail?).to be false
    end
    it 'has a slug' do
      expect(@item.slug).not_to be_empty
    end
    it 'has a record_id' do
      expect(@item.record_id).not_to be_empty
    end
    it 'has a record_id that tracks changes to collection' do
      expect(@item.record_id).to include @item.slug
      expect(@item.record_id).to include @item.collection.slug
      expect(@item.record_id).to include @item.repository.slug
    end
    it 'has a facet_years value that is an Array of years taken from dc_date' do
      @item.dc_date = %w(991 1802 2001 1776-1791 1900/1901)
      expect(@item.facet_years).to eq %w(1802 2001 1776 1791 1900 1901)
    end
    it 'returns an array for coordinates' do
      @item.dcterms_spatial = [
        'United States, Georgia, DeKalb County, Decatur, 33.7748275, -84.2963123',
        'United States, Georgia, Fulton County, 33.7902836, -84.466986'
      ]
      expect(@item.coordinates).to eq [
        '33.7748275, -84.2963123',
        '33.7902836, -84.466986'
      ]
    end
    it 'returns an array containing parseable JSON strings geojson if
        coordinates are found present in the dcterms_spatial field' do
      @item.dcterms_spatial = [
        'United States, Georgia, DeKalb County, Decatur, 33.7748275, -84.2963123',
        'United States, Georgia, Fulton County, 33.7902836, -84.466986'
      ]
      @item.geojson.each do |g|
        expect(JSON.parse(g)).to be_a Hash
      end
    end
    context 'ensures scoped uniqueness of slug' do
      it 'by disallowing the creation of two items with the same slug related to
          the same collection' do
        i2 = Fabricate(:repository).items.first
        i2.collection = @item.collection
        i2.slug = @item.slug
        expect { i2.save! }.to raise_exception ActiveRecord::RecordInvalid
        expect(i2.errors).to include :slug
      end
      it 'when creating two items with the same slug related to different
          collection' do
        i2 = Fabricate(:repository).items.first
        i2.repository = @item.repository
        expect { i2.save! }.not_to raise_exception
      end
    end
    context 'has other_* values' do
      before :each do
        @collection2 = Fabricate(:repository).collections.first
        @collection3 = Fabricate(:repository).collections.first
        @item.other_collections = [@collection2.id, @collection3.id]
      end
      it 'that includes the titles of other_collections' do
        expect(@item.collection_titles).to include @item.collection.title
        expect(@item.collection_titles).to include @collection2.title
        expect(@item.collection_titles).to include @collection3.title
      end
      it 'that includes the repository titles associated with other_collections' do
        expect(@item.repository_titles).to include @item.repository.title
        expect(@item.repository_titles).to include @collection2.repository.title
        expect(@item.repository_titles).to include @collection3.repository.title
      end
    end
    context 'has validation status' do
      it 'of true if the item is valid' do
        @item.valid?
        expect(@item.valid_item).to be true
      end
      it 'of false if the item is invalid' do
        i1 = Fabricate.build :item
        i1.valid?
        expect(i1.valid_item).to be false
      end
    end
    context 'has a counties method' do
      before :each do
        @item.dcterms_spatial = [
          'United States, Georgia',
          'United States, Georgia, Muscogee County, Columbus, 32.4609764, -84.9877094	7,519',
          'United States, Georgia, Jeff Davis County, Test, 34.4212053, -84.1190804'
        ]
      end
      it 'that extracts Georgia county values from dcterms_spatial' do
        expect(@item.counties).to eq ['Muscogee', 'Jeff Davis']
      end
    end
    context 'has a display value' do
      context 'for a non-public Repository' do
        context 'and a non-public Collection' do
          context 'and a non-public Item' do
            it 'that returns false' do
              expect(@item.display?).to eq false
            end
          end
          context 'and a public Item' do
            it 'that returns true' do
              @item.public = true
              expect(@item.display?).to eq false
            end
          end
        end
        context 'and a public Collection' do
          before :each do
            @item.collection.public = true
          end
          context 'and a non-public Item' do
            it 'returns false' do
              expect(@item.display?).to eq false
            end
          end
          context 'and a public Item' do
            it 'returns true' do
              @item.public = true
              expect(@item.display?).to eq false
            end
          end
        end
      end
      context 'for a public Repository' do
        before :each do
          @item.repository.public = true
        end
        context 'and a non-public Collection' do
          context 'and a non-public Item' do
            it 'returns false' do
              expect(@item.display?).to eq false
            end
          end
          context 'and a public Item' do
            it 'returns false' do
              @item.public = true
              expect(@item.display?).to eq false
            end
          end
        end
        context 'and a public Collection' do
          context 'and a non-public Item' do
            it 'returns false' do
              expect(@item.display?).to eq false
            end
          end
          context 'and a public Item' do
            it 'returns true' do
              @item.public = true
              expect(@item.display?).to eq false
            end
          end
        end
      end
    end
  end
  # context 'metadata field cleaning' do
  #   before :each do
  #     Fabricate :item do
  #       dcterms_description { ['Blah blah<br><BR/><br />blahblah'] }
  #       dcterms_title { ['<p><b>Blah</b> <i>blah</i></p>', '<u>Blah</u>', '<em>Blah</em><sup>1</sup>'] }
  #       dc_relation { ['<a href="http://www.blah.edu">Blah</a>', '<a href="http://blahblah.edu">Blah blah</a>'] }
  #     end
  #   end
  #
  #   context 'html tags are converted or stripped' do
  #     it 'converts <br> tags to newlines' do
  #       expect(Item.last.dcterms_description).to eq ["Blah blah\n\n\nblahblah"]
  #     end
  #     it 'removes presentation-related html tags' do
  #       expect(Item.last.dcterms_title).to eq ['Blah blah', 'Blah', 'Blah1']
  #     end
  #     it 'removes <a> links leaving only the link text' do
  #       expect(Item.last.dc_relation).to eq ['Blah', 'Blah blah']
  #     end
  #   end
  # end
end
