require 'rails_helper'

RSpec.describe User, type: :model do

  it 'has none to begin with' do
    expect(User.count).to eq 0
  end

  it 'has one after adding one' do
    Fabricate(:user)
    expect(User.count).to eq 1
  end

  it 'has a String email' do
    r = Fabricate(:user)
    expect(r.email).to be_kind_of String
  end

  it 'has an Array of Roles' do
    r = Fabricate(:user) {
      roles(count: 2)
    }
    expect(r.roles.first).to be_kind_of Admin::Role
  end

end
