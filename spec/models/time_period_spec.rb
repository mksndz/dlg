require 'rails_helper'

RSpec.describe TimePeriod, type: :model do
  it 'has none to begin with' do
    expect(TimePeriod.count).to eq 0
  end

  it 'has one after adding one' do
    Fabricate(:time_period)
    expect(TimePeriod.count).to eq 1
  end

  it 'has a name' do
    s = Fabricate(:time_period)
    expect(s.name).not_to be_empty
    expect(s.name).to be_a String
  end

  it 'has a start' do
    s = Fabricate(:time_period)
    expect(s.start).not_to be_nil
    expect(s.start).to be_a Integer
  end

  it 'has a finish' do
    s = Fabricate(:time_period)
    expect(s.finish).not_to be_nil
    expect(s.finish).to be_a Integer
  end

  it 'can have Collections' do
    s = Fabricate(:time_period) {
      collections(count: 1)
    }
    expect(s).to respond_to 'collections'
    expect(s.collections.first).to be_a Collection
  end

end
