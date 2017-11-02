require 'rails_helper'

RSpec.describe TimePeriod, type: :model do
  it 'has none to begin with' do
    expect(TimePeriod.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate(:time_period)
    expect(TimePeriod.count).to eq 1
  end
  context 'when created' do
    before :each do
      @time_period = Fabricate :time_period
    end
    it 'has a name' do
      expect(@time_period.name).not_to be_empty
      expect(@time_period.name).to be_a String
    end
    it 'has a start' do
      expect(@time_period.start).not_to be_nil
      expect(@time_period.start).to be_a Integer
    end
    it 'has a finish' do
      expect(@time_period.finish).not_to be_nil
      expect(@time_period.finish).to be_a Integer
    end
    it 'can have Collections' do
      Fabricate :repository
      Collection.last.time_periods << @time_period
      expect(@time_period).to respond_to 'collections'
      expect(@time_period.collections.first).to be_a Collection
    end
  end
end
