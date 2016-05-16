require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Users Management' do

  let(:super_user) { Fabricate :super }
  let(:basic_user) { Fabricate :basic}
  let(:coordinator_user) { Fabricate :coordinator }

  scenario 'Super User sees an list of all Users on index' do

    login_as super_user, scope: :user

    users = Fabricate.times(10, :user)

    visit users_path

    users.each do |user|
      expect(page).to have_text user.email
    end

  end

  scenario 'Coordinator User sees an list of only their created Users on index' do

    login_as coordinator_user, scope: :user

    user1 = Fabricate(:user, creator: coordinator_user)
    user2 = Fabricate(:user)

    visit users_path

    expect(page).to have_text user1.email
    expect(page).not_to have_text user2.email

  end

  scenario 'Basic User cannot administer any user stuff' do

  end

  scenario 'User index page shows Role names, Email and Action buttons' do

  end

end