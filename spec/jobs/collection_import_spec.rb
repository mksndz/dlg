require 'rails_helper'

describe CollectionImporter, type: :model do

  describe '#perform' do

    let(:collection) {
      Fabricate :collection
    }
    
    context 'with an invalid collection_id' do
      
      it 'should raise a JobFailedError' do
        
        expect{
          CollectionImporter.perform('Z','foo')
        }.to raise_error JobFailedError
        
      end
      
    end
    
    context 'with an invalid xml url' do
      
      let(:bad_url) {
        'zzz://web.page'
      }
      
      it 'should not raise a JobFailedError' do
        
        expect{
          CollectionImporter.perform(collection.id, bad_url)
        }.not_to raise_error JobFailedError
        
      end
      
    end
    
    context 'with a url that leads to invalid xml' do

      let(:bad_xml) {
        'http://dlg.galileo.usg.edu/robots.txt'
      }

      it 'should throw a JobFailedError if the passed xml_items_url provides bad xml' do

        expect{
          CollectionImporter.perform(collection.id, bad_xml)
        }.to raise_error JobFailedError

      end

    end

    context 'with a valid url, valid xml, but a Collection that already has Items' do

      let(:populated_collection) {
        Fabricate(:collection){
          items(count:1)
        }
      }

      let(:good_xml) {
        # 'http://dlg.galileo.usg.edu/xml/dcq/cviog_gainfo.xml'
        'http://dlg.galileo.usg.edu/xml/dcq/aarl_bss.xml'
      }

      it 'should return true' do

        expect(CollectionImporter.perform(populated_collection.id, good_xml)).to be true

      end

    end


    context 'with a valid url, valid xml, and an empty Collection' do

      let(:good_xml) {
        'http://dlg.galileo.usg.edu/xml/dcq/cviog_gainfo.xml'
      }

      let(:collection_item_count) { 1 }

      it 'should not raise any kind of exception' do

        expect{
          CollectionImporter.perform(collection.id, good_xml)
        }.not_to raise_exception

      end

      it 'should populate collection with Items' do

        expect{
            CollectionImporter.perform(collection.id, good_xml)
        }.to change(collection.items, :count).by(collection_item_count)

      end

    end
    
  end

end