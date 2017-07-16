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

        p = Fabricate :portal
        c = Fabricate(:collection)
        c2 = Fabricate(:collection)

        c.portals = [p]

        visit collections_path

        chosen_select p.name, from: '_portal_id'

        within '.index-filter-area' do
          find('.btn-primary').click
        end

        expect(page).to have_text c.display_title
        expect(page).not_to have_text c2.display_title

      end

      scenario 'can limit to just collections from multiple portals' do

        p1 = Fabricate :portal
        p2 = Fabricate :portal

        c = Fabricate(:collection)
        c2 = Fabricate(:collection)
        c3 = Fabricate(:collection)

        c.portals = [p1]
        c2.portals = [p1, p2]

        visit collections_path

        chosen_select p1.name, from: '_portal_id'
        chosen_select p2.name, from: '_portal_id'

        within '.index-filter-area' do
          find('.btn-primary').click
        end

        expect(page).to have_text c.display_title
        expect(page).to have_text c2.display_title
        expect(page).not_to have_text c3.display_title

      end

    end

    context 'portal behavior' do

      scenario 'cannot save a new collection with no portal value' do

        visit new_collection_path

        fill_in I18n.t('activerecord.attributes.collection.slug'), with: 'test'
        fill_in I18n.t('activerecord.attributes.collection.dcterms_temporal'), with: '2000'
        fill_in I18n.t('activerecord.attributes.collection.dcterms_spatial'), with: 'Georgia'
        chosen_select 'Text', from: 'dcterms-type-select'

        click_button I18n.t('meta.defaults.actions.save')

        screenshot_and_save_page
        expect(page).to have_text I18n.t('activerecord.errors.messages.portal')

      end

      scenario 'super user saves a new collection with a single portal value' do

        c = Fabricate(:collection)

        p = Fabricate(:portal)

        visit edit_collection_path c

        select p.name, from: I18n.t('activerecord.attributes.collection.portal_ids')

        click_button I18n.t('meta.defaults.actions.save')

        expect(page).to have_current_path collection_path(c)

      end

      scenario 'super user saves a new collection with a multiple portal values' do

        c = Fabricate(:collection)

        p1 = Fabricate(:portal)
        p2 = Fabricate(:portal)

        visit edit_collection_path c

        select p1.name, from: I18n.t('activerecord.attributes.collection.portal_ids')
        select p2.name, from: I18n.t('activerecord.attributes.collection.portal_ids')

        click_button I18n.t('meta.defaults.actions.save')

        expect(page).to have_current_path collection_path(c)
        expect(page).to have_text p1.name
        expect(page).to have_text p2.name

      end

      scenario 'saves a new collection removing portal value', js: true do

        c = Fabricate(:collection)
        p = Fabricate :portal

        c.portals = [p]

        visit edit_collection_path c

        within '#collection_portal_ids_chosen' do
          find('.search-choice-close').click
        end

        click_button I18n.t('meta.defaults.actions.save')

        expect(page).to have_text I18n.t('activerecord.errors.messages.portal')

      end

    end

    scenario 'index shows all collections with actions' do

      collection = Fabricate :collection

      visit collections_path

      expect(page).to have_text collection.title
      expect(page).to have_text collection.slug
      expect(page).to have_text collection.repository.title
      expect(page).to have_link I18n.t('meta.defaults.actions.view')
      expect(page).to have_link I18n.t('meta.defaults.actions.edit')
      expect(page).to have_link I18n.t('meta.defaults.actions.destroy')

    end

    scenario 'index page allows filtering by repository' do

      repository = Fabricate :repository do
        collections(count: 1)
      end

      other_repository = Fabricate :repository do
        collections(count: 1)
      end

      visit collections_path

      select repository.title, from: 'repository_id'
      click_on I18n.t('meta.defaults.actions.filter')

      expect(page).to have_text repository.title
      within 'tbody' do
        expect(page).not_to have_text other_repository.title
      end

    end

    scenario 'index page allows filtering by public status' do

      repository = Fabricate :repository do
        collections(count: 2)
      end

      public_collection = repository.collections.first
      not_public_collection = repository.collections.last

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

      Fabricate(:collection) { display_title { 'A' } }
      Fabricate(:collection) { display_title { '1' } }
      Fabricate(:collection) { display_title { 'Z' } }
      Fabricate(:collection) { display_title { 'F' } }
      Fabricate(:collection) { display_title { '"The"' } }

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

        Fabricate(:collection) {
          subjects(count:2)
        }

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

        Fabricate(:collection) {
          time_periods(count:2)
        }

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

      repository = Fabricate :repository do
        collections(count: 1)
      end

      other_repository = Fabricate :repository do
        collections(count: 1)
      end

      basic_user.repositories << repository

      visit collections_path

      expect(page).to have_text repository.collections.first.title
      within 'tbody' do
        expect(page).not_to have_text other_repository.collections.first.title
      end

    end

  end

end