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

  end

end