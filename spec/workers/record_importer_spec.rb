require 'rails_helper'

describe RecordImporter, type: :model do

  describe '#perform' do

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

        it 'should create a BatchItem' do

          expect{
            RecordImporter.perform(batch_import.id)
          }.to change(BatchItem, :count).by(1)

        end

        it 'should update BatchImport results appropriately' do

          RecordImporter.perform(batch_import.id)

          expect(
              batch_import.reload.results['added'].length
          ).to eq 1

        end

      end

      context 'with valid XML but no existing collection' do

        it 'should not create a BatchItem' do

          expect{
            RecordImporter.perform(batch_import.id)
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

      it 'should store a verbose error in results saying the XML could not be parsed' do

        RecordImporter.perform(batch_import.id)

        expect(
            batch_import.reload.results['failed'][0]['message']
        ).to eq 'XML could not be parsed, probably due to invalid XML format.'

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

      it 'should store a verbose error in results saying no records found' do

        RecordImporter.perform(batch_import.id)

        expect(
            batch_import.reload.results['failed'][0]['message']
        ).to eq 'No records could be extracted from the XML'

      end

    end

  end

end