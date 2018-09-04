require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Holding Institution management' do
  before :each do
    login_as Fabricate(:super), scope: :user
  end
  context 'basic CRUD functionality' do
    context 'index page' do
      scenario 'sees a list of all holding institutions and action buttons' do
        holding_institution = Fabricate(:empty_collection).holding_institutions.first
        visit holding_institutions_path
        expect(page).to have_text holding_institution.display_name
        expect(page).to have_link I18n.t('meta.defaults.actions.view')
        expect(page).to have_link I18n.t('meta.defaults.actions.edit')
        expect(page).to have_link I18n.t('meta.defaults.actions.destroy')
      end
    end
    context 'show page' do
      it 'displays all record information' do
        holding_institution = Fabricate(:empty_collection).holding_institutions.first
        holding_institution.repositories << Repository.last
        holding_institution.projects << Fabricate(:project)
        holding_institution.save
        visit holding_institution_path(holding_institution)
        expect(page).to have_text holding_institution.display_name
        expect(page).to have_text holding_institution.repositories.first.title
        expect(page).to have_text holding_institution.short_description
        expect(page).to have_text holding_institution.description
        expect(page).to have_text holding_institution.homepage_url
        expect(page).to have_text holding_institution.coordinates
        expect(page).to have_text holding_institution.strengths
        expect(page).to have_text holding_institution.collections.first.display_title
        expect(page).to have_text holding_institution.projects.first.title
        expect(page).to have_text holding_institution.contact_name
        expect(page).to have_text holding_institution.contact_email
        expect(page).to have_text holding_institution.galileo_member
        expect(page).to have_text holding_institution.harvest_strategy
        expect(page).to have_text holding_institution.oai_urls.first
        expect(page).to have_text holding_institution.ignored_collections
        expect(page).to have_text holding_institution.last_harvested_at
        expect(page).to have_text holding_institution.analytics_emails.first
        expect(page).to have_text holding_institution.subgranting
        expect(page).to have_text holding_institution.grant_partnerships
      end
    end
    context 'edit page', js: true do
      before :each do
        holding_institution = Fabricate(:empty_collection).holding_institutions.first
        visit edit_holding_institution_path(holding_institution)
      end
      it 'shows a chosen multi-select for Repositories' do
        expect(page).to have_css '#holding_institution_repository_ids_chosen'
      end
      it 'shows a chosen select for institution_type' do
        expect(page).to have_css '#holding_institution_institution_type_chosen'
      end
    end
  end
end