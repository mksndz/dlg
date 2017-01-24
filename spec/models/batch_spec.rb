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

  it 'responds with false for commit status when batch is not committed' do
    b = Fabricate :batch
    expect(b.committed?).to be false
  end

  it 'responds with true for commit status when batch has been committed' do
    b = Fabricate :batch
    b.committed_at = Time.now
    expect(b.committed?).to be true
  end

  it 'responds with boolean for pending status' do
    b = Fabricate :batch
    b.queued_for_commit_at = Time.now
    expect(b.pending?).to be true
  end

  it 'responds with false for has invalid batch items status when all batch_items are valid' do
    b = Fabricate(:batch) { batch_items(count: 2) }
    expect(b.has_invalid_batch_items?).to be false
  end

  it 'responds with true for has_invalid_ batch_items status at least one batch_item is not valid' do
    b = Fabricate(:batch) { batch_items(count: 2) }
    i = b.batch_items.first
    i.dc_date = []
    i.save(validate: false)
    expect(b.has_invalid_batch_items?).to be true
  end

  it 'responds with boolean for pending status after batch is committed' do
    b = Fabricate :batch
    b.queued_for_commit_at = Time.now
    b.committed_at = Time.now
    expect(b.pending?).to be false
    expect(b.committed?).to be true
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
    b = Fabricate(:batch){ batch_items(count: 1)}
    b.commit
    recreated = b.recreate
    expect(recreated.batch_items.length).to eq b.batch_items.length
    expect(recreated.batch_items.first.slug).to eq b.batch_items.first.slug
    expect(recreated.batch_items.first.item).to be_an Item
  end
end
