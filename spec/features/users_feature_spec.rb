require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Users Management' do

  let(:super_user) { Fabricate :super }
  let(:basic_user) { Fabricate :basic}
  let(:coordinator_user) { Fabricate :coordinator }

  scenario 'Super User sees an list of all Users on index with action buttons' do

    login_as super_user, scope: :user

    user = Fabricate :user

    visit users_path

    expect(page).to have_text user.email
    expect(page).to have_link I18n.t('meta.defaults.actions.view')
    expect(page).to have_link I18n.t('meta.defaults.actions.edit')
    expect(page).to have_link I18n.t('meta.defaults.actions.destroy')
    expect(page).to have_link I18n.t('meta.user.actions.invites')
    expect(page).to have_link I18n.t('meta.user.actions.add')

  end

  scenario 'Coordinator User sees actions and a list of only their created Users on index' do

    login_as coordinator_user, scope: :user

    user1 = Fabricate(:user, creator: coordinator_user)
    user2 = Fabricate(:user)

    visit users_path

    expect(page).to have_link I18n.t('meta.user.actions.invites')
    expect(page).to have_link I18n.t('meta.user.actions.add')

    expect(page).to have_text user1.email
    expect(page).not_to have_text user2.email

  end

  scenario 'Basic User should be restricted from User area' do

    login_as basic_user, scope: :user

    visit users_path

    p = page.html

    expect(page).to have_text I18n.t('unauthorized.index.user')

  end

  scenario 'Super User clicks on Add User button and is displayed the New User form with Role fields' do

    login_as super_user, scope: :user

    visit users_path

    click_link I18n.t('meta.user.actions.add')

    page.has_css?('#user_role_ids_1')

  end

  scenario 'Super User clicks on Add User button and is displayed the New User form without Role fields' do

    login_as super_user, scope: :user

    visit users_path

    click_link I18n.t('meta.user.actions.add')

    page.has_no_css?('#user_role_ids_1')

  end

  scenario 'Super User clicks the Edit button for an existing user and sees a form to modify user info' do

    login_as super_user, scope: :user

    visit users_path

    click_link I18n.t('meta.defaults.actions.edit')

    expect(page).to have_current_path(edit_user_path(super_user))

    if super_user.creator_id
      expect(find_field(I18n.t('activerecord.attributes.user.creator')).value).to eq super_user.creator_id
    else
      expect(find_field(I18n.t('activerecord.attributes.user.creator')).value).to be_empty
    end

    super_user.roles.each do |r|
      expect(page).to have_checked_field r.name
    end

    expect(find_field(I18n.t('activerecord.attributes.user.email')).value).to eq super_user.email
    expect(find_field(I18n.t('activerecord.attributes.user.repository_ids')).value).to eq super_user.repository_ids
    expect(find_field(I18n.t('activerecord.attributes.user.collection_ids')).value).to eq super_user.collection_ids

  end

end