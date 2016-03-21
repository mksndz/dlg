require 'rails_helper'

RSpec.describe Admin::Batch, type: :model do

  it 'has none to begin with' do
    expect(Admin::Batch.count).to eq 0
  end

  it 'has one after adding one' do
    Fabricate(:batch)
    expect(Admin::Batch.count).to eq 1
  end

  it 'has a String name' do
    b = Fabricate(:batch)
    expect(b.name).to be_kind_of String
  end

  it 'has a User' do
    b = Fabricate(:batch)
    expect(b.user).to be_kind_of User
  end

  it 'contains BatchWorks' do
    b = Fabricate(:batch) {
      batch_items(count: 1)
    }
    expect(b.batch_items).not_to be_empty
  end
  
end
