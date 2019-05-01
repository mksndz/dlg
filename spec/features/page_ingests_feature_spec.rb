require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Page Ingests' do
  let(:super_user) { Fabricate :super }
  before :each do
    login_as super_user, scope: :user
  end
  context 'on the index page' do
    context 'when successfully completed' do
      before(:each) do
        @pi = Fabricate :page_ingest_with_json_and_success
        visit page_ingests_path
      end
      scenario 'has a button to create a new ingest' do
        expect(page).to have_link I18n.t('meta.page_ingests.action.add')
      end
      scenario 'are listed with details and actions' do
        expect(page).to have_link @pi.title
        expect(page).to have_text @pi.user.email
        expect(page).to have_text I18n.l(@pi.queued_at, format: :h)
        expect(page).to have_text I18n.l(@pi.finished_at, format: :h)
      end
    end
    context 'when queued' do
      before(:each) do
        @pi = Fabricate :queued_page_ingest
        visit page_ingests_path
      end
      scenario 'are listed with only a queued time' do
        expect(page).to have_text I18n.l(@pi.queued_at, format: :h)
      end
    end
  end
  context 'on the show page' do
    context 'with a successful ingest' do
      before(:each) do
        @pi = Fabricate :page_ingest_with_json_and_success
        visit page_ingest_path(@pi)
      end
      scenario 'all attributes are displayed and results' do
        expect(page).to have_text @pi.title
        expect(page).to have_text @pi.description
        expect(page).to have_text @pi.file
        expect(page).to have_text I18n.l(@pi.queued_at, format: :h)
        expect(page).to have_text I18n.l(@pi.finished_at, format: :h)
        expect(page).to have_text I18n.l(@pi.created_at, format: :h)
        expect(page).to have_text I18n.l(@pi.updated_at, format: :h)
        expect(page).not_to have_css 'table.page-ingest-results-table-failed'
        within '.page-ingest-results-table-succeeded tbody' do
          expect(all('tr').length).to eq 2
          expect(page).to have_css 'tr.success'
        end
      end
    end
    context 'with an ingest that includes errors' do
      before(:each) do
        @pi = Fabricate :page_ingest_with_json_and_mixed_results
        visit page_ingest_path(@pi)
      end
      scenario 'results are displayed with error details' do
        within '.page-ingest-results-table-succeeded tbody' do
          expect(all('tr').length).to eq 2
          expect(page).to have_css 'tr.success'
        end
        within '.page-ingest-results-table-failed' do
          expect(page).to have_text I18n.t('meta.page_ingests.labels.message')
        end
        within '.page-ingest-results-table-failed tbody' do
          expect(all('tr').length).to eq 1
          expect(page).to have_css 'tr.danger'
        end
      end
    end
    context 'with an ingest that completely fails' do
      before(:each) do
        @pi = Fabricate :page_ingest_with_json_and_total_failure
        visit page_ingest_path(@pi)
      end
      scenario 'results are displayed with error details' do
        expect(page).to have_css '.panel-danger'
        expect(page).to have_text @pi.results_json['message']
      end
    end
  end
  context 'can be created using the form' do
    before(:each) do
      visit new_page_ingest_path
    end
    scenario 'and a success message is shown' do
      fill_in I18n.t('activerecord.attributes.page_ingest.title'), with: 'Test'
      fill_in I18n.t('activerecord.attributes.page_ingest.description'), with: 'Description'
      attach_file I18n.t('activerecord.attributes.page_ingest.file'), Rails.root.to_s + '/spec/files/pages.json'
      click_on I18n.t('meta.defaults.actions.save')
      expect(page).to have_text I18n.t('meta.page_ingests.messages.success.queued')
    end
  end
  context 'are created and background processes executed' do
    scenario 'successfully' do
      ResqueSpec.reset!
      r = Fabricate :empty_repository, slug: 'a'
      c = Fabricate(
        :empty_collection,
        slug: 'b', repository: r, portals: r.portals
      )
      Fabricate(:item, slug: 'c') do
        collection c
        portals c.portals
        fulltext nil
      end
      Fabricate(:item, slug: 'd') do
        collection c
        portals c.portals
        fulltext nil
      end
      visit new_page_ingest_path
      fill_in I18n.t('activerecord.attributes.page_ingest.title'), with: 'Test'
      fill_in I18n.t('activerecord.attributes.page_ingest.description'), with: 'Description'
      attach_file I18n.t('activerecord.attributes.page_ingest.file'), Rails.root.to_s + '/spec/files/pages.json'
      click_button I18n.t('meta.defaults.actions.save')
      ResqueSpec.perform_all :page_ingest_queue
      fti = PageIngest.last
      expect(fti.finished_at).not_to be_nil
      expect(fti.queued_at).not_to be_nil
      expect(Item.find_by(record_id: 'a_b_c').pages).not_to be_empty
      expect(Item.find_by(record_id: 'a_b_d').pages).not_to be_empty
    end
  end
end