require 'rails_helper'

describe CollectionImporter, type: :model do

  describe '#perform' do

    RSpec::Expectations.configuration.on_potential_false_positives = :nothing

    let(:collection) { Fabricate :collection }

    context 'with an invalid collection_id' do

      it 'should raise a JobFailedError' do

        expect do
          CollectionImporter.perform('Z','foo')
        end.to raise_exception JobFailedError

      end

    end

    context 'with an invalid xml url' do

      let(:bad_url) { 'zzz://web.page' }

      it 'should not raise a JobFailedError' do

        expect do
          CollectionImporter.perform(collection.id, bad_url)
        end.not_to raise_exception

      end

    end

    context 'with a url that leads to invalid xml' do

      let(:bad_xml) { 'http://dlg.galileo.usg.edu/robots.txt' }

      it 'should throw a JobFailedError if the passed xml_items_url provides bad xml' do

        expect do
          CollectionImporter.perform(collection.id, bad_xml)
        end.to raise_exception

      end

    end

    context 'with a valid url, valid xml, but a Collection that already has Items' do

      let(:populated_collection) { Fabricate(:collection){ items(count: 1) } }

      let(:good_xml) { 'http://dlg.galileo.usg.edu/xml/dcq/aarl_bss.xml' }

      it 'should return true' do

        expect(
          CollectionImporter.perform(
            populated_collection.id,
            good_xml))
          .to be true

      end

    end


    context 'with a valid url, valid xml, and an empty Collection' do

      let(:good_xml) { 'http://dlg.galileo.usg.edu/xml/dcq/cviog_gainfo.xml' }

      let(:collection_item_count) { 1 }

      it 'should not raise any kind of exception' do

        expect do
          CollectionImporter.perform(collection.id, good_xml)
        end.not_to raise_exception

      end

      it 'should populate collection with Items' do

        expect do
          CollectionImporter.perform(collection.id, good_xml)
        end.to change(collection.items, :count).by(collection_item_count)

      end

    end

  end

end