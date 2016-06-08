require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Batches Management' do

  let(:super_user) { Fabricate :super }
  let(:basic_user) { Fabricate :basic }
  let(:coordinator_user) { Fabricate :coordinator }
  let(:committer_user) { Fabricate :committer }

  scenario 'super user sees a list of all batches and action buttons' do

    login_as super_user, scope: :user

    batch = Fabricate :batch

    visit batches_path

    expect(page).to have_text batch.name
    expect(page).to have_link I18n.t('meta.defaults.actions.view')
    expect(page).to have_link I18n.t('meta.defaults.actions.edit')
    expect(page).to have_link I18n.t('meta.defaults.actions.destroy')

  end

  scenario 'basic user sees a list of only the batches they have created' do

    login_as basic_user, scope: :user

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

  scenario 'coordinator user sees a list of only the batches they or those they manage have created' do

    login_as coordinator_user, scope: :user

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

  scenario 'filter can limit index listing to only committed batches' do

    login_as super_user, scope: :user

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

  scenario 'filter can limit index listing to only not-yet-committed batches' do

    login_as super_user, scope: :user

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

  scenario 'basic user can create a batch' do



  end

  scenario 'super user can create a batch' do



  end

  scenario 'basic user can edit a batch they created' do



  end

  scenario 'basic user cannot edit a batch they did not create' do



  end

  scenario 'super user can edit a batch created by another user' do



  end

  scenario 'basic user can add a batch item to a batch' do



  end

  scenario 'committing an empty batch will display an error' do



  end

  scenario 'batches list will display number of batch items in a batch' do



  end

  scenario 'basic user does not see the button for or have the ability to upload XML' do



  end

  scenario 'super user sees a button to import XML and can load the form' do



  end

  scenario 'super user can upload some xml' do

    # todo

  end

end