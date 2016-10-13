require 'rails_helper'

describe RecordImporter, type: :model do

  describe '#perform' do

    RSpec::Expectations.configuration.on_potential_false_positives = :nothing


    context 'with valid XML' do

      let(:batch_import) {
        Fabricate :batch_import
      }

      context 'with valid XML' do

        before(:each) {
          Fabricate(:collection) {
            slug { '0091' } # to make the test xml fully valid
          }
        }

        it 'should create a BatchItem and update BatchImport appropriately' do

          expect{
            RecordImporter.perform(batch_import)
          }.to change(BatchItem, :count).by(1)

          expect(batch_import.results['added'].length).to eq 1
          expect(batch_import.results['updated'].length).to eq 0
          expect(batch_import.results['failed'].length).to eq 0
        end

      end

      context 'with valid XML but no existing collection' do

        it 'should not create a BatchItem' do

          expect{
            RecordImporter.perform(batch_import)
          }.to change(BatchItem, :count).by(0)

        end

      end

    end

    context 'with unparseable xml' do

      let(:batch_import) {
        Fabricate(:batch_import) {
          xml { '
            <items><item>M</zzz>
          ' }
        }
      }

      it 'should raise a JobFailedError' do

        expect{
          RecordImporter.perform(batch_import)
        }.to raise_error JobFailedError

      end

    end

    context 'with xml with no item nodes' do

      let(:batch_import) {
        Fabricate(:batch_import) {
          xml { '
            <items><collection><slug>blah</slug></collection></items>
          ' }
        }
      }

      it 'should raise a JobFailedError' do

        expect{
          RecordImporter.perform(batch_import)
        }.to raise_error JobFailedError

      end

    end

  end

end