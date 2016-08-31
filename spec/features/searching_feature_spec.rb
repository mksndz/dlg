require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Searching' do

  let(:super_user) { Fabricate :super }

  context 'for super user' do

    before :each do
      login_as super_user, scope: :user
    end

    scenario 'does a search and results are returned' do

      Fabricate(:collection) { items(count:10 )}
      Sunspot.commit

      visit root_path

      fill_in 'all_fields', with: ''

      click_button 'Search'

      expect(page).to have_css('.document')

    end

    scenario 'does a search and can navigate the edit forms for the results across items and collections' do

      Fabricate(:collection) { items(count: 1)}
      Sunspot.commit

      visit root_path

      fill_in 'all_fields', with: ''

      click_button 'Search'

      z = first('.edit-record')

      z.click

      expect(page).to have_link 'Next Result'
      expect(page).not_to have_link 'Previous Result'

      click_on 'Next Result'

      expect(page).not_to have_link 'Next Result'
      expect(page).to have_link 'Previous Result'

    end

  end

  context 'for basic user' do

    scenario '' do



    end

  end

end