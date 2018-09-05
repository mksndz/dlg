require 'rails_helper'
require 'rake'

describe 'converts existing dcterms_provenance values to holding institutions' do
  before do
    Meta::Application.load_tasks
    Rake::Task.define_task :environment
  end
  it 'should delete the records' do
    repo = Fabricate :repository
    coll = Collection.last
    item = Item.last
    coll.holding_institutions = []
    coll.dcterms_provenance = [
      'Test Collection Provenance Value 1',
      'Test Collection Provenance Value 2'
    ]
    coll.save(validate: false)
    item.holding_institutions = []
    item.dcterms_provenance = ['Test Item Provenance Value']
    item.save(validate: false)
    expect(coll.dcterms_provenance.length).to eq 2
    Rake::Task['convert_repositories'].invoke
    his = HoldingInstitution.all.map(&:display_name)
    expect(his.count).to eq 3
    expect(his).to include repo.title
    expect(his).to include 'Test Collection Provenance Value 1'
    expect(his).to include 'Test Collection Provenance Value 2'
    expect(his).not_to include 'Test Item Provenance Value'
  end
end