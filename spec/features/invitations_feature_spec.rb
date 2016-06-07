require 'rails_helper'
include Warden::Test::Helpers
include Faker
Warden.test_mode!

feature 'Invitation Management' do

  let(:super_user) { Fabricate :super }
  let(:basic_user) { Fabricate :basic}
  let(:coordinator_user) { Fabricate :coordinator }

  scenario 'basic user should be restricted from the invitations page' do

    login_as basic_user, scope: :user

    visit auth_invitations_path

    expect(page).to have_text I18n.t('unauthorized.index.invitation')

  end

  scenario 'coordinator user can view invitations index page with action buttons' do

    login_as coordinator_user, scope: :user

    visit auth_invitations_path

    expect(page).to have_link I18n.t('meta.invitations.action.add')

  end

  scenario 'coordinator user can create a new invitation' do

    login_as coordinator_user, scope: :user

    visit new_user_invitation_path

    expect(page).to have_field I18n.t('activerecord.attributes.user.email')

    username = Faker::Internet.email

    fill_in I18n.t('activerecord.attributes.user.email'), with: username
    click_on I18n.t('devise.invitations.new.submit_button')

    expect(page).to have_text username

  end

  scenario 'coordinator user can see their pending invitations' do

    invite = Fabricate :pending_invitation
    invite2 = Fabricate :pending_invitation

    login_as coordinator_user, scope: :user

    invite.invited_by = coordinator_user
    invite.save

    visit auth_invitations_path

    expect(page).to have_text invite.email
    expect(page).not_to have_text invite2.email

  end

  scenario 'super user can see all pending invitations' do

    invite = Fabricate :pending_invitation
    invite2 = Fabricate :pending_invitation

    login_as super_user, scope: :user

    invite.invited_by = coordinator_user
    invite2.invited_by = coordinator_user
    invite.save
    invite2.save


    visit auth_invitations_path

    expect(page).to have_text invite.email
    expect(page).to have_text invite2.email

  end

  scenario 'invited user can complete invitation process' do

    invited_user = User.invite!({email: Faker::Internet.email}, coordinator_user)

    visit "#{accept_user_invitation_path}?invitation_token=#{invited_user.raw_invitation_token}"

    password = Faker::Internet.password

    fill_in I18n.t('activerecord.attributes.user.password'), with: password
    fill_in I18n.t('activerecord.attributes.user.password_confirmation'), with: password

    click_on I18n.t('devise.invitations.edit.submit_button')

    expect(page).to have_current_path authenticated_root_path
    expect(page).to have_text I18n.t('devise.invitations.updated')

  end

end