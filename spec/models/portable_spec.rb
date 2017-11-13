require 'rails_helper'

describe Portable, type: :model do
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
      expect(repository.portals).not_to include portal
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
  context 'Collections' do
    let(:collection) { Fabricate :empty_collection }
    let(:portal) { Fabricate :portal }
    it 'has portals' do
      expect(collection.portals.first).to be_a Portal
      expect(collection.portals.count).to eq 1
      expect(collection.portals).to eq collection.repository.portals
    end
    it 'cannot add a portal that is not assigned to repository' do
      expect(collection.repository.portals).not_to include portal
      collection.portals << portal
      expect do
        collection.save!
      end.to raise_exception ActiveRecord::RecordInvalid, /#{I18n.t('activerecord.errors.messages.portals.parent_not_assigned')}/
    end
    context 'with extra portal assigned' do
      before :each do
        repository = collection.repository
        repository.portals << portal
        repository.save
      end
      it 'can add a portal that is assigned to parent' do
        collection.portals << portal
        expect { collection.save! }.not_to raise_exception
        expect(collection.portals).to include portal
      end
      context 'with item assigned' do
        before :each do
          collection.portals << portal
          collection.save
          collection.items << Fabricate(
            :item,
            portals: collection.portals,
            collection: collection
          )
        end
        it 'cannot remove a portal that remains assigned to any children' do
          expect do
            collection.portals.delete(portal)
          end.to raise_exception PortalError, /#{Item.last.id}/
        end
        it 'can remove a portal not assigned to any children' do
          item = Item.last
          expect(item.portals.count).to eq 2
          item.portals.delete(portal)
          expect do
            collection.portals.delete(portal)
          end.not_to raise_exception
          expect(collection.portals).not_to include portal
        end
      end

    end
  end
  context 'Items' do
    let(:item) { Fabricate(:repository).items.last }
    let(:portal) { Fabricate :portal }
    it 'has portals' do
      expect(item.portals.first).to be_a Portal
      expect(item.portals.count).to eq 1
    end
    it 'cannot add a portal that is no assigned to the parent collection' do
      item.portals << portal
      expect do
        item.save!
      end.to raise_exception ActiveRecord::RecordInvalid, /#{I18n.t('activerecord.errors.messages.portals.parent_not_assigned')}/
    end
    context 'with additional portal on parents' do
      before :each do
        repository = item.repository
        repository.portals << portal
        repository.save
        collection = item.collection
        collection.portals << portal
        collection.save
      end
      it 'can add a portal if assigned to parents' do
        item.portals << portal
        expect { item.save! }.not_to raise_exception
        expect(item.portals).to include portal
      end
      it 'can remove a portal' do
        item.portals << portal
        item.save
        expect do
          item.portals.delete(portal)
        end.not_to raise_exception
        expect(item.portals).not_to include portal
      end
    end
  end
end