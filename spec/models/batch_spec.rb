require 'rails_helper'

RSpec.describe Batch, type: :model do
  it 'has none to begin with' do
    expect(Batch.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate(:batch)
    expect(Batch.count).to eq 1
  end
  context'when created' do
    let(:batch) { Fabricate :batch }
    it 'has a String name' do
      expect(batch.name).to be_kind_of String
    end
    it 'has a User' do
      expect(batch.user).to be_kind_of User
    end
    it 'responds with false for commit status when batch is not committed' do
      expect(batch.committed?).to be_falsey
    end
    it 'responds with true for commit status when batch has been committed' do
      batch.committed_at = Time.now
      expect(batch.committed?).to be_truthy
    end
    it 'responds with boolean for pending status' do
      batch.queued_for_commit_at = Time.now
      expect(batch.pending?).to be true
    end
    it 'responds with boolean for pending status after batch is committed' do
      batch.queued_for_commit_at = Time.now
      batch.committed_at = Time.now
      expect(batch.pending?).to be false
      expect(batch.committed?).to be_truthy
    end
    context 'with BatchItems' do
      before :each do
        batch.batch_items << Fabricate.build(:batch_item_without_batch)
      end
      it 'contains BatchItems' do
        expect(batch.batch_items).not_to be_empty
      end
      it 'responds with false for has invalid batch items status when all batch
          items are valid' do
        expect(batch.invalid_batch_items?).to be false
      end
      it 'responds with true for has_invalid_ batch_items status at least one
          batch_item is not valid' do
        i = batch.batch_items.first
        i.dc_date = []
        i.save(validate: false)
        expect(batch.invalid_batch_items?).to be true
      end
      it 'commits the batch and saves itself with results as JSON' do
        batch.commit
        expect(batch).to be_persisted
        expect(batch.commit_results).to be_a Hash
        expect(batch.commit_results['items']).to be_an Array
        expect(batch.commit_results['items'].first).to be_a Hash
      end
      it 'recreates itself as a fresh batch referencing the current state of
          Items' do
        batch.commit
        recreated = batch.recreate
        expect(recreated.batch_items.length).to eq batch.batch_items.length
        expect(recreated.batch_items.first.slug).to eq batch.batch_items.first.slug
        expect(recreated.batch_items.first.item).to be_an Item
      end
    end
  end
end
