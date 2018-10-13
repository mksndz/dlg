require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Advanced Searching' do
  before :each do
    login_as Fabricate(:super), scope: :user
  end
  after :each do
    Sunspot.remove_all! Item
    Sunspot.remove_all! Collection
    Sunspot.remove_all! Repository
  end
  context 'for basic behaviors' do
    before :each do
      c = Fabricate :collection_with_repo_and_robust_item, slug: 'polyester'
      r = c.repository
      r.slug = 'zzz'
      r.save
      c.save
      Collection.reindex
      i = r.items.first
      i.slug = 'quack'
      i.save
      Item.reindex
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
    end
    scenario 'an all fields search returns results' do
      fill_in 'all_fields', with: Item.first.dcterms_title.last
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    context 'with substrings' do
      scenario 'slug search returns relevant results based on substrings' do
        fill_in 'slug', with: 'ester'
        click_button 'Search'
        expect(all('.edit-record').count).to eq 1
      end
      scenario 'record id search returns relevant results based on substrings' do
        fill_in 'record_id', with: 'ester'
        click_button 'Search'
        expect(all('.edit-record').count).to eq 2
      end
    end
    context 'facet behavior', js: true do
      context 'for Items' do
        scenario 'there exists a portals facet' do
          expect(page).to have_css '#portal_names_sms_chosen'
        end
        scenario 'there exists a validity facet' do
          expect(page).to have_css '#valid_item_b_chosen'
        end
        scenario 'there exists a publisher facet' do
          expect(page).to have_css '#publisher_facet_chosen'
        end
        scenario 'there exists a counties facet' do
          expect(page).to have_css '#counties_facet_chosen'
        end
      end
      context 'for Collections' do
        scenario 'there exists a collection_provenance_facet facet' do
          expect(page).to have_css '#collection_provenance_facet_chosen'
        end
        scenario 'there exists a collection_type_facet facet' do
          expect(page).to have_css '#collection_type_facet_chosen'
        end
        scenario 'there exists a collection_spatial_facet facet' do
          expect(page).to have_css '#collection_spatial_facet_chosen'
        end
      end
    end
  end
  context 'facet limit behavior' do
    scenario 'advanced search facets are not limited to 11', js: true do
      Fabricate.times 20, :repository
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      find('#repository_name_sms_chosen').click
      expect(page).to have_text Repository.first.title
      expect(page).to have_text Repository.last.title
    end
  end
  context 'for special search fields' do
    before :each do
      collection = Fabricate :empty_collection
      @item = Fabricate.build(
        :item,
        collection: collection,
        portals: collection.portals,
        holding_institutions: [Fabricate(:holding_institution, authorized_name: 'PPPPPPPPPPPPPPP')]
      )
    end
    scenario 'title search returns only relevant results' do
      @item.dcterms_title = ['ZZZZZZZZZZ']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'title', with: 'ZZZZZZZZZZ'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'creator search returns only relevant results' do
      @item.dcterms_creator = ['ZZZZZZZZZZ']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'creator', with: 'ZZZZZZZZZZ'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'contributor search returns only relevant results' do
      @item.dcterms_contributor = ['ZZZZZZZZZZ']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'contributor', with: 'ZZZZZZZZZZ'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'subject search returns only relevant results' do
      @item.dcterms_subject = ['ZZZZZZZZZZ']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'subject', with: 'ZZZZZZZZZZ'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'description search returns only relevant results' do
      @item.dcterms_description = ['ZZZZZZZZZZ']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'description', with: 'ZZZZZZZZZZ'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'publisher search returns only relevant results' do
      @item.dcterms_publisher = ['ZZZZZZZZZZ']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'publisher', with: 'ZZZZZZZZZZ'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'date search returns only relevant results' do
      @item.dc_date = ['9999']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'date', with: '9999'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'temporal search returns only relevant results' do
      @item.dcterms_temporal = ['9999']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'temporal', with: '9999'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'spatial search returns only relevant results' do
      @item.dcterms_spatial = ['ZZZZZZZZZZ']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'spatial', with: 'ZZZZZZZZZZ'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'is part of search returns only relevant results' do
      @item.dcterms_is_part_of = ['ZZZZZZZZZZ']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'is_part_of', with: 'ZZZZZZZZZZ'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'is shown at search returns only relevant results' do
      @item.edm_is_shown_at = ['http://www.google.com']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'is_shown_at', with: 'www.google.com'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'is shown by search returns only relevant results' do
      @item.edm_is_shown_by = ['http://www.google.com']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'is_shown_by', with: 'www.google.com'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'is shown at search returns results using a part of the url hierarchy' do
      @item.edm_is_shown_at = ['http://dl.ga/Topics/GovernmentPolitics.html']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'is_shown_at', with: 'Topics'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'identifier search returns only relevant results' do
      @item.dcterms_identifier = ['ZZZZZZZZZZ']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'identifier', with: 'ZZZZZZZZZZ'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'identifier search returns results using a part of the url hierarchy' do
      @item.dcterms_identifier = ['http://dlg.galileo.usg.edu/Topics/GovernmentPolitics.html']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'identifier', with: 'http://dlg.galileo.usg.edu'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'rights holder search returns results only relevant results' do
      @item.dcterms_rights_holder = ['ZZZZZZZZZZZZZZZZZZZ']
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'rights_holder', with: 'ZZZZZZZZZZZZZZZZZZZ'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'provenance search returns results only relevant results' do
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'provenance', with: 'PPPPPPPPPPPPPPP'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
    scenario 'collection name search returns results only relevant results' do
      c = @item.collection
      c.display_title = 'Vanishing Georgia'
      c.save
      @item.save
      Sunspot.commit
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'collection_name', with: 'georgia'
      click_button 'Search'
      expect(all('.edit-record').count).to eq 1
    end
  end
end