require 'rails_helper'

RSpec.describe Feature, type: :model do
  it 'has none to begin with' do
    expect(Feature.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate(:feature)
    expect(Feature.count).to eq 1
  end
  context 'when created' do
    let(:feature) { Fabricate :feature }
  end
end
