require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Collections Management' do

  let(:super_user) { Fabricate :super }
  let(:basic_user) { Fabricate :basic }

  context 'for super user' do

    before :each do
      login_as super_user, scope: :user
    end

    scenario 'index shows all collections with actions' do

      collection = Fabricate :collection
      # another_collection = Fabricate :collection

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