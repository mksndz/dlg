require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Logging In and Out' do

  scenario 'User browses to the site is presented with a login form' do

    visit '/'

    expect(page).to have_text I18n.t('activerecord.attributes.user.email')

  end

  scenario 'User provides invalid credentials' do

    visit '/'

    fill_in I18n.t('activerecord.attributes.user.email'), with: 'blahblah@blah.org'
    click_button 'Log In'

    expect(page).to have_text I18n.t('devise.failure.invalid', authentication_keys: 'Email Address')

  end

  scenario 'User provides valid login information' do

    password = 'password'
    user = Fabricate(:user, password: password)

    visit '/'

    fill_in I18n.t('activerecord.attributes.user.email'), with: user.email
    fill_in I18n.t('activerecord.attributes.user.password'), with: password
    click_button 'Log In'

    expect(page).to have_text I18n.t('devise.sessions.signed_in')

  end

  scenario 'Logged in user Logs Out' do

    login_as Fabricate(:basic), scope: :user

    visit '/'

    click_link 'Log Out'

    expect(page).to have_text I18n.t('devise.sessions.signed_out')

  end

end