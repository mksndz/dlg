require 'rails_helper'

RSpec.describe Meta::Batch, type: :model do

  it 'has none to begin with' do
    expect(Meta::Batch.count).to eq 0
  end

  it 'has one after adding one' do
    Fabricate(:batch)
    expect(Meta::Batch.count).to eq 1
  end

  it 'has a String name' do
    b = Fabricate(:batch)
    expect(b.name).to be_kind_of String
  end

  it 'has an Admin' do
    b = Fabricate(:batch)
    expect(b.admin).to be_kind_of Admin
  end

  it 'contains BatchWorks' do
    b = Fabricate(:batch) {
      batch_items(count: 1)
    }
    expect(b.batch_items).not_to be_empty
  end
  
end
