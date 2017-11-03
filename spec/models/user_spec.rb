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
end
