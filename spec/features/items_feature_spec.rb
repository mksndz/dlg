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
    context 'batch_items listing for item' do
      scenario 'item created from batch_item should link to batch and batch_item
                from whence it came' do
        b = Fabricate(:batch) { batch_items(count: 1) }
        b.commit
        visit item_path(Item.last.id)
        expect(page).to have_text b.name
      end
    end
    context 'other_collection behavior' do
      scenario 'saves a new item with no other_collection value' do
        r = Fabricate(:repository)
        visit items_path
        click_on I18n.t('meta.defaults.actions.edit')
        chosen_select 'Text', from: 'dcterms-type-select'
        click_button I18n.t('meta.defaults.actions.save')
        expect(page).to have_current_path item_path(r.items.first)
      end
      scenario 'saves a new item with other_collection value' do
        c1 = Fabricate(:repository).collections.first
        c2 = Fabricate :empty_collection
        visit items_path
        click_on I18n.t('meta.defaults.actions.edit')
        chosen_select 'Text', from: 'dcterms-type-select'
        select(
          c2.display_title,
          from: I18n.t('activerecord.attributes.item.other_collections')
        )
        click_button I18n.t('meta.defaults.actions.save')
        expect(page).to have_current_path item_path(c1.items.first)
      end
      scenario 'saves a new item removing other_collection value' do
        c1 = Fabricate(:repository).collections.first
        Fabricate :empty_collection
        c1.items.first.other_collections = [c1.id]
        visit items_path
        click_on I18n.t('meta.defaults.actions.edit')
        chosen_select 'Text', from: 'dcterms-type-select'
        select '', from: I18n.t('activerecord.attributes.item.other_collections')
        click_button I18n.t('meta.defaults.actions.save')
        expect(page).to have_current_path item_path(c1.items.first)
      end
    end
    context 'portal behavior' do
      scenario 'portals are displayed as badges on index' do
        Fabricate(:item) { portals(count: 1) }
        visit items_path
        within 'tbody' do
          expect(page).to have_css '.label-primary'
        end
      end
      scenario 'saves a new item with no portal value' do
        r = Fabricate :repository
        visit items_path
        click_on I18n.t('meta.defaults.actions.edit')
        click_button I18n.t('meta.defaults.actions.save')
        expect(page).to have_current_path item_path(r.items.first)
      end
      # TODO redo after form and validation changes
      # scenario 'super user saves a new item with a multiple portal values' do
      #   c1 = Fabricate :empty_collection
      #   p1 = Fabricate :portal
      #   p2 = Fabricate :portal
      #   visit items_path
      #   click_on I18n.t('meta.defaults.actions.edit')
      #   select p1.name, from: I18n.t('activerecord.attributes.item.portal_ids')
      #   select p2.name, from: I18n.t('activerecord.attributes.item.portal_ids')
      #   click_button I18n.t('meta.defaults.actions.save')
      #   expect(page).to have_current_path item_path(c1.items.first)
      #   expect(page).to have_text p1.name
      #   expect(page).to have_text p2.name
      # end
      # scenario 'saves a new item removing portal value' do
      #   r = Fabricate :repository
      #   visit edit_item_path(r.items.first)
      #   within '#item_portal_ids_chosen' do
      #     find('.search-choice-close').click
      #   end
      #   click_button I18n.t('meta.defaults.actions.save')
      #   expect(page).to have_text I18n.t('activerecord.errors.messages.portal')
      # end
    end
    context 'sorting and limiting behavior' do
      scenario 'limited results show accurate total count' do
        Fabricate.times 2, :repository
        invalid_item = Item.last
        invalid_item.save(validate: false)
        visit items_path
        click_on I18n.t('meta.defaults.labels.columns.valid')
        counts = page.all('.index-filter-area .badge')
        expect(counts[0].text).to eq '2'
        expect(counts[1].text).to eq '2'
      end
      scenario 'sorts by validity status' do
        Fabricate.times 2, :repository
        invalid_item = Fabricate.build(:item) { dcterms_spatial [] }
        invalid_item.save(validate: false)
        visit items_path
        click_on I18n.t('meta.defaults.labels.columns.valid')
        titles = []
        page.all('table tbody tr').each do |row|
          titles << row.all('td')[2].text
        end
        expect(titles[0]).to eq invalid_item.title
      end
      scenario 'sorts items by title then sees items properly listed' do
        Fabricate.times 6, :repository
        items = Item.all
        %w(2 A F L Q Z).each_with_index do |e, i|
          items[i].dcterms_title = [e]
          items[i].save
        end
        visit items_path
        click_on I18n.t('meta.defaults.labels.columns.title')
        titles = []
        page.all('table tbody tr').each do |row|
          titles << row.all('td')[2].text
        end
        expect(titles).to eq %w(2 A F L Q Z)
      end
      scenario 'can limit to just items from a particular portal', js: true do
        i = Fabricate(:repository).items.first
        i2 = Fabricate(:repository).items.first
        p = Portal.first
        visit items_path
        chosen_select p.name, from: '_portal_id'
        find_button(I18n.t('meta.defaults.actions.filter')).click
        expect(page).to have_text i.dcterms_title.first
        expect(page).not_to have_text i2.dcterms_title.first
      end
      scenario 'can limit to just items from multiple portals' do
        Fabricate.times 3, :repository
        p1 = Portal.first
        p2 = Portal.second
        visit items_path
        chosen_select p1.name, from: '_portal_id'
        chosen_select p2.name, from: '_portal_id'
        find_button(I18n.t('meta.defaults.actions.filter')).click
        expect(page).to have_text Item.first.dcterms_title.first
        expect(page).to have_text Item.second.dcterms_title.first
        expect(page).not_to have_text Item.third.dcterms_title.first
      end
    end
    scenario 'can select and save a rights statement from a drop down' do
      item = Fabricate(:repository).items.first
      display_value = 'Rightsstatements.org - In Copyright'
      saved_value   = 'http://rightsstatements.org/vocab/InC/1.0/'
      visit edit_item_path item
      chosen_select display_value, from: 'dc-right-select'
      find('.fixed-save-button').click
      expect(page).to have_current_path item_path(item)
      expect(page).to have_content saved_value
    end
    scenario 'can select and save multiple DCMI Type values from a drop down' do
      item = Fabricate(:repository).items.first
      visit edit_item_path item
      new_type = 'MovingImage'
      chosen_select new_type, from: 'dcterms-type-select'
      find('.fixed-save-button').click
      expect(page).to have_current_path item_path(item)
      expect(page).to have_content new_type
    end
    context 'changing slug values and indexing' do
      before(:each) { Sunspot.remove_all Item, Collection }
      scenario 'changing a slug should not cause a duplicate record in the
                index' do
        item = Fabricate(:repository).items.first
        visit edit_item_path item
        fill_in I18n.t('activerecord.attributes.item.slug'), with: 'newslug'
        find('.fixed-save-button').click
        visit root_path
        fill_in 'title', with: ''
        click_button 'Search'
        expect(all('.edit-record').count).to eq 2
      end
    end
  end
end