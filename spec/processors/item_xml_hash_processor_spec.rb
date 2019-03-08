require 'rails_helper'

RSpec.describe ItemXmlHashProcessor, type: :model do
  let(:job) { Fabricate :batch_import }

  it 'properly translates ID value' do
    hash = { 'id' => '1' }
    expect(
      ItemXmlHashProcessor.new(hash).convert
    ).to eq('item_id' => '1')
  end

  context 'for Item database ID' do
    it 'properly sets the item_id attribute' do
      hash = { 'id' => 1 }
      expect(
        ItemXmlHashProcessor.new(hash).convert
      ).to eq('item_id' => 1)
    end
  end

  context 'for collection data' do
    it 'properly translates Collection Record ID value' do
      collection = Fabricate :empty_collection
      hash = { 'collection' => { 'record_id' => collection.record_id } }
      expect(
        ItemXmlHashProcessor.new(hash).convert
      ).to eq('collection_id' => collection.id)
    end
    it 'raises an error if collection is not found' do
      hash = { 'collection' => { 'record_id' => 'a_b' } }
      expect do
        ItemXmlHashProcessor.new(hash).convert
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context 'for portal values' do
    it 'properly translates portal code values to database ids' do
      portal1 = Fabricate :portal
      portal2 = Fabricate :portal
      hash = { 'portals' => [
        { 'code' => portal1.code }, { 'code' => portal2.code }
      ] }
      expect(
        ItemXmlHashProcessor.new(hash).convert
      ).to eq('portal_ids' => [portal1.id, portal2.id])
    end
    it 'raises an error if any portals cannot be found' do
      portal = Fabricate :portal
      hash = { 'portals' => [
        { 'code' => portal.code }, { 'code' => 'quux' }
      ] }
      expect do
        ItemXmlHashProcessor.new(hash).convert
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context 'for other_coll values' do
    it 'properly looks up and translates values' do
      collection1 = Fabricate :empty_collection
      collection2 = Fabricate :empty_collection
      hash = { 'other_colls' => [
        { 'record_id' => collection1.record_id },
        { 'record_id' => collection2.record_id }
      ] }
      expect(
        ItemXmlHashProcessor.new(hash).convert
      ).to eq('other_collections' => [collection1.id, collection2.id])
    end
    it 'raises an error if any Collections cannot be found' do
      collection = Fabricate :empty_collection
      hash = { 'other_colls' => [
        { 'record_id' => collection.record_id }, { 'record_id' => 'foo_bar' }
      ] }
      expect do
        ItemXmlHashProcessor.new(hash).convert
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context 'for dcterms_provenance values' do
    it 'properly looks up and translates values' do
      hi1 = Fabricate :holding_institution
      hi2 = Fabricate :holding_institution
      hash = { 'dcterms_provenance' =>
                 [hi1.authorized_name, hi2.authorized_name] }
      expect(
        ItemXmlHashProcessor.new(hash).convert
      ).to eq('holding_institution_ids' => [hi1.id, hi2.id])
    end
    it 'raises an error if any Holding Institutions cannot be found' do
      hi = Fabricate :holding_institution
      hash = { 'dcterms_provenance' =>
                 [hi.authorized_name, 'MK Institute for Advanced Study'] }
      expect do
        ItemXmlHashProcessor.new(hash).convert
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end
end