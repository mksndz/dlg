require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Fulltext Ingests' do
  let(:super_user) { Fabricate :super}
  before :each do
    login_as super_user, scope: :user
  end
  context 'on the index page' do
    context 'when successfully completed' do
      before(:each) do
        @fti = Fabricate :completed_fulltext_ingest_success
        visit fulltext_ingests_path
      end
      scenario 'has a button to create a new ingest' do
        expect(page).to have_link I18n.t('meta.fulltext_ingests.action.add')
      end
      scenario 'are listed with details and actions' do
        expect(page).to have_link @fti.title
        expect(page).to have_text @fti.user.email
        expect(page).to have_text @fti.queued_at
        expect(page).to have_text @fti.finished_at
      end
    end
    context 'when queued' do
      before(:each) do
        @fti = Fabricate :queued_fulltext_ingest
        visit fulltext_ingests_path
      end
      scenario 'are listed with only a queued time' do
        expect(page).to have_text @fti.queued_at
      end
    end
    context 'when undone' do
      before(:each) do
        @fti = Fabricate :undone_fulltext_ingest
        visit fulltext_ingests_path
      end
      scenario 'are listed with a check' do
        expect(page).to have_css '.glyphicon-ok'
      end
    end
  end
  context 'on the show page' do
    context 'with a successful ingest' do
      before(:each) do
        @fti = Fabricate :completed_fulltext_ingest_success
        visit fulltext_ingest_path(@fti)
      end
      scenario 'all attributes are displayed and results' do
        expect(page).to have_text @fti.title
        expect(page).to have_text @fti.description
        expect(page).to have_text @fti.file_identifier
        expect(page).to have_text @fti.queued_at
        expect(page).to have_text @fti.finished_at
        expect(page).to have_text @fti.created_at
        expect(page).to have_text @fti.updated_at
        within '.fulltext-ingest-results-table tbody' do
          expect(all('tr').length).to eq 2
          expect(page).to have_css 'tr.success'
          expect(page).not_to have_css 'tr.danger'
          expect(page).to have_text @fti.processed_files.first[0]
          expect(page).to have_link 'Item Updated'
        end
      end
    end
    context 'with an ingest that includes errors' do
      before(:each) do
        @fti = Fabricate :completed_fulltext_ingest_with_errors
        visit fulltext_ingest_path(@fti)
      end
      scenario 'results are displayed with error details' do
        expect(page).to have_css '.panel-default'
        within '.fulltext-ingest-results-table tbody' do
          expect(all('tr').length).to eq 2
          expect(page).to have_css 'tr.success'
          expect(page).to have_css 'tr.danger'
          expect(page).to have_text @fti.processed_files.first[0]
          expect(page).to have_text @fti.processed_files['r1_c1_i2']['reason']
        end
      end
    end
    context 'with an ingest that completely fails' do
      before(:each) do
        @fti = Fabricate :completed_fulltext_ingest_total_failure
        visit fulltext_ingest_path(@fti)
      end
      scenario 'results are displayed with error details' do
        expect(page).to have_css '.panel-danger'
        expect(page).to have_text @fti.results['message']
      end
    end
  end
  context 'can be created using the form' do
    before(:each) do
      visit new_fulltext_ingest_path
    end
    scenario 'and a success message is shown' do
      fill_in I18n.t('activerecord.attributes.fulltext_ingest.title'), with: 'Test'
      fill_in I18n.t('activerecord.attributes.fulltext_ingest.description'), with: 'Description'
      attach_file I18n.t('activerecord.attributes.fulltext_ingest.file'), Rails.root.to_s + '/spec/files/fulltext.zip'
      click_on I18n.t('meta.defaults.actions.save')
      expect(page).to have_text I18n.t('meta.fulltext_ingests.messages.success.queued')
    end
  end
  context 'are created and background processes executed' do
    scenario 'successfully' do
      ResqueSpec.reset!
      r = Fabricate :empty_repository, slug: 'r1'
      c = Fabricate(
        :empty_collection,
        slug: 'c1', repository: r, portals: r.portals
      )
      Fabricate(:item, slug: 'i1') do
        collection c
        portals c.portals
      end
      Fabricate(:item, slug: 'i2') do
        collection c
        portals c.portals
      end
      visit new_fulltext_ingest_path
      fill_in I18n.t('activerecord.attributes.fulltext_ingest.title'), with: 'Test'
      fill_in I18n.t('activerecord.attributes.fulltext_ingest.description'), with: 'Description'
      attach_file I18n.t('activerecord.attributes.fulltext_ingest.file'), Rails.root.to_s + '/spec/files/fulltext.zip'
      click_button I18n.t('meta.defaults.actions.save')
      ResqueSpec.perform_all :fulltext_ingest_queue
      fti = FulltextIngest.last
      expect(fti.finished_at).not_to be_nil
      expect(fti.queued_at).not_to be_nil
      expect(Item.first.fulltext).not_to be_empty
      expect(Item.last.fulltext).not_to be_empty
    end
  end
end