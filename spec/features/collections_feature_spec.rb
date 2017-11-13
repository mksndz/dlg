require 'rails_helper'
require 'chosen-rails/rspec'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Collections Management' do
  let(:super_user) { Fabricate :super }
  let(:basic_user) { Fabricate :basic }
  context 'for super user' do
    before :each do
      login_as super_user, scope: :user
    end
    after :each do
      Sunspot.remove_all! Item
      Sunspot.remove_all! Collection
      Sunspot.remove_all! Repository
    end
    context 'index page filtering' do
      scenario 'can limit to just collections from a particular portal' do
        c = Fabricate(:empty_collection)
        c2 = Fabricate(:empty_collection)
        p = c.portals.last
        visit collections_path
        chosen_select p.name, from: '_portal_id'
        within '.index-filter-area' do
          find('.btn-primary').click
        end
        expect(page).to have_text c.display_title
        expect(page).not_to have_text c2.display_title
      end
      scenario 'can limit to just collections from multiple portals' do
        c = Fabricate :empty_collection
        c2 = Fabricate :empty_collection
        c3 = Fabricate :empty_collection
        c2.portals << c.portals.first
        visit collections_path
        chosen_select c.portals.first.name, from: '_portal_id'
        chosen_select c2.portals.first.name, from: '_portal_id'
        within '.index-filter-area' do
          find('.btn-primary').click
        end
        expect(page).to have_text c.display_title
        expect(page).to have_text c2.display_title
        expect(page).not_to have_text c3.display_title
      end
    end
    context 'edit page' do
      context 'portal behavior' do
        scenario 'cannot save a new collection with no portal value' do
          visit new_collection_path
          fill_in I18n.t('activerecord.attributes.collection.slug'), with: 'test'
          fill_in I18n.t('activerecord.attributes.collection.dcterms_temporal'), with: '2000'
          fill_in I18n.t('activerecord.attributes.collection.dcterms_spatial'), with: 'Georgia'
          chosen_select 'Text', from: 'dcterms-type-select'
          click_button I18n.t('meta.defaults.actions.save')
          expect(page).to have_text I18n.t('activerecord.errors.messages.portal')
        end
        scenario 'only portals from parent repository are shown as options', js: true do
          r = Fabricate :repository
          p = Fabricate :portal
          visit edit_collection_path Collection.last
          portal_options = find_all('#collection_portal_ids_chosen').collect(&:text)
          expect(portal_options.count).to eq r.portals.count
          expect(portal_options.first).to eq r.portals.first.name
          expect(portal_options).not_to include p.name
        end
        scenario 'super user saves a new collection with a multiple portal values' do
          c = Fabricate :empty_collection
          p1 = Fabricate :portal
          p2 = Fabricate :portal
          c.repository.portals << [p1, p2]
          visit edit_collection_path c
          select p1.name, from: I18n.t('activerecord.attributes.collection.portal_ids')
          select p2.name, from: I18n.t('activerecord.attributes.collection.portal_ids')
          click_button I18n.t('meta.defaults.actions.save')
          expect(page).to have_current_path collection_path(c)
          expect(page).to have_text p1.name
          expect(page).to have_text p2.name
        end
        scenario 'saves a new collection removing portal value', js: true do
          c = Fabricate :empty_collection
          visit edit_collection_path c
          within '#collection_portal_ids_chosen' do
            find('.search-choice-close').click
          end
          click_button I18n.t('meta.defaults.actions.save')
          expect(page).to have_text I18n.t('activerecord.errors.messages.portal')
        end
        scenario 'removing a portal value with children still assigned shows an error', js: true do
          r = Fabricate :repository
          c = r.collections.first
          p = Fabricate(:portal)
          r.portals << p
          c.portals << p
          visit edit_collection_path c
          find_all('.search-choice').map do |e|
            within e do
              find('.search-choice-close').click
            end if e.text == c.items.first.portals.last.name
          end
          click_button I18n.t('meta.defaults.actions.save')
          expect(page).to have_text /#{c.items.first.id}/
        end
      end
      context 'includes other fields' do
        before :each do
          Fabricate(:empty_collection) do
            partner_homepage_url 'http://lib.gsu.edu/collection'
            homepage_text '<p>This is homepage text</p>'
          end
        end
        scenario 'can see other field values' do
          visit collection_path Collection.last
          expect(page).to have_text 'http://lib.gsu.edu/collection'
          expect(page).to have_text '<p>This is homepage text</p>'
        end
        scenario 'can save partner homepage url' do
          visit edit_collection_path(Collection.last)
          fill_in I18n.t('activerecord.attributes.collection.partner_homepage_url'), with: 'http://change.homepage.url'
          click_button I18n.t('meta.defaults.actions.save')
          expect(page).to have_text 'http://change.homepage.url'
        end
        scenario 'can save homepage text' do
          visit edit_collection_path(Collection.last)
          fill_in I18n.t('activerecord.attributes.collection.homepage_text'), with: '<p>New homepage text</p>'
          click_button I18n.t('meta.defaults.actions.save')
          expect(page).to have_text '<p>New homepage text</p>'
        end
      end
    end
    scenario 'index shows all collections with actions' do
      collection = Fabricate :empty_collection
      visit collections_path
      expect(page).to have_text collection.title
      expect(page).to have_text collection.slug
      expect(page).to have_text collection.repository.title
      expect(page).to have_link I18n.t('meta.defaults.actions.view')
      expect(page).to have_link I18n.t('meta.defaults.actions.edit')
      expect(page).to have_link I18n.t('meta.defaults.actions.destroy')
    end
    scenario 'index page allows filtering by repository' do
      repository = Fabricate :repository
      other_repository = Fabricate :repository
      visit collections_path
      select repository.title, from: 'repository_id'
      click_on I18n.t('meta.defaults.actions.filter')
      expect(page).to have_text repository.title
      within 'tbody' do
        expect(page).not_to have_text other_repository.title
      end
    end
    scenario 'index page allows filtering by public status' do
      Fabricate.times 2, :empty_collection
      public_collection = Collection.first
      not_public_collection = Collection.last
      public_collection.public = true
      public_collection.save
      not_public_collection.public = false
      not_public_collection.save
      visit collections_path
      select 'Public', from: 'public'
      click_on I18n.t('meta.defaults.actions.filter')
      expect(page).to have_text public_collection.slug
      within 'tbody' do
        expect(page).not_to have_text not_public_collection.slug
      end
    end
    scenario 'index page allows sorting by item count' do
      Fabricate :empty_collection, display_title: 'A'
      Fabricate :empty_collection, display_title: '1'
      Fabricate :empty_collection, display_title: 'Z'
      Fabricate :empty_collection, display_title: 'F'
      Fabricate :empty_collection, display_title: '"The"'
      visit collections_path
      click_on I18n.t('meta.defaults.labels.columns.title')
      titles = []
      page.all('table tbody tr').each do |row|
        titles << row.all('td')[2].text
      end
      expect(titles).to eq %w(1 A F "The" Z)
    end
    context 'working with subjects' do
      before :each do
        Fabricate(:empty_collection) do
          subjects(count: 2)
        end
        visit edit_collection_path(Collection.last)
      end
      scenario 'collection has checkboxes designating assigned subject categories' do
        expect(page).to have_checked_field(Collection.last.subjects.first.name)
      end
      scenario 'collection is re-saved without duplicating saved subject values' do
        find('.fixed-save-button').click
        expect(Collection.last.subjects.length).to eq(2)
      end
    end
    context 'working with time_periods' do
      before :each do
        Fabricate(:empty_collection) do
          time_periods(count: 2)
        end
        visit edit_collection_path(Collection.last)
      end
      scenario 'collection has checkboxes designating assigned time periods' do
        expect(page).to have_checked_field(Collection.last.time_periods.first.name)
      end
      scenario 'collection is re-saved without duplicating saved time periods' do
        find('.fixed-save-button').click
        expect(Collection.last.time_periods.length).to eq(2)
      end
    end
  end
  context 'for basic user' do
    before :each do
      login_as basic_user, scope: :user
    end
    scenario 'index page allows filtering by repository' do
      repository = Fabricate :repository
      other_repository = Fabricate :repository
      basic_user.repositories << repository
      visit collections_path
      expect(page).to have_text repository.collections.first.title
      within 'tbody' do
        expect(page).not_to have_text other_repository.collections.first.title
      end
    end
  end
end