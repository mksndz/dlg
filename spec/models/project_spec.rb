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
      expect(project).to respond_to 'holding_institution'
      # expect(project.repository).to be_a Repository
    end
  end
end
