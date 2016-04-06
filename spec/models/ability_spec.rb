require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do

  let(:super_admin)        { Fabricate :super }
  let(:basic_admin)        { Fabricate :basic }
  let(:coordinator_admin)  { Fabricate :coordinator }
  let(:committer_admin)    { Fabricate :committer }

  context 'for an Admin admin' do
    
    subject { Ability.new super_admin }

    it 'can manage all things' do
      is_expected.to be_able_to :manage, :all
    end

  end
  
  context 'for a Coordinator admin' do
    
    subject { Ability.new coordinator_admin }

    it 'cannot manage all things' do
      is_expected.not_to be_able_to :manage, :all
    end

    it 'can create new Admins' do
      is_expected.to be_able_to :new, Admin.new
      is_expected.to be_able_to :create, Admin.new
    end

    it 'can modify Admins for which it is the creator' do

      admin = Fabricate :admin
      admin.creator = coordinator_admin

      is_expected.to be_able_to :edit, admin
      is_expected.to be_able_to :update, admin
      is_expected.to be_able_to :destroy, admin

    end

    it 'cannot modify Admins for which it is not the creator' do

      admin = Fabricate :admin
      other_admin = Fabricate :admin
      admin.creator = other_admin

      is_expected.not_to be_able_to :edit, admin
      is_expected.not_to be_able_to :update, admin
      is_expected.not_to be_able_to :destroy, admin

    end

  end

  context 'for a Basic admin' do

    subject { Ability.new basic_admin }

    it 'cannot manage all things' do
      is_expected.not_to be_able_to :manage, :all
    end

    context 'with Repository assigned' do
      
      let(:repository) { Fabricate :repository }

      it 'can modify but not destroy Repositories if the Repository is assigned' do
        basic_admin.repositories << repository
        is_expected.to be_able_to :show, repository
        is_expected.to be_able_to :edit, repository
        is_expected.to be_able_to :update, repository
        is_expected.not_to be_able_to :destroy, repository
      end

      it 'can modify but not destroy Collections if the Repository is assigned' do
        basic_admin.repositories << repository
        collection = repository.collections.first
        is_expected.to be_able_to :show, collection
        is_expected.to be_able_to :edit, collection
        is_expected.to be_able_to :update, collection
        is_expected.not_to be_able_to :destroy, collection
      end

      it 'can modify and destroy Items if the Repository is assigned' do
        basic_admin.repositories << repository
        collection = repository.collections.first
        item = Fabricate :item
        collection.items << item
        is_expected.to be_able_to :show, item
        is_expected.to be_able_to :edit, item
        is_expected.to be_able_to :update, item
        is_expected.to be_able_to :destroy, item
      end

      it 'cannot modify Repositories if the Repository is not assigned' do
        is_expected.not_to be_able_to :show, repository
        is_expected.not_to be_able_to :edit, repository
        is_expected.not_to be_able_to :update, repository
      end

      it 'cannot modify Collections if the Repository is not assigned' do
        collection = repository.collections.first
        is_expected.not_to be_able_to :show, collection
        is_expected.not_to be_able_to :edit, collection
        is_expected.not_to be_able_to :update, collection
      end

      it 'cannot manage Items if the Repository is not assigned' do
        collection = repository.collections.first
        item = Fabricate :item
        collection.items << item
        is_expected.not_to be_able_to :show, item
        is_expected.not_to be_able_to :edit, item
        is_expected.not_to be_able_to :update, item
        is_expected.not_to be_able_to :destroy, item
      end
      
    end

    context 'with Collection assigned' do

      let(:collection) { Fabricate :collection }

      it 'can modify Collections if the Collection is assigned' do
        basic_admin.collections << collection
        is_expected.to be_able_to :show, collection
        is_expected.to be_able_to :edit, collection
        is_expected.to be_able_to :update, collection
        is_expected.not_to be_able_to :destroy, collection
      end

      it 'can manage Items if the Collection is assigned' do
        basic_admin.collections << collection
        is_expected.to be_able_to :show, collection
        is_expected.to be_able_to :edit, collection
        is_expected.to be_able_to :update, collection
        is_expected.not_to be_able_to :destroy, collection
      end
      
      it 'cannot modify or delete Collections if the Collection is not assigned' do
        is_expected.not_to be_able_to :show, collection
        is_expected.not_to be_able_to :edit, collection
        is_expected.not_to be_able_to :update, collection
        is_expected.not_to be_able_to :destroy, collection
      end

      it 'cannot manage Items if the Collection is not assigned' do
        is_expected.not_to be_able_to :show, collection
        is_expected.not_to be_able_to :edit, collection
        is_expected.not_to be_able_to :update, collection
        is_expected.not_to be_able_to :destroy, collection
      end
      
    end

    context 'working with Batches' do

      let(:batch) { Fabricate(:batch) { batch_items(count: 1) } }

      it 'can create Batches' do
        is_expected.to be_able_to :index, batch
        is_expected.to be_able_to :new, batch
        is_expected.to be_able_to :create, batch
      end

      it 'can view and create BatchItems' do
        batch_item = batch.batch_items.first
        is_expected.to be_able_to :index, batch_item
        is_expected.to be_able_to :new, batch_item
        is_expected.to be_able_to :create, batch_item
      end

      it 'cannot view or modify Batches belonging to others' do
        other_admin = Fabricate :admin
        batch.admin = other_admin
        is_expected.not_to be_able_to :show, batch
        is_expected.not_to be_able_to :edit, batch
        is_expected.not_to be_able_to :update, batch
        is_expected.not_to be_able_to :destroy, batch
      end

      it 'cannot modify or destroy BatchItems belonging to others' do
        other_admin = Fabricate :admin
        batch.admin = other_admin
        batch_item = batch.batch_items.first
        is_expected.not_to be_able_to :edit, batch_item
        is_expected.not_to be_able_to :update, batch_item
        is_expected.not_to be_able_to :destroy, batch_item
      end

      context 'when Batch is owned by self' do

        it 'can view and modify Batch' do
          batch.admin = basic_admin
          is_expected.to be_able_to :edit, batch
          is_expected.to be_able_to :update, batch
          is_expected.to be_able_to :destroy, batch
        end

        it 'can modify and destroy BatchItems in the Batch' do
          batch.admin = basic_admin
          batch_item = batch.batch_items.first
          is_expected.to be_able_to :edit, batch_item
          is_expected.to be_able_to :update, batch_item
          is_expected.to be_able_to :destroy, batch_item
        end

      end

    end

  end

  context 'for a committer admin' do

    subject { Ability.new committer_admin }
    let(:batch) { Fabricate :batch }

    it 'can commit a batch owned by self' do
      batch.admin = committer_admin
      is_expected.to be_able_to :commit, batch
    end

    it 'cannot commit a batch not owned by self' do
      is_expected.not_to be_able_to :commit, batch
    end

  end

end