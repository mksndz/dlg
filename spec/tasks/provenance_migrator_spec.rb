require 'rails_helper'
require 'rake'

describe 'migrates provenance values' do
  before do
    Meta::Application.load_tasks
    Rake::Task.define_task :environment
  end
  it 'should clean a dirty item and save only that item' do
    repo = Fabricate :repository
    coll = repo.collections.last
    Fabricate(:holding_institution, display_name: 'Value 1')
    Fabricate(:holding_institution, display_name: 'Value 2')
    item = Fabricate(
      :item,
      collection: coll,
      portals: repo.portals,
      legacy_dcterms_provenance: ['Value 1', 'Value 2', 'Bad Value']
    )
    Rake::Task['provenance_migrator'].invoke(coll.record_id)
    item.reload
    expect(item.holding_institutions.count).to eq 3
    expect(item.holding_institution_names).to include 'Value 1'
    expect(item.holding_institution_names).to include 'Value 2'
    expect(item.holding_institution_names).not_to include 'Bad Value'
  end
end