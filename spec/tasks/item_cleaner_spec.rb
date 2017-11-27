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
  it 'should clean an item and save' do
    Rake::Task['clean_all_items'].invoke
    expect(Item.last.dcterms_description.first).to eq "Blah\nblah (link@mclink.org)\nBLAH"
  end
  it 'should change nothing is dry_run flag is true' do
    Rake::Task['clean_all_items'].invoke true
    expect(Item.last.dcterms_description.first).to eq 'Blah<br><a href="mailto:link@mclink.org"><b>blah</b></a><BR/>BLAH'
  end
end