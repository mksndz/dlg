require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Batches Management' do

  let(:super_user) { Fabricate :super }
  let(:basic_user) { Fabricate :basic }
  let(:coordinator_user) { Fabricate :coordinator }
  let(:committer_user) { Fabricate :committer }
  let(:uploader_user) { Fabricate :uploader}

  context :super_user do

    before :each do
      login_as super_user, scope: :user
    end

    let(:batch) {
      Fabricate(:batch) {
        batch_items(count: 3)
      }
    }

    scenario 'can view a batch_item record' do

      visit batch_batch_item_path(batch, batch.batch_items.first)

      expect(page).to have_text batch.batch_items.first.title

    end

    scenario 'can load the batch_item edit form and save the record' do

      visit edit_batch_batch_item_path(batch, batch.batch_items.first)

      expect(page).to have_text batch.batch_items.first.title
      expect(page).to have_button I18n.t('meta.defaults.actions.save')
      expect(page).to have_button I18n.t('meta.defaults.actions.save_and_goto_next')
      expect(page).not_to have_button I18n.t('meta.defaults.actions.save_and_goto_previous')

    end

    scenario 'can load the batch_item new form and save the record (without seeing navigation buttons)' do

      visit new_batch_batch_item_path(batch)

      expect(page).to have_button I18n.t('meta.defaults.actions.save')
      expect(page).not_to have_button I18n.t('meta.defaults.actions.save_and_goto_next')
      expect(page).not_to have_button I18n.t('meta.defaults.actions.save_and_goto_previous')

    end


    scenario 'can save a batch_item and be taken to the show page' do

      visit edit_batch_batch_item_path(batch, batch.batch_items.first)

      click_on I18n.t('meta.defaults.actions.save')

      expect(page).to have_current_path batch_batch_item_path(batch, batch.batch_items.first)

    end


    scenario 'can save a batch_item and be taken to the next record' do

      visit edit_batch_batch_item_path(batch, batch.batch_items.first)

      click_on I18n.t('meta.defaults.actions.save_and_goto_next')

      expect(page).to have_current_path edit_batch_batch_item_path(batch, batch.batch_items.first.next)

    end

    scenario 'can save a batch_item and be taken to the previous record' do

      visit edit_batch_batch_item_path(batch, batch.batch_items.last)

      click_on I18n.t('meta.defaults.actions.save_and_goto_previous')

      expect(page).to have_current_path edit_batch_batch_item_path(batch, batch.batch_items.last.previous)

    end

  end

  context :coordinator_user do

    before :each do
      login_as coordinator_user, scope: :user
    end



  end

  context :committer_user do

    before :each do
      login_as committer_user, scope: :user
    end



  end



  context :basic_user do

    before :each do
      login_as basic_user, scope: :user
    end



  end

end