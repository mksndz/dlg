require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Item Management' do

  let(:super_user) { Fabricate :super }
  let(:basic_user) { Fabricate :basic}
  let(:coordinator_user) { Fabricate :coordinator }

  context 'Super User' do

    before :each do
      login_as super_user, scope: :user
    end

    scenario 'Super User sees a profile menu with three items' do

      visit root_path

      expect(page).to have_link I18n.t('meta.app.user_menu.profile')
      expect(page).to have_link I18n.t('meta.app.user_menu.change_password')
      expect(page).to have_link I18n.t('blacklight.header_links.logout')

    end

    scenario 'Change Password page allows password to be changed' do

      visit edit_profile_path

      expect(page).to have_field I18n.t('activerecord.attributes.user.password')
      expect(page).to have_field I18n.t('activerecord.attributes.user.password_confirmation')

      fill_in I18n.t('activerecord.attributes.user.password'), with: 'newpassword'
      fill_in I18n.t('activerecord.attributes.user.password_confirmation'), with: 'newpassword'

      click_button I18n.t('meta.defaults.actions.save')

      expect(page).to have_text I18n.t('meta.profile.messages.success.password_changed')

    end

  end

  context 'Basic User' do

    before :each do
      login_as basic_user, scope: :user
    end

    scenario 'Basic User sees a panel showing their assigned coordinator user, if applicable' do

      basic_user.creator = coordinator_user

      visit profile_path

      expect(page).to have_text coordinator_user.email

    end

  end

end