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

  it 'commits the batch and saves itself with results as JSON' do
    b = Fabricate(:batch){ batch_items(count: 2)}
    b.commit
    expect(b).to be_persisted
    expect(b.commit_results).to be_a Hash
    expect(b.commit_results['items']).to be_an Array
    expect(b.commit_results['items'].first).to be_a Hash
  end

  it 'commits the batch and saves itself with results as JSON including errors' do
    b = Fabricate(:batch){ batch_items(count: 2)}
    bi = b.batch_items.first
    bi.update_attributes(slug: nil) # update record so that it will error
    b.commit
    error = b.commit_results['errors'].first
    expect(error['batch_item']).to be_a Integer
    expect(error['errors']).to be_a Hash
  end

  it 'recreates itself as a fresh batch referencing the current state of Items' do
    b = Fabricate(:batch){ batch_items(count: 2)}
    b.commit
    recreated = b.recreate
    expect(recreated.batch_items.length).to eq b.batch_items.length
    expect(recreated.batch_items.first.slug).to eq b.batch_items.first.slug
    expect(recreated.batch_items.first.item).to be_an Item
  end
end
