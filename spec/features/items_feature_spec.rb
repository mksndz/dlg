require 'rails_helper'
require 'chosen-rails/rspec'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Item Management' do

  let(:super_user) { Fabricate :super }

  context 'for super user' do

    before :each do
      login_as super_user, scope: :user
    end

    context 'other_collection behavior' do

      scenario 'saves a new item with no other_collection value' do

        c1 = Fabricate(:collection) { items(count:1) }

        visit items_path

        click_on I18n.t('meta.defaults.actions.edit')

        fill_in I18n.t('activerecord.attributes.item.slug'), with: 'test'
        fill_in I18n.t('activerecord.attributes.item.dcterms_temporal'), with: '2000'
        fill_in I18n.t('activerecord.attributes.item.dcterms_spatial'), with: 'Georgia'
        chosen_select 'Text', from: 'dcterms-type-select'

        click_button I18n.t('meta.defaults.actions.save')

        expect(page).to have_current_path item_path(c1.items.first)

      end

      scenario 'super user saves a new item with other_collection value' do

        c1 = Fabricate(:collection) { items(count:1) }
        c2 = Fabricate(:collection)

        visit items_path

        click_on I18n.t('meta.defaults.actions.edit')

        fill_in I18n.t('activerecord.attributes.item.slug'), with: 'test'
        fill_in I18n.t('activerecord.attributes.item.dcterms_temporal'), with: '2000'
        fill_in I18n.t('activerecord.attributes.item.dcterms_spatial'), with: 'Georgia'
        chosen_select 'Text', from: 'dcterms-type-select'

        select c2.display_title, from: I18n.t('activerecord.attributes.item.other_collections')

        click_button I18n.t('meta.defaults.actions.save')

        expect(page).to have_current_path item_path(c1.items.first)

      end

      scenario 'saves a new item removing other_collection value' do

        c0 = Fabricate(:collection)
        c1 = Fabricate(:collection) {
          items(count:1)
        }

        c1.items.first.other_collections = [c0.id]

        visit items_path

        click_on I18n.t('meta.defaults.actions.edit')

        fill_in I18n.t('activerecord.attributes.item.slug'), with: 'test'
        fill_in I18n.t('activerecord.attributes.item.dcterms_temporal'), with: '2000'
        fill_in I18n.t('activerecord.attributes.item.dcterms_spatial'), with: 'Georgia'
        chosen_select 'Text', from: 'dcterms-type-select'

        select '', from: I18n.t('activerecord.attributes.item.other_collections')

        click_button I18n.t('meta.defaults.actions.save')

        expect(page).to have_current_path item_path(c1.items.first)

      end

      context 'portal behavior' do

        scenario 'saves a new item with no portal value' do

          c1 = Fabricate(:collection) { items(count:1) }

          visit items_path

          click_on I18n.t('meta.defaults.actions.edit')

          fill_in I18n.t('activerecord.attributes.item.slug'), with: 'test'
          fill_in I18n.t('activerecord.attributes.item.dcterms_temporal'), with: '2000'
          fill_in I18n.t('activerecord.attributes.item.dcterms_spatial'), with: 'Georgia'
          chosen_select 'Text', from: 'dcterms-type-select'

          click_button I18n.t('meta.defaults.actions.save')

          expect(page).to have_current_path item_path(c1.items.first)

        end

        scenario 'super user saves a new item with a single portal value' do

          c1 = Fabricate(:collection) { items(count:1) }

          p = Fabricate(:portal)

          visit items_path

          click_on I18n.t('meta.defaults.actions.edit')

          fill_in I18n.t('activerecord.attributes.item.slug'), with: 'test'
          fill_in I18n.t('activerecord.attributes.item.dcterms_temporal'), with: '2000'
          fill_in I18n.t('activerecord.attributes.item.dcterms_spatial'), with: 'Georgia'
          chosen_select 'Text', from: 'dcterms-type-select'

          select p.name, from: I18n.t('activerecord.attributes.item.portal_ids')

          click_button I18n.t('meta.defaults.actions.save')

          expect(page).to have_current_path item_path(c1.items.first)

        end

        scenario 'super user saves a new item with a multiple portal values' do

          c1 = Fabricate(:collection) { items(count:1) }

          p1 = Fabricate(:portal)
          p2 = Fabricate(:portal)

          visit items_path

          click_on I18n.t('meta.defaults.actions.edit')

          fill_in I18n.t('activerecord.attributes.item.slug'), with: 'test'
          fill_in I18n.t('activerecord.attributes.item.dcterms_temporal'), with: '2000'
          fill_in I18n.t('activerecord.attributes.item.dcterms_spatial'), with: 'Georgia'
          chosen_select 'Text', from: 'dcterms-type-select'

          select p1.name, from: I18n.t('activerecord.attributes.item.portal_ids')
          select p2.name, from: I18n.t('activerecord.attributes.item.portal_ids')

          click_button I18n.t('meta.defaults.actions.save')

          expect(page).to have_current_path item_path(c1.items.first)
          expect(page).to have_text p1.name
          expect(page).to have_text p2.name

        end

        scenario 'saves a new item removing other_collection value' do

          c = Fabricate(:collection) {
            items(count:1)
          }

          p = Fabricate :portal

          c.items.first.portals = [p]

          visit items_path

          click_on I18n.t('meta.defaults.actions.edit')

          fill_in I18n.t('activerecord.attributes.item.slug'), with: 'test'
          fill_in I18n.t('activerecord.attributes.item.dcterms_temporal'), with: '2000'
          fill_in I18n.t('activerecord.attributes.item.dcterms_spatial'), with: 'Georgia'
          chosen_select 'Text', from: 'dcterms-type-select'

          select '', from: I18n.t('activerecord.attributes.item.portal_ids')

          click_button I18n.t('meta.defaults.actions.save')

          expect(page).to have_current_path item_path(c.items.first)

        end

      end

    end

    scenario 'sorts items by title then sees items properly listed' do

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

    scenario 'can select and save a rights statement from a drop down' do

      item = Fabricate :item

      display_value = 'Rightsstatements.org - In Copyright'
      saved_value   = 'http://rightsstatements.org/vocab/InC/1.0/'

      visit edit_item_path item

      chosen_select display_value, from: 'dc-right-select'

      find('.fixed-save-button').click

      expect(page).to have_current_path item_path(item)
      expect(page).to have_content saved_value

    end

    scenario 'can select and save multiple DCMI Type values from a drop down' do

      item = Fabricate :item

      visit edit_item_path item

      new_type = 'MovingImage'

      chosen_select new_type, from: 'dcterms-type-select'

      find('.fixed-save-button').click

      expect(page).to have_current_path item_path(item)
      expect(page).to have_content new_type

    end

  end

end