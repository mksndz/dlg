require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Document' do
  context 'for super user' do
    before :each do
      login_as Fabricate(:super), scope: :user
    end
    scenario 'document view shows a rights icon that links to the uri' do
      i = Fabricate(:repository).items.first
      Sunspot.commit
      visit solr_document_path(i.record_id)
      expect(page).to have_css '.rights-statement-icon'
      expect(page).to have_xpath '//a[@href = "' + i.dc_right.first + '"]'
    end
    scenario 'document view has a page title that begins with the item title' do
      i = Fabricate(:repository).items.first
      Sunspot.commit
      visit solr_document_path(i.record_id)
      expect(page).to have_title i.title
    end
  end
end