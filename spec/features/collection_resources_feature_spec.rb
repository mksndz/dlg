require 'rails_helper'
require 'chosen-rails/rspec'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Collection Resource management' do
  subject(:resource) do
    Fabricate(:collection_resource)
  end
  before :each do
    login_as Fabricate(:super), scope: :user
  end
  context 'basic CRUD functionality' do
    context 'index page' do
      scenario 'sees a list of all collection resources and action buttons' do
        visit collection_collection_resources_path(resource.collection)
        expect(page).to have_text resource.title
        expect(page).to have_link I18n.t('meta.defaults.actions.view')
        expect(page).to have_link I18n.t('meta.defaults.actions.edit')
        expect(page).to have_link I18n.t('meta.defaults.actions.destroy')
      end
    end
    context 'show page' do
      it 'displays all record information' do
        visit collection_collection_resource_path(resource.collection, resource)
        expect(page).to have_text resource.slug
        expect(page).to have_text resource.title
        expect(page).to have_text resource.position
        expect(page).to have_text resource.raw_content
        expect(page).to have_text resource.scrubbed_content
      end
    end
    context 'edit page' do
      before :each do
        visit edit_collection_collection_resource_path(resource.collection, resource)
      end
      scenario 'can update fields and see the updated results' do
        new_slug = 'New Slug'
        new_position = '999'
        new_title = 'New Title'
        new_content = 'Some New Content'
        fill_in I18n.t('activerecord.attributes.collection_resource.slug'),
                with: new_slug
        fill_in I18n.t('activerecord.attributes.collection_resource.position'),
                with: new_position
        fill_in I18n.t('activerecord.attributes.collection_resource.title'),
                with: new_title
        fill_in I18n.t('activerecord.attributes.collection_resource.raw_content'),
                with: new_content
        click_button I18n.t('meta.defaults.actions.save')
        expect(page).to have_current_path collection_collection_resource_path(
                                            resource.collection, resource)
        expect(page).to have_text new_slug
        expect(page).to have_text new_position
        expect(page).to have_text new_title
        expect(page).to have_text new_content
      end
    end
    context 'new page' do
      before :each do
        visit new_collection_collection_resource_path(resource.collection)
      end
      scenario 'can be used to create a new record' do
        new_slug = 'New Slug'
        new_position = '999'
        new_title = 'New Title'
        new_content = 'Some New Content'
        fill_in I18n.t('activerecord.attributes.collection_resource.slug'),
                with: new_slug
        fill_in I18n.t('activerecord.attributes.collection_resource.position'),
                with: new_position
        fill_in I18n.t('activerecord.attributes.collection_resource.title'),
                with: new_title
        fill_in I18n.t('activerecord.attributes.collection_resource.raw_content'),
                with: new_content
        click_button I18n.t('meta.defaults.actions.save')
        new_resource = CollectionResource.last
        expect(page).to have_current_path collection_collection_resource_path(
                                            resource.collection, new_resource)
        expect(page).to have_text new_slug
        expect(page).to have_text new_position
        expect(page).to have_text new_title
        expect(page).to have_text new_content
      end
      scenario 'shows a helpful error message if required values are blank' do
        click_button I18n.t('meta.defaults.actions.save')
        expect(page).to have_text "#{I18n.t('activerecord.attributes.collection_resource.slug')} #{I18n.t('activerecord.errors.messages.blank')}"
        expect(page).to have_text "#{I18n.t('activerecord.attributes.collection_resource.title')} #{I18n.t('activerecord.errors.messages.blank')}"
        expect(page).to have_text "#{I18n.t('activerecord.attributes.collection_resource.raw_content')} #{I18n.t('activerecord.errors.messages.blank')}"
      end
    end
  end
end