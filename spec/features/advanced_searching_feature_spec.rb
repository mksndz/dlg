require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Searching' do

  let(:super_user) { Fabricate :super }

  context 'for super user', js: true do

    before :each do
      login_as super_user, scope: :user
    end

    after :each do
      Sunspot.remove_all! Item
      Sunspot.remove_all! Collection
    end

    scenario 'does an advanced search and results are returned' do

      Fabricate(:collection) { items(count: 1) }
      Sunspot.commit

      visit blacklight_advanced_search_engine.advanced_search_path

      fill_in 'title', with: Collection.last.items.first.dcterms_title.first

      click_button 'Search'

      expect(page).to have_css('.document')

    end

  end

end