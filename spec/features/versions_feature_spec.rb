require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Versions' do
  let(:super_user) { Fabricate :super }
  before :each do
    login_as super_user, scope: :user
  end
  with_versioning do
    scenario 'super user views an item and should see versions listed' do
      item = Fabricate(:repository).items.first
      item.update(slug: 'newslug')
      visit item_path(item)
      expect(page).to have_link I18n.t('meta.versions.action.diff')
      expect(page).to have_link I18n.t('meta.versions.action.rollback')
    end
    scenario 'super user rolls back to previous version of an item and is redirected to the item show page with a success message' do
      item = Fabricate(:repository).items.first
      original_slug = item.slug
      item.update(slug: 'newslug')
      visit item_path(item)
      click_on I18n.t('meta.versions.action.rollback')
      expect(page).to have_current_path item_path(item)
      expect(page).to have_text I18n.t('meta.versions.messages.success.rollback')
      expect(page).to have_text original_slug
    end
    scenario 'deleted items are listed with restore link when super user visits deleted item page' do
      item = Fabricate(:repository).items.first
      original_slug = item.slug
      item.destroy
      visit deleted_items_path
      expect(page).to have_text original_slug
      expect(page).to have_link I18n.t('meta.item.actions.restore')
    end
    scenario 'super user restores a deleted item and is taken to the restored item show page' do
      item = Fabricate(:repository).items.first
      item = item.destroy
      visit deleted_items_path
      click_on I18n.t('meta.item.actions.restore')
      expect(page).to have_current_path item_path(item)
      expect(page).to have_text I18n.t('meta.versions.messages.success.restore')
      expect(page).to have_text item.slug
    end
  end
end