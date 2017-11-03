require 'rails_helper'
require 'rake'

describe 'deletes items based on a list of record_id values in a file' do
  before do
    Meta::Application.load_tasks
    Rake::Task.define_task :environment
  end
  it 'should delete the records' do
    r = Fabricate :empty_repository, slug: 'testrepo1'
    c = Fabricate(
      :empty_collection,
      slug: 'testcoll1', repository: r, portals: r.portals
    )
    i1 = Fabricate(:item, slug: 'testitem1') do
      collection { c }
      portals { c.portals }
    end
    i2 = Fabricate(:item, slug: 'testitem2') do
      collection { c }
      portals { c.portals }
    end
    i3 = Fabricate(:item) do
      collection { c }
      portals { c.portals }
    end
    expect(i1.record_id).to eq 'testrepo1_testcoll1_testitem1'
    expect(i2.record_id).to eq 'testrepo1_testcoll1_testitem2'
    Rake::Task['delete_items'].invoke('spec/files/record_ids.txt')
    items = Item.all
    expect(items.count).to eq 1
    expect(items).not_to include i1, i2
    expect(items).to include i3
  end
end