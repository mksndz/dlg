require 'rails_helper'
require 'chosen-rails/rspec'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Repositories Management' do
  let(:super_user) { Fabricate :super }
  let(:basic_user) { Fabricate :basic }
  context 'for super user' do
    before :each do
      login_as super_user, scope: :user
    end
    context 'validation' do
      scenario 'requires a coordinates value' do
        Fabricate :empty_repository
        visit new_repository_path
        fill_in I18n.t('activerecord.attributes.repository.title'), with: 'Test'
        click_on I18n.t('meta.defaults.actions.save')
        expect(page).to have_text I18n.t('activerecord.errors.messages.repository.blank')
      end
    end
    context 'index page filtering' do
      scenario 'can limit to just collections from a particular portal' do
        r = Fabricate(:repository)
        r2 = Fabricate(:repository)
        p = Fabricate :portal
        r.portals << p
        visit repositories_path
        chosen_select p.name, from: '_portal_id'
        find_button(I18n.t('meta.defaults.actions.filter')).click
        expect(page).to have_text r.title
        expect(page).not_to have_text r2.title
      end
      scenario 'can limit to just collections from multiple portals' do
        r = Fabricate(:repository)
        r2 = Fabricate(:repository)
        r3 = Fabricate(:repository)
        p1 = Fabricate :portal
        p2 = Fabricate :portal
        r.portals << p1
        r2.portals << p2
        visit repositories_path
        chosen_select p1.name, from: '_portal_id'
        chosen_select p2.name, from: '_portal_id'
        find_button(I18n.t('meta.defaults.actions.filter')).click
        expect(page).to have_text r.title
        expect(page).to have_text r2.title
        expect(page).not_to have_text r3.title
      end
    end
    context 'portal behavior' do
      scenario 'saves a new repository with no portal value' do
        c = Fabricate(:repository)
        visit repositories_path
        click_on I18n.t('meta.defaults.actions.edit')
        fill_in I18n.t('activerecord.attributes.repository.slug'), with: 'test'
        click_button I18n.t('meta.defaults.actions.save')
        expect(page).to have_current_path repository_path(c)
      end
      scenario 'super user saves a new repository with a single portal value' do
        c = Fabricate(:repository)
        p = Fabricate(:portal)
        visit repositories_path
        click_on I18n.t('meta.defaults.actions.edit')
        fill_in I18n.t('activerecord.attributes.repository.slug'), with: 'test'
        select p.name, from: I18n.t('activerecord.attributes.repository.portal_ids')
        click_button I18n.t('meta.defaults.actions.save')
        expect(page).to have_current_path repository_path(c)
      end
      scenario 'super user saves a new repository with a multiple portal values' do
        c = Fabricate(:repository)
        p1 = Fabricate(:portal)
        p2 = Fabricate(:portal)
        visit repositories_path
        click_on I18n.t('meta.defaults.actions.edit')
        fill_in I18n.t('activerecord.attributes.repository.slug'), with: 'test'
        select p1.name, from: I18n.t('activerecord.attributes.repository.portal_ids')
        select p2.name, from: I18n.t('activerecord.attributes.repository.portal_ids')
        click_button I18n.t('meta.defaults.actions.save')
        expect(page).to have_current_path repository_path(c)
        expect(page).to have_text p1.name
        expect(page).to have_text p2.name
      end
      scenario 'removing the only portal value', js: true do
        r = Fabricate :empty_repository
        visit edit_repository_path r
        within '#repository_portal_ids_chosen' do
          find('.search-choice-close').click
        end
        click_button I18n.t('meta.defaults.actions.save')
        expect(page).to have_text I18n.t('activerecord.errors.messages.portal')
      end
      scenario 'removing a portal value with children still assigned shows an error', js: true do
        r = Fabricate :repository
        r.portals << Fabricate(:portal)
        visit edit_repository_path r
        find_all('.search-choice').map do |e|
          within e do
            find('.search-choice-close').click
          end if e.text == r.collections.first.portals.last.name
        end
        click_button I18n.t('meta.defaults.actions.save')
        expect(page).to have_text /#{r.collections.first.id}/
      end
    end
    context 'default color' do
      scenario 'new form shows white as selected color' do
        visit new_repository_path
        expect(find_field(I18n.t('activerecord.attributes.repository.color')).value).to eq '#ffffff'
      end
      scenario 'created Repository shows non-white color' do
        Fabricate :repository
        visit edit_repository_path Repository.last
        expect(find_field(I18n.t('activerecord.attributes.repository.color')).value).to eq '#eeeeee'
      end
    end
  end
end