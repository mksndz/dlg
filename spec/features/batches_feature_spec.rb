require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Batches Management' do

  # todo recreate batches

  let(:super_user) { Fabricate :super }
  let(:basic_user) { Fabricate :basic }
  let(:coordinator_user) { Fabricate :coordinator }
  let(:committer_user) { Fabricate :committer }
  let(:uploader_user) { Fabricate :uploader}

  context :super_user do

    before :each do
      login_as super_user, scope: :user
    end

    scenario 'super user sees a list of all batches and action buttons' do

      batch = Fabricate :batch

      visit batches_path

      expect(page).to have_text batch.name
      expect(page).to have_link I18n.t('meta.defaults.actions.view')
      expect(page).to have_link I18n.t('meta.defaults.actions.edit')
      expect(page).to have_link I18n.t('meta.defaults.actions.destroy')

    end

    scenario 'super user can limit index listing to only committed batches' do

      pending_batch = Fabricate :batch
      committed_batch = Fabricate :batch do
        committed_at { Time.now }
      end

      visit batches_path

      select 'Committed', from: 'status'
      click_on I18n.t('meta.defaults.actions.filter')

      expect(page).to have_text committed_batch.name
      expect(page).not_to have_text pending_batch.name

    end

    scenario 'super user can limit index listing to only not-yet-committed batches' do

      pending_batch = Fabricate :batch
      committed_batch = Fabricate :batch do
        committed_at { Time.now }
      end

      visit batches_path

      select 'Pending', from: 'status'
      click_on I18n.t('meta.defaults.actions.filter')

      expect(page).not_to have_text committed_batch.name
      expect(page).to have_text pending_batch.name

    end

    scenario 'super user can edit a batch created by another user' do

      batch = Fabricate :batch
      batch.user = basic_user
      batch.save

      visit edit_batch_path(batch)

      expect(find_field(I18n.t('activerecord.attributes.batch.name')).value).to eq batch.name
      expect(find_field(I18n.t('activerecord.attributes.batch.notes')).value).to eq batch.notes

      name = 'Changed Batch Name'
      notes = 'Changed Batch Notes'

      fill_in I18n.t('activerecord.attributes.batch.name'), with: name
      fill_in I18n.t('activerecord.attributes.batch.notes'), with: notes
      click_on I18n.t('meta.defaults.actions.save')

      expect(page).to have_current_path batch_path(batch)
      expect(page).to have_text name
      expect(page).to have_text notes

    end

    scenario 'super user committing an empty batch will display an error' do

      batch = Fabricate :batch

      visit batch_path batch

      expect(page).to have_link I18n.t('meta.batch.actions.commit')

      click_on I18n.t('meta.batch.actions.commit')

      expect(page).to have_current_path batch_path batch
      expect(page).to have_text I18n.t('meta.batch.labels.empty_batch_commit')

    end

    scenario 'super user visiting batches list will display number of batch items in a batch' do

      count = 5

      Fabricate :batch do
        batch_items(count: count)
      end

      visit batches_path

      within('.count-link') do
        expect(page).to have_text count
      end

    end

    scenario 'super user sees a button to import XML and can load the form' do

      Fabricate :batch

      visit edit_batch_path(Batch.last)

      expect(page).to have_link I18n.t('meta.batch.actions.populate_with_xml')

      click_on I18n.t('meta.batch.actions.populate_with_xml')

      expect(page).to have_text I18n.t('meta.batch.labels.import.xml_file') # todo
      expect(page).to have_field I18n.t('meta.batch.labels.import.xml_text')
      expect(page).to have_field I18n.t('meta.batch.labels.import.bypass_validations')

    end

    scenario 'super user can upload some xml' do

      # todo

    end

  end

  context :coordinator_user do

    before :each do
      login_as coordinator_user, scope: :user
    end

    scenario 'coordinator user sees a list of only the batches they or those they manage have created' do

      managed_user = Fabricate :user
      managed_user.creator = coordinator_user
      managed_user.save

      batch1 = Fabricate :batch
      batch1.user = managed_user
      batch1.save

      batch2 = Fabricate :batch
      batch2.user = coordinator_user
      batch2.save

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

  context :committer_user do

    before :each do
      login_as committer_user, scope: :user
    end

    scenario 'committer user can commit a valid batch (do not run background jobs)' do

      batch_items = 2

      batch = Fabricate :batch do
        batch_items(count: batch_items)
      end

      batch.user = committer_user
      batch.save

      visit batch_path batch

      expect(page).to have_link I18n.t('meta.batch.actions.commit')

      click_on I18n.t('meta.batch.actions.commit')

      expect(page).to have_current_path commit_form_batch_path batch

      click_on I18n.t('meta.batch.actions.commit')

      expect(page).to have_text I18n.t('meta.batch.messages.success.committed')

      visit batches_path

      expect(page).to have_text I18n.t('meta.batch.labels.commit_pending', time: batch.queued_for_commit_at)

    end

    scenario 'committer user can commit a valid batch (run background jobs) and can view the results' do

      batch_items = 1

      batch = Fabricate :batch do
        batch_items(count: batch_items)
      end

      batch.user = committer_user
      batch.save

      visit batch_path batch

      click_on I18n.t('meta.batch.actions.commit')
      click_on I18n.t('meta.batch.actions.commit')

      Delayed::Worker.new.work_off

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

  context :uploader_user do

    before :each do
      login_as uploader_user, scope: :user
    end

    scenario 'uploader user sees a button to import XML and can load the form' do

      batch = Fabricate :batch
      batch.user = uploader_user
      batch.save

      visit edit_batch_path(batch)

      expect(page).to have_link I18n.t('meta.batch.actions.populate_with_xml')

      click_on I18n.t('meta.batch.actions.populate_with_xml')

      expect(page).to have_text I18n.t('meta.batch.labels.import.xml_file') # todo
      expect(page).to have_field I18n.t('meta.batch.labels.import.xml_text')
      expect(page).to have_field I18n.t('meta.batch.labels.import.bypass_validations')

    end

  end

  context :basic_user do

    before :each do
      login_as basic_user, scope: :user
    end

    scenario 'basic user sees a list of only the batches they have created' do

      batch = Fabricate :batch
      batch.user = basic_user
      batch.save

      other_batch = Fabricate :batch

      visit batches_path

      expect(page).to have_text batch.name
      expect(page).not_to have_text other_batch.name
      expect(page).to have_link I18n.t('meta.defaults.actions.view')
      expect(page).to have_link I18n.t('meta.defaults.actions.edit')
      expect(page).to have_link I18n.t('meta.defaults.actions.destroy')

    end

    scenario 'basic user can create a batch' do

      visit batches_path

      click_on I18n.t('meta.batch.actions.add')

      expect(page).to have_field I18n.t('activerecord.attributes.batch.name')
      expect(page).to have_field I18n.t('activerecord.attributes.batch.notes')

      name = 'Test Batch'
      notes = 'Some Notes'

      fill_in I18n.t('activerecord.attributes.batch.name'), with: name
      fill_in I18n.t('activerecord.attributes.batch.notes'), with: notes
      click_on I18n.t('meta.defaults.actions.save')

      expect(page).to have_current_path batch_path(Batch.last)
      expect(page).to have_text name
      expect(page).to have_text notes

    end

    scenario 'basic user can edit a batch they created' do

      batch = Fabricate :batch
      batch.user = basic_user
      batch.save

      visit edit_batch_path(batch)

      expect(find_field(I18n.t('activerecord.attributes.batch.name')).value).to eq batch.name
      expect(find_field(I18n.t('activerecord.attributes.batch.notes')).value).to eq batch.notes

      name = 'Changed Batch Name'
      notes = 'Changed Batch Notes'

      fill_in I18n.t('activerecord.attributes.batch.name'), with: name
      fill_in I18n.t('activerecord.attributes.batch.notes'), with: notes
      click_on I18n.t('meta.defaults.actions.save')

      expect(page).to have_current_path batch_path(batch)
      expect(page).to have_text name
      expect(page).to have_text notes

    end

    scenario 'basic user cannot edit a batch they did not create' do

      Fabricate :batch

      visit edit_batch_path(Batch.last)

      expect(page).to have_text I18n.t('unauthorized.edit.batch')
      expect(page).to have_current_path root_path  # todo change to batch_path?

    end

    scenario 'basic user can add a batch item to a batch' do

      Fabricate :repository do
        collections(count: 1)
      end

      batch = Fabricate :batch
      batch.user = basic_user
      batch.save

      visit edit_batch_path(batch)

      expect(page).to have_link I18n.t('meta.batch.actions.add_batch_item')

      click_on I18n.t('meta.batch.actions.add_batch_item')

      expect(page).to have_current_path new_batch_batch_item_path(batch)

      # todo expect page to have all item_type fields

      click_on I18n.t('meta.defaults.actions.save')

      expect(page).to have_text I18n.t('meta.defaults.messages.errors.invalid_on_save', entity: 'Batch Item')

    end

    scenario 'basic user does not see the button for or have the ability to upload XML' do

      Fabricate :batch

      visit edit_batch_path(Batch.last)

      expect(page).not_to have_button I18n.t('meta.batch.actions.import')

    end

  end

end