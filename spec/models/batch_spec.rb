require 'rails_helper'

RSpec.describe Batch, type: :model do

  it 'has none to begin with' do
    expect(Batch.count).to eq 0
  end

  it 'has one after adding one' do
    Fabricate(:batch)
    expect(Batch.count).to eq 1
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

  it 'commits the batch_items return array of results' do
    b = Fabricate(:batch){ batch_items(count: 2)}
    r = b.commit
    expect(r).to be_an Array
    expect(r.first).to be_a Hash
    expect(r.first[:batch_item]).to be_a BatchItem
    expect(r.first[:item]).to be_a Item
    expect(b.committed_at).to be
  end
end
