require 'rails_helper'

RSpec.describe BatchItem, type: :model do

  it 'has none to begin with' do
    expect(BatchItem.count).to eq 0
  end

  it 'has one after adding one' do
    Fabricate(:batch_item)
    expect(BatchItem.count).to eq 1
  end
  it 'has a Batch' do
    b = Fabricate(:batch)
    expect(b.batch_items.first.batch).to be_kind_of Batch
  end

  it 'has a String title' do
    b = Fabricate(:batch)
    expect(b.batch_items.first.title).to be_kind_of String
  end

  it 'has a slug' do
    b = Fabricate(:batch)
    expect(b.batch_items.first.slug).not_to be_empty
  end

  it 'is not an Item' do
    b = Fabricate(:batch)
    expect(b.batch_items.first).not_to be_kind_of Item
  end

end
