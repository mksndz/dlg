require 'rails_helper'

RSpec.feature 'Application' do
  scenario 'User browses to the site' do
    visit '/'
    expect(page).to have_text('User Login')
  end

  scenario 'User provides a username but no password' do
    visit '/'
    fill_in 'Email Address', with: 'blahblah@blah.org'
    click_button 'Log In'
    expect(page).to have_text('Invalid')
  end
end