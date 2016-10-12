require 'rails_helper'

describe CollectionImporter, type: :model do

  describe '#perform' do

    RSpec::Expectations.configuration.on_potential_false_positives = :nothing

    let(:batch_import) {
      Fabricate :batch_import
    }

    context 'with valid XML' do

      before(:all) {
        Fabricate(:collection) {
          slug { '0091' } # to make the test xml valid
        }
      }

      it 'should create a BatchItem' do

        expect{
          RecordImporter.perform(batch_import)
        }.to change(BatchItem, :count).by(1)

      end
      
    end

    context 'with valid XML but no existing collection' do

      it 'should raise an exception' do

        expect{
          RecordImporter.perform(batch_import)
        }.to change(BatchItem, :count).by(0)

      end

    end

  end

end