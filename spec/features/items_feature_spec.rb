require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Item Management' do

  let(:super_user) { Fabricate :super }

  context 'for super user' do

    before :each do
      login_as super_user, scope: :user
    end

    scenario 'super user saves a new item with no other_collection value' do

      c1 = Fabricate(:collection) { items(count:1) }

      visit items_path

      click_on I18n.t('meta.defaults.actions.edit')

      fill_in I18n.t('activerecord.attributes.item.slug'),                  with: 'test'
      fill_in I18n.t('activerecord.attributes.item.dcterms_temporal'),      with: '2000'
      fill_in I18n.t('activerecord.attributes.item.dcterms_spatial'),       with: 'Georgia'
      fill_in I18n.t('activerecord.attributes.item.dcterms_type'),          with: 'Text'
      fill_in I18n.t('activerecord.attributes.item.dc_right'),              with: 'None'

      click_button I18n.t('meta.defaults.actions.save')

      expect(page).to have_current_path item_path(c1.items.first)

    end

    scenario 'super user saves a new item with other_collection value' do

      c1 = Fabricate(:collection) { items(count:1) }
      c2 = Fabricate(:collection)

      visit items_path

      click_on I18n.t('meta.defaults.actions.edit')

      fill_in I18n.t('activerecord.attributes.item.slug'),                  with: 'test'
      fill_in I18n.t('activerecord.attributes.item.dcterms_temporal'),      with: '2000'
      fill_in I18n.t('activerecord.attributes.item.dcterms_spatial'),       with: 'Georgia'
      fill_in I18n.t('activerecord.attributes.item.dcterms_type'),          with: 'Text'
      fill_in I18n.t('activerecord.attributes.item.dc_right'),              with: 'None'

      select c2.display_title, from: I18n.t('activerecord.attributes.item.other_collections')

      click_button I18n.t('meta.defaults.actions.save')

      expect(page).to have_current_path item_path(c1.items.first)

    end

    scenario 'super user saves a new item removing other_collection value' do

      c0 = Fabricate(:collection)
      c1 = Fabricate(:collection) {
        items(count:1)
      }

      c1.items.first.other_collections = [c0.id]

      visit items_path

      click_on I18n.t('meta.defaults.actions.edit')

      fill_in I18n.t('activerecord.attributes.item.slug'),                  with: 'test'
      fill_in I18n.t('activerecord.attributes.item.dcterms_temporal'),      with: '2000'
      fill_in I18n.t('activerecord.attributes.item.dcterms_spatial'),       with: 'Georgia'
      fill_in I18n.t('activerecord.attributes.item.dcterms_type'),          with: 'Text'
      fill_in I18n.t('activerecord.attributes.item.dc_right'),              with: 'None'

      select '', from: I18n.t('activerecord.attributes.item.other_collections')

      click_button I18n.t('meta.defaults.actions.save')

      expect(page).to have_current_path item_path(c1.items.first)

    end

    scenario 'user sorts items by title then sees items properly listed' do

      Fabricate(:item) { dcterms_title [ 'L' ] }
      Fabricate(:item) { dcterms_title [ 'F' ] }
      Fabricate(:item) { dcterms_title [ 'A' ] }
      Fabricate(:item) { dcterms_title [ 'Z' ] }
      Fabricate(:item) { dcterms_title [ 'Q' ] }
      Fabricate(:item) { dcterms_title [ '2' ] }

      visit items_path

      click_on I18n.t('meta.defaults.labels.columns.title')

      titles = []

      page.all('table tbody tr').each do |row|
        titles << row.all('td')[2].text
      end

      expect(titles).to eq %w(2 A F L Q Z)

    end

  end

end