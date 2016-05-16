require 'rails_helper'

feature 'Logging In and Out' do

  scenario 'User browses to the site is presented with a login form' do

    visit '/'

    expect(page).to have_text('User Login')

  end

  scenario 'User provides a username but no password' do

    visit '/'

    fill_in 'Email Address', with: 'blahblah@blah.org'
    click_button 'Log In'

    expect(page).to have_text('Invalid')

  end

  scenario 'User provides valid login information' do

    password = 'password'
    user = Fabricate(:user, password: password)

    visit '/'

    fill_in 'Email Address', with: user.email
    fill_in 'Password', with: password
    click_button 'Log In'

    expect(page).to have_text 'Log Out'

  end

end