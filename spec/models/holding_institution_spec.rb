require 'rails_helper'

RSpec.describe HoldingInstitution, type: :model do
  it 'has none to begin with' do
    expect(HoldingInstitution.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate :holding_institution
    expect(HoldingInstitution.count).to eq 1
  end
  context 'when created' do
    let(:holding_institution) { Fabricate :holding_institution }
    it 'has a display_name' do
      expect(holding_institution.display_name).not_to be_empty
      expect(holding_institution.display_name).to be_a String
    end
    it 'has Projects' do
      projects = Fabricate.times(2, :project)
      holding_institution.projects = projects
      expect(holding_institution).to respond_to 'projects'
      expect(holding_institution.projects.first).to be_a Project
    end
    it 'has Collections' do
      collections = Fabricate.times(2, :empty_collection)
      holding_institution.collections = collections
      expect(holding_institution).to respond_to 'collections'
      expect(holding_institution.collections.count).to eq 2
      expect(holding_institution.collections.first).to be_a Collection
    end
  end
end
