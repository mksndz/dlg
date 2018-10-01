require 'rails_helper'
require 'rake'

describe 'task to fix messy hi to repo relation' do
  before do
    Meta::Application.load_tasks
    Rake::Task.define_task :environment
  end
  it 'should set a relation for each repo to the corresponding holding inst' do
    r1 = Fabricate :repository
    r2 = Fabricate :repository
    hi1 = Fabricate(:holding_institution, display_name: r1.title)
    hi2 = Fabricate(:holding_institution, display_name: r2.title)
    hi3 = Fabricate :holding_institution
    hi4 = Fabricate :holding_institution
    r1.holding_institutions << hi1
    r1.holding_institutions << hi3
    r2.holding_institutions << hi2
    r2.holding_institutions << hi4
    Rake::Task['fix_hi_repo_relations'].invoke
    r1.reload
    r2.reload
    expect(r1.holding_institutions).to include hi1
    expect(r1.holding_institutions).not_to include hi3
    expect(r2.holding_institutions).to include hi2
    expect(r2.holding_institutions).not_to include hi4
  end
end