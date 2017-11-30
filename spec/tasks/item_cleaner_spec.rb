require 'rails_helper'
require 'rake'

describe 'cleans items' do
  before do
    Meta::Application.load_tasks
    Rake::Task.define_task :environment
    Fabricate :repository
  end
  before :each do
    collection = Fabricate :empty_collection
    Fabricate(:item,
              collection: collection,
              portals: collection.portals) do
      dcterms_description ['Blah<br><a href="mailto:link@mclink.org"><b>blah</b></a><BR/>BLAH']
    end
  end
  it 'should clean a dirty item and save only that item' do
    item = Item.last
    item_updated = item.updated_at
    other_item = Fabricate(:item,
                           collection: item.collection,
                           portals: item.collection.portals)
    other_item_updated = other_item.updated_at
    Rake::Task['clean_all_items'].invoke
    item.reload
    expect(item.dcterms_description.first).to eq "Blah\nblah (link@mclink.org)\nBLAH"
    expect(item.updated_at).not_to eq item_updated
    expect(other_item.updated_at).to eq other_item_updated
  end
  it 'should change nothing is dry_run flag is true' do
    Rake::Task['clean_all_items'].invoke true
    expect(Item.last.dcterms_description.first).to eq 'Blah<br><a href="mailto:link@mclink.org"><b>blah</b></a><BR/>BLAH'
  end
end