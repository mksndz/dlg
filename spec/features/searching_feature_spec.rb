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

    scenario 'does a search and results are returned' do

      Fabricate(:collection) { items(count:1 ) }
      Sunspot.commit

      visit root_path

      fill_in 'title', with: ''

      click_button 'Search'

      expect(page).to have_css('.document')

    end

    scenario 'does a search and can navigate the edit forms for the results across items and collections' do

      c = Fabricate(:collection) { items(count: 1) }
      Sunspot.commit

      visit root_path

      fill_in 'title', with: ''

      click_button 'Search'

      expect(all('.edit-record').count).to eq 2

      first('.edit-record').click

      expect(page).to have_link 'Next Result'
      expect(page).not_to have_link 'Previous Result'

      click_on 'Next Result'

      expect(page).not_to have_link 'Next Result'
      expect(page).to have_link 'Previous Result'

    end

    context 'advanced searching functionality' do

      scenario 'slug search returns results based on substrings' do

        Fabricate(:item) {
          slug 'polyester'
        }
        Sunspot.commit

        visit blacklight_advanced_search_engine.advanced_search_path

        fill_in 'slug', with: 'yes'

        click_button 'Search'

        expect(all('.edit-record').count).to eq 1

      end

    end

  end

  context 'for basic user' do

    scenario '' do



    end

  end

end