require 'rails_helper'
require 'rake'

describe 'deletes items based on a list of record_id values in a file' do

  before do
    Meta::Application.load_tasks
    Rake::Task.define_task :environment
  end

  it 'should delete the records' do

    i1 = Fabricate(:item) do
      slug { 'testitem1' }
      collection do
        Fabricate(:collection) do
          slug { 'testcoll1' }
          repository { Fabricate(:repository) { slug { 'testrepo1' } } }
        end
      end
    end

    i2 = Fabricate(:item) do
      slug { 'testitem2' }
      collection do
        Fabricate(:collection) do
          slug { 'testcoll2' }
          repository { Fabricate(:repository) { slug { 'testrepo2' } } }
        end
      end
    end

    i3 = Fabricate :item

    expect(i1.record_id).to eq 'testrepo1_testcoll1_testitem1'
    expect(i2.record_id).to eq 'testrepo2_testcoll2_testitem2'

    Rake::Task['delete_items'].invoke('spec/files/record_ids.txt')

    items = Item.all
    expect(items.count).to eq 1
    expect(items).not_to include i1, i2
    expect(items).to include i3

  end

end