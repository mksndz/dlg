require 'rails_helper'

RSpec.describe Subject, type: :model do
  it 'has none to begin with' do
    expect(Subject.count).to eq 0
  end

  it 'has one after adding one' do
    Fabricate(:subject)
    expect(Subject.count).to eq 1
  end

  it 'has a name' do
    s = Fabricate(:subject)
    expect(s.name).not_to be_empty
    expect(s.name).to be_a String
  end

  it 'can have Collections' do
    s = Fabricate(:subject) {
      collections(count: 1)
    }
    expect(s).to respond_to 'collections'
    expect(s.collections.first).to be_a Collection
  end

end
