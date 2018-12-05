require 'rails_helper'
require 'chosen-rails/rspec'
Warden.test_mode!

feature 'Page Management' do
  include Warden::Test::Helpers
  let(:super_user) { Fabricate :super }
  context 'super user' do
    before(:each) { login_as super_user, scope: :user }
    let(:pg) { Fabricate :page_with_item_and_text }
    context 'index' do
      before(:each) { visit item_pages_path pg.item }
      scenario 'lists all Pages for Item' do
        expect(page).to have_link(pg.title,
                                  href: edit_item_page_path(pg.item, pg))
      end
      scenario 'shows a button to create a new Page for Item' do
        expect(page).to have_link(I18n.t('meta.page.actions.add'),
                                  href: new_item_page_path(pg.item))
      end
      scenario 'shows action links for Page' do
        expect(page).to have_link(I18n.t('meta.defaults.actions.view'),
                                  href: item_page_path(pg.item, pg))
        expect(page).to have_link(I18n.t('meta.defaults.actions.edit'),
                                  href: edit_item_page_path(pg.item, pg))
        expect(page).to have_link(I18n.t('meta.defaults.actions.destroy'),
                                  href: item_page_path(pg.item, pg))
      end
    end
    context 'show' do
      before(:each) { visit item_page_path pg.item, pg }
      scenario 'includes an edit button' do
        expect(page).to have_link(I18n.t('meta.defaults.actions.edit'),
                                  href: edit_item_page_path(pg.item, pg))
      end
      scenario 'list all expected attributes' do
        expect(page).to have_text pg.number
        expect(page).to have_text pg.title
        expect(page).to have_text pg.fulltext
      end
    end
    context 'new' do
      before(:each) { visit new_item_page_path pg.item }
      scenario 'includes all expected form fields' do
        expect(page).to have_field I18n.t('activerecord.attributes.page.number')
        expect(page).to have_field I18n.t('activerecord.attributes.page.title')
        expect(page).to have_field(
          I18n.t('activerecord.attributes.page.fulltext')
        )
      end
      scenario 'shows a message on invalid save' do
        fill_in(I18n.t('activerecord.attributes.page.number'),
                with: pg.number)
        click_on I18n.t('meta.defaults.actions.save')
        expect(page).to have_text(
          I18n.t('meta.defaults.messages.errors.invalid_on_save',
                 entity: 'Page')
        )
      end
      scenario 'redirects to show on valid save' do
        new_number = pg.number.to_i + 1
        fill_in(I18n.t('activerecord.attributes.page.number'),
                with: new_number)
        click_on I18n.t('meta.defaults.actions.save')
        expect(page).to have_current_path item_page_path(pg.item, Page.last)
        expect(page).to have_text new_number
      end
    end
    context 'edit' do
      before(:each) { visit edit_item_page_path(pg.item, pg) }
      scenario 'includes all expected form fields and values' do
        expect(page).to have_field(
          I18n.t('activerecord.attributes.page.number'),
          with: pg.number
        )
        expect(page).to have_field(
          I18n.t('activerecord.attributes.page.title'),
          with: pg.title
        )
        expect(page).to have_field(
          I18n.t('activerecord.attributes.page.fulltext'),
          with: pg.fulltext
        )
      end
      scenario 'redirects to show on valid save' do
        click_on I18n.t('meta.defaults.actions.save')
        expect(page).to have_current_path item_page_path(pg.item, Page.last)
      end
    end
  end
end