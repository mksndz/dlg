require 'rails_helper'

RSpec.describe Meta::Role, type: :model do

  it 'has none to begin with' do
    expect(Meta::Role.count).to eq 0
  end

  it 'has one after adding one' do
    Fabricate(:role)
    expect(Meta::Role.count).to eq 1
  end

  it 'has a String name' do
    r = Fabricate(:role)
    expect(r.name).to be_kind_of String
  end

  it 'has an Array of Users' do
    r = Fabricate(:role) {
      users(count: 2) { Fabricate(:user) }
    }
    expect(r.users.first).to be_kind_of User
  end

end
