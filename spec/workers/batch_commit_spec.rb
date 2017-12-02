require 'rails_helper'

describe BatchCommitter, type: :model do
  describe '#perform' do
    context 'with a batch with no batch_items' do
      let(:batch) { Fabricate :batch }
      it 'should fail silently and add job message' do
        BatchCommitter.perform batch.id
        batch.reload
        expect(batch.job_message).not_to be_nil
        expect(batch.queued_for_commit_at).to be_nil
      end
    end
    context 'with a defunct batch_id' do
      it 'should raise JobFailedError' do
        expect do
          BatchCommitter.perform 0
        end.to raise_error JobFailedError
      end
    end
    context 'with valid batch_items' do
      let(:batch) { Fabricate(:batch) { batch_items(count: 2) } }
      it 'should commit the Batch' do
        BatchCommitter.perform(batch.id)
        batch.reload
        results = batch.commit_results
        expect(results).not_to be_empty
      end
    end
    context 'with an invalid batch_item' do
      let(:batch) { Fabricate(:batch) { batch_items(count: 2) } }
      it 'should fail to commit the Batch' do
        batch.batch_items.last.dc_date = [] # validation error
        batch.batch_items.last.save(validate: false)
        BatchCommitter.perform(batch.id)
        batch.reload
        expect(batch.job_message).not_to be_nil
        expect(batch.committed?).to eq nil
      end
    end
    context 'with a batch_items that will update an existing item' do
      let(:batch) { Fabricate(:batch) { batch_items(count: 1) } }
      it 'should commit the Batch and set the item relation' do
        item = Fabricate(:repository).items.first
        batch_item = batch.batch_items.first
        batch_item.item = item # update existing item
        batch_item.collection = item.collection
        batch_item.portals = item.portals
        batch_item.save
        with_versioning do
          BatchCommitter.perform(batch.id)
        end
        batch.reload
        results = batch.commit_results
        expect(results['items']).not_to be_empty
        expect(results['items'][0]['item_updated']).to be_truthy
        expect(results['items'][0]['item']).to eq item.id
        expect(item.paper_trail.previous_version).to be_truthy
      end
    end
  end
end