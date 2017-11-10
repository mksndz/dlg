require 'rails_helper'

describe Portable, type: :model do
  before :each do
    @repository = Fabricate :repository
    @portal = @repository.portals.last
  end
  context 'Repositories' do
    let(:repository) { Fabricate :repository }
    let(:portal) { Fabricate(:portal) }
    it 'has portals' do
      expect(repository.portals.first).to be_a Portal
      expect(repository.portals.count).to eq 1
    end
    it 'can add a portal' do
      repository.portals << portal
      expect(repository.portals).to include portal
      expect(repository.portals.count).to eq 2
    end
    it 'can remove a portal not assigned to any children' do
      repository.portals << portal
      expect do
        repository.portals.delete(portal)
      end.not_to raise_exception
    end
    it 'cannot remove all portals' do
      repository.collections.destroy_all
      repository.portals = []
      expect do
        repository.save!
      end.to raise_exception ActiveRecord::RecordInvalid
    end
    it 'cannot remove a portal unless no child is assigned to that portal' do
      repository.portals << portal
      expect do
        repository.portals.delete(Item.last.portals.last)
      end.to raise_exception PortalError, /#{Collection.last.id}/
    end
  end
end