require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Batches Management' do
  let(:super_user) { Fabricate :super }
  let(:basic_user) { Fabricate :basic }
  let(:coordinator_user) { Fabricate :coordinator }
  let(:committer_user) { Fabricate :committer }
  context 'for a super user' do
    before :each do
      login_as super_user, scope: :user
    end
    scenario 'sees a list of all batches and action buttons' do
      batch = Fabricate :batch
      visit batches_path
      expect(page).to have_text batch.name
      expect(page).to have_link I18n.t('meta.defaults.actions.view')
      expect(page).to have_link I18n.t('meta.defaults.actions.edit')
      expect(page).to have_link I18n.t('meta.defaults.actions.destroy')
    end
    scenario 'can edit a batch created by another user' do
      batch = Fabricate :batch, user: basic_user
      visit edit_batch_path batch
      name = 'Changed Batch Name'
      notes = 'Changed Batch Notes'
      fill_in I18n.t('activerecord.attributes.batch.name'), with: name
      fill_in I18n.t('activerecord.attributes.batch.notes'), with: notes
      click_on I18n.t('meta.defaults.actions.save')
      expect(page).to have_current_path batch_path batch
      expect(page).to have_text name
      expect(page).to have_text notes
    end
    scenario 'committing an empty batch will display an error' do
      batch = Fabricate :batch
      visit batch_path batch
      expect(page).to have_link I18n.t('meta.batch.actions.commit')
      click_on I18n.t('meta.batch.actions.commit')
      expect(page).to have_current_path batch_path batch
      expect(page).to(
        have_text(I18n.t('meta.batch.messages.errors.empty_batch_commit'))
      )
    end
    scenario 'committing a batch with invalid batch_items will
              display an error' do
      batch = Fabricate(:batch) { batch_items(count: 2) }
      i = batch.batch_items.first
      i.dc_date = []
      i.save validate: false
      visit batch_path batch
      expect(page).to have_link I18n.t('meta.batch.actions.commit')
      click_on I18n.t('meta.batch.actions.commit')
      expect(page).to have_current_path batch_path batch
      expect(page).to(
        have_text(I18n.t('meta.batch.messages.errors.has_invalid_batch_items'))
      )
    end
    scenario 'visiting batches list will display number of batch items in a
              batch' do
      count = 5
      Fabricate :batch do
        batch_items(count: count)
      end
      visit batches_path
      within('.batch-items-count-link') do
        expect(page).to have_text count
      end
    end
    context 'commiting (run background jobs)' do
      before :each do
        ResqueSpec.reset!
        batch = Fabricate(:batch, user: committer_user) do
          batch_items(count: 1)
        end
        visit batch_path batch
        Resque.enqueue(BatchCommitter, batch.id)
        ResqueSpec.perform_all(:batch_commit_queue)
        visit batches_path
        click_on I18n.t('meta.batch.actions.results')
      end
      scenario 'a valid batch results in items with correct portals' do
        batch = Batch.last
        expect(page).to have_current_path(results_batch_path(batch))
        expect(page).to have_text batch.batch_items.first.slug
        expect(page).not_to have_text I18n.t('meta.batch.labels.failed')
        within 'table.successfully-committed-results-table tbody' do
          expect(all('tr').length).to eq 1
        end
        expect(page).to have_link I18n.t('meta.batch.actions.view_item')
        click_on I18n.t('meta.batch.actions.view_item')
        expect(page).to have_text Portal.last.name
      end
      scenario 'created items show the batch item that created them' do
        click_on I18n.t('meta.batch.actions.view_item')
        expect(page).to have_link Batch.last.committed_at
      end
    end
    context 'with deleted user handling' do
      before :each do
        Fabricate :batch
        User.last.destroy
      end
      scenario 'shows Unknown for creator on index' do
        visit batches_path
        expect(page).to have_text I18n.t('meta.batch.labels.deleted_user')
      end
      scenario 'shows Unknown for creator on show' do
        visit batch_path Batch.last
        expect(page).to have_text I18n.t('meta.batch.labels.deleted_user')
      end
    end
    context 'using the index page filters' do
      # TODO: this could be replaced with a model scope and model spec
      before :each do
        Fabricate :batch, name: 'pending-batch'
        Fabricate :batch, name: 'committed-batch', committed_at: Time.now
        visit batches_path
      end
      scenario 'can limit index listing to only committed batches' do
        select 'Committed', from: 'status'
        click_on I18n.t('meta.defaults.actions.filter')
        expect(page).to have_text 'committed-batch'
        expect(page).not_to have_text 'pending-batch'
      end
      scenario 'can limit index listing to only not-yet-committed
                batches' do
        select 'Pending', from: 'status'
        click_on I18n.t('meta.defaults.actions.filter')
        expect(page).not_to have_text 'committed-batch'
        expect(page).to have_text 'pending-batch'
      end
    end
    context 'commits a batch with an invalid item (run background
             jobs)' do
      scenario 'and the batch shows an error and a retry button' do
        ResqueSpec.reset!
        batch = Fabricate(:batch, user: committer_user) do
          batch_items(count: 1)
        end
        batch_item = BatchItem.last
        batch_item.dc_date = []
        batch_item.save(validate: false)
        Resque.enqueue(BatchCommitter, batch.id)
        ResqueSpec.perform_all(:batch_commit_queue)
        visit batches_path
        expect(page).to have_text I18n.t('meta.batch.messages.errors.could_not_commit')
        expect(page).to have_link I18n.t('meta.batch.actions.retry_commit')
        visit batch_path batch
        expect(page).to have_text batch.job_message
      end
    end
    context 'committing and updating records' do
      before :each do
        @new_slug = 'changed-slug'
        @item = Fabricate(:repository).items.first
        @old_slug = @item.slug
        @batch = Fabricate :batch_for_updating_record_id
        @batch_item = BatchItem.last
        @batch_item.slug = @new_slug
        @batch_item.collection = @item.collection
        @batch_item.portals = @item.portals
        @batch_item.item = @item
        @batch.batch_items << @batch_item
        @batch.commit
      end
      scenario 'can index a new record when changing slugs for items without
              creating a duplicate' do
        visit root_path
        fill_in 'title', with: ''
        click_button 'Search'
        expect(page).to have_text @new_slug
        expect(page).not_to have_text @old_slug
      end
      scenario 'updated item displays a previous version', versioning: true do
        @item.reload
        visit item_path @item
        expect(page).to have_link I18n.t('meta.versions.action.diff')
        expect(page).to have_text @item.paper_trail.previous_version.created_at
      end
    end
  end
  context 'for a coordinator user' do
    before :each do
      login_as coordinator_user, scope: :user
    end
    scenario 'coordinator user sees a list of only the batches they or those
              they manage have created' do
      managed_user = Fabricate :user, creator: coordinator_user
      batch1 = Fabricate :batch, user: managed_user
      batch2 = Fabricate :batch, user: coordinator_user
      other_batch = Fabricate :batch
      visit batches_path
      expect(page).to have_text batch1.name
      expect(page).to have_text batch2.name
      expect(page).not_to have_text other_batch.name
      expect(page).to have_link I18n.t('meta.defaults.actions.view')
      expect(page).to have_link I18n.t('meta.defaults.actions.edit')
      expect(page).to have_link I18n.t('meta.defaults.actions.destroy')
    end
  end
  context 'for a committer user' do
    context 'with a collection assigned' do
      before :each do
        login_as committer_user, scope: :user
        collection = Fabricate :empty_collection
        committer_user.collections << collection
        batch = Fabricate(:batch, user: committer_user) { batch_items count: 1 }
        batch.batch_items.first.collection = collection
        batch.batch_items.first.portals = collection.portals
        batch.batch_items.first.save
        visit batch_path batch
      end
      scenario 'can commit a valid batch (do not run background
                jobs)' do
        expect(page).to have_link I18n.t('meta.batch.actions.commit')
        click_on I18n.t('meta.batch.actions.commit')
        expect(page).to have_current_path commit_form_batch_path Batch.last
        click_on I18n.t('meta.batch.actions.commit')
        expect(page).to have_text I18n.t('meta.batch.messages.success.committed')
        visit batches_path
        expect(page).to have_text 'ago'
      end
      scenario 'cannot commit a valid batch when batch_items are
                members of collections the user is not assigned to' do
        batch = Batch.last
        batch.batch_items << Fabricate(:batch_item)
        visit batch_path batch
        expect(page).to have_link I18n.t('meta.batch.actions.commit')
        click_on I18n.t('meta.batch.actions.commit')
        expect(page).to have_text I18n.t('meta.batch.messages.errors.contains_unassigned_collections')
      end
      context 'running background jobs' do
        before(:each) do
          ResqueSpec.reset!
        end
        scenario 'can commit a valid batch (run background jobs) and can view
                  the results' do
          batch = Batch.last
          visit batch_path batch
          click_on I18n.t('meta.batch.actions.commit')
          click_on I18n.t('meta.batch.actions.commit')
          ResqueSpec.perform_all(:batch_commit_queue)
          visit batches_path
          click_on I18n.t('meta.batch.actions.results')
          expect(page).to have_current_path(results_batch_path(batch))
          expect(page).to have_text batch.batch_items.first.slug
          expect(page).not_to have_text I18n.t('meta.batch.labels.failed')
          within 'table.successfully-committed-results-table tbody' do
            expect(all('tr').length).to eq 1
          end
          expect(page).to have_link I18n.t('meta.batch.actions.view_item')
        end
      end
    end
  end
  context 'for a basic user' do
    before :each do
      login_as basic_user, scope: :user
    end
    scenario 'sees a list of only the batches they have created' do
      batch = Fabricate :batch, user: basic_user
      other_batch = Fabricate :batch
      visit batches_path
      expect(page).to have_text batch.name
      expect(page).not_to have_text other_batch.name
      expect(page).to have_link I18n.t('meta.defaults.actions.view')
      expect(page).to have_link I18n.t('meta.defaults.actions.edit')
      expect(page).to have_link I18n.t('meta.defaults.actions.destroy')
    end
    scenario 'basic user can add a batch item to a batch' do
      Fabricate :repository
      batch = Fabricate :batch, user: basic_user
      visit edit_batch_path(batch)
      expect(page).to have_link I18n.t('meta.batch.actions.add_batch_item')
      click_on I18n.t('meta.batch.actions.add_batch_item')
      expect(page).to have_current_path new_batch_batch_item_path(batch)
      find('.fixed-save-button').click
      expect(page).to have_text I18n.t('meta.defaults.messages.errors.invalid_on_save', entity: 'Batch Item')
    end
    scenario 'basic user does not see the button for or have the ability to upload XML' do
      Fabricate :batch
      visit edit_batch_path(Batch.last)
      expect(page).not_to have_button I18n.t('meta.batch.actions.import')
    end
  end
end