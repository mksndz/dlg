require 'rails_helper'

describe BatchCommitter, type: :model do

  describe '#perform' do

    context 'with a batch with no batch_items' do

      let(:batch) {
        Fabricate :batch
      }

      it 'should raise a JobFailedError' do
        
        expect{
          BatchCommitter.perform(batch.id)
        }.to raise_error JobFailedError
        
      end
      
    end
    
    context 'with a batch with invalid batch_items' do

      it 'should raise a JobFailedError' do

        batch = Fabricate.build(:batch) {
          batch_items { [Fabricate(:batch_item) {
            dcterms_type { [] }
          }]}
        }

        batch.save(validate: false)

        expect{
          BatchCommitter.perform(batch.id)
        }.to raise_error JobFailedError
        
      end
      
    end
    
    context 'with valid batch_items' do

      let(:batch) {
        Fabricate(:batch) {
          batch_items(count: 2)
        }
      }

      it 'should commit the Batch' do

        BatchCommitter.perform(batch.id)

        batch.reload

        results = batch.commit_results

        expect(results).not_to be_empty

      end

    end

    context 'with a mix of valid and invalid batch_items' do

      let(:batch) do
        Fabricate(:batch) { batch_items(count: 3) }
      end

      it 'should commit the Batch' do

        item = Fabricate :item

        batch.batch_items.last.dc_date = [] # validation error
        batch.batch_items.last.save(validate: false)

        batch.batch_items.first.item = item # update existing item
        batch.batch_items.first.save

        BatchCommitter.perform(batch.id)

        batch.reload

        results = batch.commit_results

        expect(results['errors']).not_to be_empty
        expect(results['items']).not_to be_empty
        expect(results['items'][0]['item_updated']).to be_truthy
        expect(results['items'][0]['item']).to eq item.id
        expect(results['items'][1]['item_updated']).to be_falsey
        expect(results['errors'][0]['errors']).not_to be_empty
        expect(results['errors'][0]['errors'].length).to eq 1

      end

    end

  end

end