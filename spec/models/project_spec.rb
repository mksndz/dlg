require 'rails_helper'

RSpec.describe Project, type: :model do
  it 'has none to begin with' do
    expect(Project.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate :project
    expect(Project.count).to eq 1
  end
  context 'when created' do
    let(:project) { Fabricate :project }
    it 'has a title' do
      expect(project.title).not_to be_empty
      expect(project.title).to be_a String
    end
    it 'has a Holding Institution' do
      hi = Fabricate :holding_institution
      project.holding_institution = hi
      expect(project).to respond_to 'holding_institution'
      expect(project.holding_institution).to be_a HoldingInstitution
    end
    it 'has Collections' do
      collections = Fabricate.times(2, :empty_collection)
      project.collections = collections
      expect(project).to respond_to 'collections'
      expect(project.collections.count).to eq 2
      expect(project.collections.first).to be_a Collection
    end
    it 'has a decimal value for storage used' do
      expect(project.storage_used).to eq 100.5
    end
  end
  context 'when validating' do
    it 'requires a title' do
      project = Fabricate.build :project, title: nil
      project.valid?
      expect(project.errors).to have_key :title
    end
    it 'requires a holding institution' do
      project = Fabricate.build :project, holding_institution: nil
      project.valid?
      expect(project.errors).to have_key :holding_institution
    end
  end
end
