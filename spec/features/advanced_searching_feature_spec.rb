require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Searching' do
  let(:super_user) { Fabricate :super }
  context 'for super user' do
    before(:each) do
      login_as super_user, scope: :user
      Fabricate :repository
      Sunspot.commit
    end
    scenario 'does an advanced search and results are returned' do
      visit blacklight_advanced_search_engine.advanced_search_path
      fill_in 'title', with: Repository.last.items.first.dcterms_title.first
      click_button 'Search'
      expect(page).to have_css '.document'
    end
  end
end