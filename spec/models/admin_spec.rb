require 'rails_helper'

RSpec.describe Admin, type: :model do

  it 'has none to begin with' do
    expect(Admin.count).to eq 0
  end

  it 'has one after adding one' do
    Fabricate(:admin)
    expect(Admin.count).to eq 1
  end

  it 'has a String email' do
    r = Fabricate(:admin)
    expect(r.email).to be_kind_of String
  end

  it 'has an Array of Roles' do
    r = Fabricate(:admin) {
      roles(count: 2)
    }
    expect(r.roles.first).to be_kind_of Role
  end

end
