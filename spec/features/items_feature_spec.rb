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
    context 'index page' do
      scenario 'shows a link to modify page information' do
        i = Fabricate :item_with_parents_and_pages
        visit items_path
        within 'a.pages-link' do
          have_text i.pages_count
        end
      end
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
        chosen_select 'Text', from: 'dcterms-type-select-multiple'
        click_button I18n.t('meta.defaults.actions.save')
        expect(page).to have_current_path item_path(r.items.first)
      end
      scenario 'saves a new item with other_collection value' do
        c1 = Fabricate(:repository).collections.first
        c2 = Fabricate :empty_collection
        visit items_path
        click_on I18n.t('meta.defaults.actions.edit')
        chosen_select 'Text', from: 'dcterms-type-select-multiple'
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
        chosen_select 'Text', from: 'dcterms-type-select-multiple'
        select '', from: I18n.t('activerecord.attributes.item.other_collections')
        click_button I18n.t('meta.defaults.actions.save')
        expect(page).to have_current_path item_path(c1.items.first)
      end
    end
    context 'portal behavior' do
      scenario 'portals are displayed as badges on index' do
        Fabricate :repository
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
      scenario 'saves a new item with a multiple portal values' do
        r = Fabricate :repository
        c = r.collections.first
        p1 = Fabricate :portal
        p2 = Fabricate :portal
        r.portals = r.portals << [p1, p2]
        c.portals << [p1, p2]
        visit edit_item_path Item.last
        select p1.name, from: I18n.t('activerecord.attributes.item.portal_ids')
        select p2.name, from: I18n.t('activerecord.attributes.item.portal_ids')
        click_button I18n.t('meta.defaults.actions.save')
        expect(page).to have_current_path item_path(c.items.first)
        expect(page).to have_text p1.name
        expect(page).to have_text p2.name
      end
      scenario 'only portals from parent collection are shown as options', js: true do
        c = Fabricate(:repository).collections.first
        p = Fabricate :portal
        visit edit_item_path c.items.first
        portal_options = find_all('#item_portal_ids_chosen').collect(&:text)
        expect(portal_options.count).to eq c.portals.count
        expect(portal_options.first).to eq c.portals.first.name
        expect(portal_options).not_to include p.name
      end
      scenario 'removing the only portal shows validation error', js: true do
        r = Fabricate :repository
        visit edit_item_path(r.items.first)
        within '#item_portal_ids_chosen' do
          find('.search-choice-close').click
        end
        click_button I18n.t('meta.defaults.actions.save')
        expect(page).to have_text I18n.t('activerecord.errors.messages.portal')
      end
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
        invalid_item = Item.last
        invalid_item.dcterms_title = []
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
    context 'edit behavior' do
      let(:item) { Fabricate(:repository).items.first }
      before(:each) do
        Fabricate(:holding_institution, authorized_name: 'DLG')
        visit edit_item_path item
      end
      scenario 'edit page has a fulltext field' do
        expect(page).to have_field I18n.t('activerecord.attributes.item.fulltext')
      end
      scenario 'fulltext field saves fulltext to item, redirects to show page with a link to the fulltext page' do
        fulltext = 'Test Fulltext'
        fill_in I18n.t('activerecord.attributes.item.fulltext'), with: fulltext
        find('.fixed-save-button').click
        expect(page).to have_current_path item_path item
        expect(page).to have_link I18n.t('activerecord.attributes.item.fulltext')
        click_on I18n.t('activerecord.attributes.item.fulltext')
        expect(page).to have_current_path fulltext_item_path item
        expect(page).to have_text fulltext
      end
      scenario 'can select and save a rights statement from a drop down' do
        display_value = 'Rightsstatements.org - In Copyright'
        saved_value   = 'http://rightsstatements.org/vocab/InC/1.0/'
        chosen_select display_value, from: 'dc-right-select'
        find('.fixed-save-button').click
        expect(page).to have_current_path item_path(item)
        expect(page).to have_content saved_value
      end
      scenario 'can select and save multiple DCMI Type values from a drop down' do
        new_type = 'MovingImage'
        chosen_select new_type, from: 'dcterms-type-select-multiple'
        find('.fixed-save-button').click
        expect(page).to have_current_path item_path(item)
        expect(page).to have_content new_type
      end
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