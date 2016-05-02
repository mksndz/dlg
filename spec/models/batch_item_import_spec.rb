require 'rails_helper'

RSpec.describe BatchItemImport, type: :model do

  let(:collection){
    Fabricate(:collection){
      items(count: 1)
    }
  }

  let(:batch) {
    Fabricate(:batch)
  }

  let(:xml_text) {
    collection.items.first.to_xml
  }

  it 'creates a BatchItem with an associated Item' do
    batch_item = BatchItemImport.new(xml_text, batch, true).process
    expect(batch_item).to be_a BatchItem
    expect(batch_item.item).to be_a Item
  end

  it 'creates a BatchItem without an associated Item' do
    hash = collection.items.first.attributes
    hash.delete('id')
    new_item = Item.new(hash)
    batch_item = BatchItemImport.new(new_item.to_xml, batch, true).process
    expect(batch_item).to be_a BatchItem
    expect(batch_item.item).to be_nil
  end

  it 'throws an exception if xml is invalid' do
    expect { BatchItemImport.new('gibberish', batch, true) }.to raise_error(ImportFailedError, /invalid/)
  end

  it 'throws an exception if the replace item id is not found' do
    hash = collection.items.first.attributes
    collection.items.first.destroy
    new_item = Item.new(hash)
    batch_item_importer = BatchItemImport.new(new_item.to_xml, batch, true)
    expect { batch_item_importer.process }.to raise_error(ImportFailedError, /not be found/)
  end

end