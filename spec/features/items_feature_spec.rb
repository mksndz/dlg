require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Item Management' do

  let(:super_user) { Fabricate :super }

  scenario 'when user does a search from a sorted index list, the search should not fail' do

    login_as super_user, scope: :user

    Fabricate :item

    visit items_path

    click_link I18n.t('meta.defaults.labels.columns.slug')

    fill_in 'search for', with: 'anything'
    click_button 'Search'

    expect(page).to have_text 'Limit your search'

  end

end