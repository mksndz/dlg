require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  let(:super_user) { Fabricate :super }
  let(:basic_user) { Fabricate :basic }
  let(:coordinator_user) { Fabricate :coordinator }
  let(:coordinator_committer_user) { Fabricate :coordinator_committer }
  let(:committer_user) { Fabricate :committer }
  let(:uploader_user) { Fabricate :uploader }
  let(:viewer_user) { Fabricate :viewer }
  let(:pm_user) { Fabricate :pm }
  # let(:page_ingester_user) { Fabricate :page_ingester }
  let(:fulltext_ingester_user) { Fabricate :fulltext_ingester }

  context 'for a Super user' do
    subject { Ability.new super_user }
    it 'can manage all things' do
      is_expected.to be_able_to :manage, :all
    end
  end
  context 'for a Viewer user' do
    subject { Ability.new viewer_user }
    it 'can index and show items, collections and repositories' do
      is_expected.to be_able_to :index, Item
      is_expected.to be_able_to :show,  Item
      is_expected.to be_able_to :index, Collection
      is_expected.to be_able_to :show,  Collection
      is_expected.to be_able_to :index, Repository
      is_expected.to be_able_to :show,  Repository
    end
  end
  context 'for a Project Manager user' do
    subject { Ability.new pm_user }
    it 'can manage Projects' do
      is_expected.to be_able_to :manage, Project
    end
  end
  context 'for a Fulltext Ingester user' do
    subject { Ability.new fulltext_ingester_user }
    it 'can manage Fulltext Ingests' do
      is_expected.to be_able_to :manage, FulltextIngest
    end
  end
  # context 'for a Page Ingester user' do
  #   subject { Ability.new page_ingester_user }
  #   it 'can manage Page Ingests' do
  #     is_expected.to be_able_to :manage, PageIngest
  #   end
  # end
  context 'for a Coordinator user' do
    subject { Ability.new coordinator_user }
    it 'cannot manage all things' do
      is_expected.not_to be_able_to :manage, :all
    end
    it 'can create new Users' do
      is_expected.to be_able_to :new, User.new
      is_expected.to be_able_to :create, User.new
    end
    it 'can modify Users for which it is the creator' do
      user = Fabricate :user
      user.creator = coordinator_user
      is_expected.to be_able_to :edit, user
      is_expected.to be_able_to :update, user
      is_expected.to be_able_to :destroy, user
    end
    it 'cannot modify Users for which it is not the creator' do
      user = Fabricate :user
      other_user = Fabricate :user
      user.creator = other_user
      is_expected.not_to be_able_to :edit, user
      is_expected.not_to be_able_to :update, user
      is_expected.not_to be_able_to :destroy, user
    end
    context 'working with Batches' do
      let :user do
        user = Fabricate :user
        user.creator = coordinator_user
      end
      it 'can view, modify and delete Batches created by users they manage' do
        batch = Fabricate :batch
        batch.user = user
        is_expected.to be_able_to :show, batch
        is_expected.to be_able_to :edit, batch
        is_expected.to be_able_to :update, batch
        is_expected.to be_able_to :destroy, batch
      end
    end
  end
  context 'for a coordinator committer' do
    subject { Ability.new coordinator_committer_user }
    context 'working with Batches' do
      let(:user) { Fabricate :user, creator: coordinator_committer_user }
      let(:batch) { Fabricate :batch, user: user }
      let(:other_batch) { Fabricate :batch }
      it 'can commit batches created by created users' do
        is_expected.to be_able_to :commit, batch
      end
      it 'cannot commit batches from non-created users' do
        is_expected.not_to be_able_to :commit, other_batch
      end
    end
  end
  context 'for a Basic user' do
    subject { Ability.new basic_user }
    it 'cannot manage all things' do
      is_expected.not_to be_able_to :manage, :all
    end
    it 'cannot do fulltext ingests' do
      is_expected.not_to be_able_to :manage, FulltextIngest
    end
    context 'Holding Institutions' do
      let(:holding_institution) { Fabricate :holding_institution }
      it 'can view Holding Institution info' do
        is_expected.to be_able_to :index, HoldingInstitution
        is_expected.to be_able_to :show, holding_institution
      end
      it 'cannot modify Holding Institutions' do
        is_expected.not_to be_able_to :edit, holding_institution
        is_expected.not_to be_able_to :update, holding_institution
        is_expected.not_to be_able_to :destroy, holding_institution
      end
    end
    context 'Projects' do
      let(:project) { Fabricate :project }
      it 'can view Project info' do
        is_expected.to be_able_to :index, Project
        is_expected.to be_able_to :show, project
      end
      it 'cannot modify a Project' do
        is_expected.not_to be_able_to :edit, project
        is_expected.not_to be_able_to :update, project
        is_expected.not_to be_able_to :destroy, project
      end
    end

    context 'with Repository assigned' do
      let(:repository) { Fabricate(:repository) }
      let(:other_item) { Fabricate(:repository).items.first }
      it 'can modify but not destroy Repositories if the Repository is
          assigned' do
        basic_user.repositories << repository
        is_expected.to be_able_to :show, repository
        is_expected.to be_able_to :edit, repository
        is_expected.to be_able_to :update, repository
        is_expected.not_to be_able_to :destroy, repository
      end
      it 'can load the new Collection form' do
        is_expected.to be_able_to :new, Collection
      end
      it 'can modify but not destroy Collections if the Repository is
          assigned' do
        basic_user.repositories << repository
        collection = repository.collections.first
        is_expected.to be_able_to :show, collection
        is_expected.to be_able_to :edit, collection
        is_expected.to be_able_to :update, collection
        is_expected.not_to be_able_to :destroy, collection
      end
      it 'can modify but not destroy Items if the Repository is assigned' do
        basic_user.repositories << repository
        collection = repository.collections.first
        collection.items << other_item
        is_expected.to be_able_to :show, other_item
        is_expected.to be_able_to :edit, other_item
        is_expected.to be_able_to :copy, other_item
        is_expected.to be_able_to :update, other_item
        is_expected.not_to be_able_to :destroy, other_item
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
        collection.items << other_item
        is_expected.not_to be_able_to :show, other_item
        is_expected.not_to be_able_to :edit, other_item
        is_expected.not_to be_able_to :update, other_item
        is_expected.not_to be_able_to :destroy, other_item
      end
    end
    context 'with Collection assigned' do
      let(:collection) { Fabricate(:repository).collections.first }
      it 'can modify Collections if the Collection is assigned' do
        basic_user.collections << collection
        is_expected.to be_able_to :show, collection
        is_expected.to be_able_to :edit, collection
        is_expected.to be_able_to :update, collection
        is_expected.not_to be_able_to :destroy, collection
      end
      it 'can manage Items if the Collection is assigned' do
        basic_user.collections << collection
        is_expected.to be_able_to :show, collection
        is_expected.to be_able_to :edit, collection
        is_expected.to be_able_to :update, collection
        is_expected.not_to be_able_to :destroy, collection
      end
      it 'cannot modify or delete Collections if the Collection is not
          assigned' do
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
      with_versioning do
        it 'can manage ItemVersions if the Collection is assigned' do
          collection_with_items = Fabricate(:repository).collections.first
          basic_user.collections << collection_with_items
          collection_with_items.items.first.destroy
          item_version = ItemVersion.last
          is_expected.to be_able_to :rollback, item_version
          is_expected.to be_able_to :restore, item_version
          is_expected.to be_able_to :diff, item_version
        end
      end
    end
    context 'working with Batches' do
      let(:batch) { Fabricate(:batch) { batch_items(count: 1) } }
      it 'can create Batches' do
        is_expected.to be_able_to :index, batch
        is_expected.to be_able_to :new, batch
        is_expected.to be_able_to :create, batch
      end
      it 'can view BatchItems' do
        batch_item = batch.batch_items.first
        is_expected.to be_able_to :index, batch_item
      end
      it 'can create BatchItems for Collections that have been assigned' do
        batch_item = batch.batch_items.first
        collection = Fabricate(:repository).collections.first
        batch_item.collection = collection
        basic_user.collections << collection
        is_expected.to be_able_to :create, batch_item
        is_expected.to be_able_to :update, batch_item
      end
      it 'can create BatchItems for Collections in Repositories that have been
          assigned' do
        batch_item = batch.batch_items.first
        repository = Fabricate(:repository)
        batch_item.collection = repository.collections.first
        basic_user.repositories << repository
        is_expected.to be_able_to :create, batch_item
        is_expected.to be_able_to :update, batch_item
      end
      it 'cannot modify BatchItems for Collections that have not been
          assigned' do
        batch_item = batch.batch_items.first
        is_expected.not_to be_able_to :update, batch_item
      end
      it 'cannot update BatchItems for Collections in Repositories that have not
          been assigned' do
        batch_item = batch.batch_items.first
        is_expected.not_to be_able_to :update, batch_item
      end
      it 'cannot view or modify Batches belonging to others' do
        other_user = Fabricate :user
        batch.user = other_user
        is_expected.not_to be_able_to :show, batch
        is_expected.not_to be_able_to :edit, batch
        is_expected.not_to be_able_to :update, batch
        is_expected.not_to be_able_to :destroy, batch
      end
      it 'cannot modify or destroy BatchItems belonging to others' do
        other_user = Fabricate :user
        batch.user = other_user
        batch_item = batch.batch_items.first
        is_expected.not_to be_able_to :edit, batch_item
        is_expected.not_to be_able_to :update, batch_item
        is_expected.not_to be_able_to :destroy, batch_item
      end
      context 'when Batch is owned by self' do
        it 'can view, modify, destroy and recreate Batch' do
          batch.user = basic_user
          is_expected.to be_able_to :edit, batch
          is_expected.to be_able_to :update, batch
          is_expected.to be_able_to :destroy, batch
          is_expected.to be_able_to :recreate, batch
        end
        it 'can modify and destroy BatchItems in the Batch' do
          batch.user = basic_user
          batch_item = batch.batch_items.first
          is_expected.to be_able_to :edit, batch_item
          is_expected.to be_able_to :update, batch_item
          is_expected.to be_able_to :destroy, batch_item
        end
      end
    end
  end
  context 'for a committer user' do
    subject { Ability.new committer_user }
    let(:batch) { Fabricate :batch }
    it 'can commit a batch owned by self' do
      batch.user = committer_user
      is_expected.to be_able_to :commit, batch
      is_expected.to be_able_to :commit_form, batch
    end
    it 'can view results of any batch commit' do
      is_expected.to be_able_to :results, Batch
    end
    it 'cannot commit a batch not owned by self' do
      is_expected.not_to be_able_to :commit, batch
    end
  end
  context 'for a uploader user' do
    subject { Ability.new uploader_user }
    it 'can create a new BatchImport' do
      batch_import = Fabricate :batch_import
      is_expected.to be_able_to :new, batch_import
      is_expected.to be_able_to :create, batch_import
      is_expected.to be_able_to :help, batch_import
    end
    it 'cannot show or destroy Batch Imports for Batches not owned by self' do
      batch_import = Fabricate :batch_import
      is_expected.not_to be_able_to :show, batch_import
      is_expected.not_to be_able_to :destroy, batch_import
    end
    it 'can index, show and destroy Batch Imports for Batches owned by self' do
      batch = Fabricate :batch
      batch.user = uploader_user
      batch_import = BatchImport.new(user: uploader_user, batch: batch)
      is_expected.to be_able_to :index, batch_import
      is_expected.to be_able_to :show, batch_import
      is_expected.to be_able_to :destroy, batch_import
    end
  end
end