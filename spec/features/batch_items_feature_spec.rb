require 'rails_helper'
require 'chosen-rails/rspec'
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

      within '.action-buttons' do
        click_on I18n.t('meta.defaults.actions.save')
      end

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


    context 'portal behavior' do

      scenario 'saves a new batch_item with no portal value' do

        b = Fabricate(:batch) { batch_items(count:1) }

        visit batch_batch_items_path(b)

        click_on I18n.t('meta.defaults.actions.edit')

        fill_in I18n.t('activerecord.attributes.batch_item.slug'), with: 'test'
        fill_in I18n.t('activerecord.attributes.batch_item.dcterms_temporal'), with: '2000'
        fill_in I18n.t('activerecord.attributes.batch_item.dcterms_spatial'), with: 'Georgia'
        chosen_select 'Text', from: 'dcterms-type-select'

        click_button I18n.t('meta.defaults.actions.save')

        expect(page).to have_current_path batch_batch_item_path(b, b.batch_items.first)

      end

      scenario 'super user saves a new batch_item with a single portal value' do

        b = Fabricate(:batch) { batch_items(count:1) }

        p = Fabricate(:portal)

        visit batch_batch_items_path(b)

        click_on I18n.t('meta.defaults.actions.edit')

        fill_in I18n.t('activerecord.attributes.batch_item.slug'), with: 'test'
        fill_in I18n.t('activerecord.attributes.batch_item.dcterms_temporal'), with: '2000'
        fill_in I18n.t('activerecord.attributes.batch_item.dcterms_spatial'), with: 'Georgia'
        chosen_select 'Text', from: 'dcterms-type-select'

        select p.name, from: I18n.t('activerecord.attributes.batch_item.portal_ids')

        click_button I18n.t('meta.defaults.actions.save')

        expect(page).to have_current_path batch_batch_item_path(b, b.batch_items.first)

      end

      scenario 'super user saves a new batch_item with a multiple portal values' do

        b = Fabricate(:batch) { batch_items(count:1) }

        p1 = Fabricate(:portal)
        p2 = Fabricate(:portal)

        visit batch_batch_items_path(b)

        click_on I18n.t('meta.defaults.actions.edit')

        fill_in I18n.t('activerecord.attributes.batch_item.slug'), with: 'test'
        fill_in I18n.t('activerecord.attributes.batch_item.dcterms_temporal'), with: '2000'
        fill_in I18n.t('activerecord.attributes.batch_item.dcterms_spatial'), with: 'Georgia'
        chosen_select 'Text', from: 'dcterms-type-select'

        select p1.name, from: I18n.t('activerecord.attributes.batch_item.portal_ids')
        select p2.name, from: I18n.t('activerecord.attributes.batch_item.portal_ids')

        click_button I18n.t('meta.defaults.actions.save')

        expect(page).to have_current_path batch_batch_item_path(b, b.batch_items.first)
        expect(page).to have_text p1.name
        expect(page).to have_text p2.name

      end

      scenario 'saves a new batch_item removing other_collection value' do

        b = Fabricate(:batch) {
          batch_items(count:1)
        }

        p = Fabricate :portal

        b.batch_items.first.portals = [p]

        visit batch_batch_items_path(b)

        click_on I18n.t('meta.defaults.actions.edit')

        fill_in I18n.t('activerecord.attributes.batch_item.slug'), with: 'test'
        fill_in I18n.t('activerecord.attributes.batch_item.dcterms_temporal'), with: '2000'
        fill_in I18n.t('activerecord.attributes.batch_item.dcterms_spatial'), with: 'Georgia'
        chosen_select 'Text', from: 'dcterms-type-select'

        select '', from: I18n.t('activerecord.attributes.batch_item.portal_ids')

        click_button I18n.t('meta.defaults.actions.save')

        expect(page).to have_current_path batch_batch_item_path(b, b.batch_items.first)

      end

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