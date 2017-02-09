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

    context 'index page filtering' do

      scenario 'can limit to just collections from a particular portal' do

        r = Fabricate(:repository) {
          portals(count: 1)
        }

        r2 = Fabricate(:repository)

        p = Portal.last

        visit repositories_path

        chosen_select p.name, from: '_portal_id'

        within '.index-filter-area' do
          find('.btn-primary').click
        end

        expect(page).to have_text r.title
        expect(page).not_to have_text r2.title

      end

      scenario 'can limit to just collections from multiple portals' do

        r = Fabricate(:repository) {
          portals(count: 1)
        }

        r2 = Fabricate(:repository) {
          portals(count: 1)
        }

        r3 = Fabricate(:repository)

        p1 = Portal.first
        p2 = Portal.last

        visit repositories_path

        chosen_select p1.name, from: '_portal_id'
        chosen_select p2.name, from: '_portal_id'

        within '.index-filter-area' do
          find('.btn-primary').click
        end

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

      scenario 'saves a new repository removing other_repository value' do

        c = Fabricate(:repository)
        p = Fabricate :portal

        c.portals = [p]

        visit repositories_path

        click_on I18n.t('meta.defaults.actions.edit')

        fill_in I18n.t('activerecord.attributes.repository.slug'), with: 'test'

        select '', from: I18n.t('activerecord.attributes.repository.portal_ids')

        click_button I18n.t('meta.defaults.actions.save')

        expect(page).to have_current_path repository_path(c)

      end

    end

  end

end