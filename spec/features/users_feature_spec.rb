require 'rails_helper'
include Warden::Test::Helpers
include Faker
Warden.test_mode!

feature 'Users Management' do

  let(:super_user) { Fabricate :super }
  let(:basic_user) { Fabricate :basic}
  let(:coordinator_user) { Fabricate :coordinator }

  context 'Super User' do

    before :each do
      login_as super_user, scope: :user
    end

    scenario 'Super User sees an list of all Users on index with action buttons' do

      user = Fabricate :user

      visit users_path

      expect(page).to have_text user.email
      expect(page).to have_link I18n.t('meta.defaults.actions.view')
      expect(page).to have_link I18n.t('meta.defaults.actions.edit')
      expect(page).to have_link I18n.t('meta.defaults.actions.destroy')
      expect(page).to have_link I18n.t('meta.user.actions.invites')
      expect(page).to have_link I18n.t('meta.user.actions.add')

    end

    scenario 'Super User clicks on Add User button and is displayed the New User form with Role fields and with Password fields' do

      visit users_path

      click_link I18n.t('meta.user.actions.add')

      expect(page).to have_field(I18n.t('activerecord.attributes.user.is_super'))
      expect(page).to have_field(I18n.t('activerecord.attributes.user.is_coordinator'))
      expect(page).to have_field(I18n.t('activerecord.attributes.user.is_uploader'))
      expect(page).to have_field(I18n.t('activerecord.attributes.user.is_committer'))
      expect(page).to have_field(I18n.t('activerecord.attributes.user.password'))
      expect(page).to have_field(I18n.t('activerecord.attributes.user.password_confirmation'))

    end

    scenario 'Super User clicks the Edit button for an existing user and sees a form to modify user info without password fields' do

      visit users_path

      click_link I18n.t('meta.defaults.actions.edit')

      expect(page).to have_current_path(edit_user_path(super_user))

      if super_user.creator_id
        expect(find_field(I18n.t('activerecord.attributes.user.creator')).value).to eq super_user.creator_id
      else
        expect(find_field(I18n.t('activerecord.attributes.user.creator')).value).to be_empty
      end
      expect(page).to have_no_field(I18n.t('activerecord.attributes.user.password'))
      expect(page).to have_no_field(I18n.t('activerecord.attributes.user.password_confirmation'))
      super_user.roles.each do |r|
        expect(page).to have_checked_field r.name
      end
      expect(find_field(I18n.t('activerecord.attributes.user.email')).value).to eq super_user.email
      expect(find_field(I18n.t('activerecord.attributes.user.repository_ids')).value).to eq super_user.repository_ids
      expect(find_field(I18n.t('activerecord.attributes.user.collection_ids')).value).to eq super_user.collection_ids

    end

    scenario 'Super User saves an Edit form and is redirected to the view page' do

      user = Fabricate :user

      visit edit_user_path(user)

      click_button I18n.t('meta.defaults.actions.save')

      expect(page).to have_current_path(user_path(user))
      expect(page).to have_text I18n.t('meta.defaults.messages.success.updated', entity: 'User')

    end

    scenario 'Super User saves an invalid New form and is redirected back to the new form with password fields' do

      visit new_user_path

      click_button I18n.t('meta.defaults.actions.save')

      expect(page).to have_field I18n.t('activerecord.attributes.user.password')
      expect(page).to have_field I18n.t('activerecord.attributes.user.password_confirmation')
      expect(page).to have_text I18n.t('meta.defaults.messages.errors.invalid_on_save', entity: 'User')

    end

  end

  context 'Coordinator User' do

    before :each  do
      login_as coordinator_user, scope: :user
    end

    scenario 'Coordinator User sees actions and a list of only their created Users on index' do

      user1 = Fabricate(:user, creator: coordinator_user)
      user2 = Fabricate(:user)

      visit users_path

      expect(page).to have_link I18n.t('meta.user.actions.invites')
      expect(page).to have_link I18n.t('meta.user.actions.add')

      expect(page).to have_text user1.email
      expect(page).not_to have_text user2.email

    end

    scenario 'Coordinator User clicks on Add User button and is displayed the New User form without Role fields and with Password fields' do

      visit users_path

      click_link I18n.t('meta.user.actions.add')

      expect(page).not_to have_field(I18n.t('activerecord.attributes.user.is_super'))
      expect(page).to have_field(I18n.t('activerecord.attributes.user.password'))
      expect(page).to have_field(I18n.t('activerecord.attributes.user.password_confirmation'))

    end

    scenario 'Coordinator User creates a user that has no roles' do

      visit new_user_path

      password = Faker::Internet.password

      fill_in I18n.t('activerecord.attributes.user.email'), with: Faker::Internet.email
      fill_in I18n.t('activerecord.attributes.user.password'), with: password
      fill_in I18n.t('activerecord.attributes.user.password_confirmation'), with: password

      click_on I18n.t('meta.defaults.actions.save')

      user = User.last

      expect(page).to have_current_path user_path(user)
      expect(user.super?).to be false
      expect(user.coordinator?).to be false
      expect(user.uploader?).to be false
      expect(user.committer?).to be false
      expect(user.basic?).to be true

    end
    
    scenario 'Coordinator User can assign repositories and collections to users' do

      collection = Fabricate :collection
      repository = Fabricate :repository

      unassigned_collection = Fabricate :collection
      unassigned_repository = Fabricate :repository

      coordinator_user.repositories << repository
      coordinator_user.collections << collection
      
      visit new_user_path

      expect(page).to have_field I18n.t('activerecord.attributes.user.collection_ids')
      expect(page).to have_field I18n.t('activerecord.attributes.user.repository_ids')

      expect(page.find_field(I18n.t('activerecord.attributes.user.collection_ids'))).to have_xpath(".//option[text() = '#{collection.title}']")
      expect(page.find_field(I18n.t('activerecord.attributes.user.collection_ids'))).not_to have_xpath(".//option[text() = '#{unassigned_collection.title}']")

      within(find_field(I18n.t('activerecord.attributes.user.repository_ids'))) do
        expect(page).to have_xpath(".//option[text() = '#{repository.title}']")
        expect(page).not_to have_xpath(".//option[text() = '#{unassigned_repository.title}']")
      end

      within(find_field(I18n.t('activerecord.attributes.user.repository_ids'))) do
        expect(page).to have_xpath(".//option[text() = '#{repository.title}']")
        expect(page).not_to have_xpath(".//option[text() = '#{unassigned_repository.title}']")
      end

      password = Faker::Internet.password

      fill_in I18n.t('activerecord.attributes.user.email'), with: Faker::Internet.email
      fill_in I18n.t('activerecord.attributes.user.password'), with: password
      fill_in I18n.t('activerecord.attributes.user.password_confirmation'), with: password

      click_on I18n.t('meta.defaults.actions.save')

      user = User.last

      expect(page).to have_current_path user_path(user)

    end

  end

  context 'Basic User' do

    before :each do
      login_as basic_user, scope: :user
    end

    scenario 'Basic User should be restricted from User area' do

      visit users_path

      expect(page).to have_text I18n.t('unauthorized.index.user')

    end

  end

end