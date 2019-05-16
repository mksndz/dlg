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
        expect(page).to have_text resource.content
      end
    end
    context 'edit page' do
      before :each do
        visit edit_collection_collection_resource_path(resource.collection, resource)
      end
    end
    context 'new page' do
      before :each do
        visit new_collection_collection_resource_path(resource.collection)
      end
    end
  end
end