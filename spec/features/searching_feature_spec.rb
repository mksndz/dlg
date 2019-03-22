require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Searching' do
  let(:basic_user) { Fabricate :basic }
  context 'for super user' do
    before :each do
      login_as Fabricate(:super), scope: :user
    end
    after :each do
      Sunspot.remove_all! Item
      Sunspot.remove_all! Collection
      Sunspot.remove_all! Repository
    end
    context 'simple behaviors' do
      before :each do
        Fabricate :repository
        Sunspot.commit
        visit root_path
      end
      scenario 'does a search and results are returned' do
        fill_in 'title', with: ''
        click_button 'Search'
        expect(page).to have_css('.document')
      end
      scenario 'does a search and can navigate the edit forms for the results
                across items and collections', js: true do
        fill_in 'title', with: ''
        click_button 'Search'
        expect(all('.edit-record').count).to eq 2
        first('.edit-record').click
        expect(page).to have_link 'Next Result'
        expect(page).not_to have_link 'Previous Result'
        click_on 'Next Result'
        expect(page).not_to have_link 'Next Result'
        expect(page).to have_link 'Previous Result'
      end
      scenario 'deleted items are removed from the index and not displayed' do
        Item.first.destroy
        Sunspot.commit
        fill_in 'title', with: ''
        click_button 'Search'
        expect(all('.edit-record').count).to eq 1
      end
    end
    context 'xml generating functionality' do
      scenario 'items are selected and xml is generated', js: true do
        item = Fabricate(:repository).items.first
        item2 = Fabricate(:repository).items.first
        Sunspot.commit
        visit search_catalog_path
        click_button 'Search'
        check "select-#{item.id}"
        check "select-#{item2.id}"
        click_button I18n.t('meta.app.action_widget.name')
        page.switch_to_window(window_opened_by { click_on I18n.t('meta.app.action_widget.xml') } )
        expect(page).to have_current_path xml_items_path(format: :xml)
        expect(page.html).to include item.slug
        expect(page.html).to include item2.slug
      end
    end
    context 'display value and public value inheritance', js: true do
      before :each do
        ResqueSpec.reset!
      end
      scenario 'an item whose repository is not public is display: false' do
        Fabricate :repository
        Sunspot.commit
        visit root_path
        fill_in 'title', with: ''
        click_button 'Search'
        display_values = all('dd.blacklight-display_ss')
        display_values.each do |v|
          expect(v.text).to eq 'No'
        end
      end
      scenario 'an item whose collection is not public is display: false' do
        Fabricate :repository_public_true
        item = Item.last
        item.public = true
        item.save
        Sunspot.commit
        visit root_path
        fill_in 'title', with: ''
        click_button 'Search'
        display_values = all('dd.blacklight-display_ss')
        display_values.each do |v|
          expect(v.text).to eq 'No'
        end
      end
      scenario 'an item whose repo and coll are not public is display: false' do
        Fabricate :repository
        item = Item.last
        item.public = true
        item.save
        Sunspot.commit
        visit root_path
        fill_in 'title', with: ''
        click_button 'Search'
        display_values = all('dd.blacklight-display_ss')
        display_values.each do |v|
          expect(v.text).to eq 'No'
        end
      end
      scenario 'an item, repo and coll are public: true then the item and coll are display: true' do
        Fabricate :repository_public_true
        item = Item.last
        item.public = true
        item.save
        collection = Collection.last
        collection.public = true
        collection.save
        ResqueSpec.perform_all :resave
        ResqueSpec.perform_all :reindex
        Sunspot.commit
        visit root_path
        fill_in 'title', with: ''
        click_button 'Search'
        display_values = all('dd.blacklight-display_ss')
        display_values.each do |v|
          expect(v.text).to eq 'Yes'
        end
      end
      scenario 'an item is display: true after its repo is switched' do
        Fabricate :repository
        item = Item.last
        item.public = true
        item.save
        collection = Collection.last
        collection.public = true
        collection.save
        repository = Repository.last
        repository.public = true
        repository.save
        ResqueSpec.perform_all :resave
        ResqueSpec.perform_all :reindex
        Sunspot.commit
        visit root_path
        fill_in 'title', with: ''
        click_button 'Search'
        display_values = all('dd.blacklight-display_ss')
        display_values.each do |v|
          expect(v.text).to eq 'Yes'
        end
      end
      scenario 'an item is display: true after its public value is switched' do
        Fabricate :repository_public_true
        collection = Collection.last
        collection.public = true
        collection.save
        ResqueSpec.perform_all :resave
        ResqueSpec.perform_all :reindex
        item = Item.last
        item.public = true
        item.save
        ResqueSpec.perform_all :resave
        ResqueSpec.perform_all :reindex
        Sunspot.commit
        visit root_path
        fill_in 'title', with: ''
        click_button 'Search'
        display_values = all('dd.blacklight-display_ss')
        display_values.each do |v|
          expect(v.text).to eq 'Yes'
        end
      end
    end
    context 'results validity display' do
      scenario 'invalid items are shown as such' do
        Fabricate :repository
        item = Item.last
        item.dcterms_title = []
        item.save(validate: false)
        Sunspot.commit
        visit root_path
        fill_in 'title', with: ''
        click_button 'Search'
        validity_dd = find('dd.blacklight-valid_item_ss')
        expect(validity_dd.text).to eq 'No'
      end
      scenario 'valid items are shown as such' do
        Fabricate :repository
        Sunspot.commit
        visit root_path
        fill_in 'title', with: ''
        click_button 'Search'
        validity_dd = find('dd.blacklight-valid_item_ss')
        expect(validity_dd.text).to eq 'Yes'
      end
    end
    context 'result URL display behavior' do
      before :each do
        Fabricate :collection_with_repo_and_robust_item
        Sunspot.commit
        visit blacklight_advanced_search_engine.advanced_search_path
        click_button 'Search'
      end
      scenario 'item record edm_is_shown_at value displayed as URL link' do
        expect(page).to have_css(
          'dt.blacklight-edm_is_shown_at_display',
          text: "#{I18n.t('meta.search.labels.edm_is_shown_at')}:"
        )
        expect(page).to have_css(
          'dd.blacklight-edm_is_shown_at_display',
          text: 'http://dlg.galileo.usg.edu')
        expect(page).to have_link 'http://dlg.galileo.usg.edu'
      end
      scenario 'item record edm_is_shown_by value displayed as URL link' do
        expect(page).to have_css(
          'dt.blacklight-edm_is_shown_by_display',
          text: "#{I18n.t('meta.search.labels.edm_is_shown_by')}:"
        )
        expect(page).to have_css(
          'dd.blacklight-edm_is_shown_by_display',
          text: 'http://dlg.galileo.usg.edu'
        )
        expect(page).to have_link 'http://dlg.galileo.usg.edu'
      end
      # TODO: should we expect identifier to be a URL?
      # scenario 'item record dcterms_identifier value is displayed as Identifier link' do
      #   expect(page).to have_selector('dt.blacklight-dcterms_identifier_display', text: "#{I18n.t('meta.search.labels.dcterms_identifier')}:")
      #   expect(page).to have_css('dd.blacklight-dcterms_identifier_display', text: url)
      #   expect(page).to have_link url
      # end
    end
    context 'other_* display' do
      scenario 'with an other_collection value' do
        Fabricate :repository
        i = Item.last
        i.other_collections << Fabricate(:empty_collection, repository: Repository.last, portals: i.portals).id
        i.save
        Sunspot.commit
        visit blacklight_advanced_search_engine.advanced_search_path
        fill_in 'record_id', with: i.record_id
        click_button 'Search'
        repo_name_dd = find_all('dd.blacklight-repository_name_sms')[0].text
        expect(repo_name_dd.scan(/Repo/).length).to eq 1
      end
    end
    context 'add to batch functionality' do
      context 'when everything goes smoothly' do
        before :each do
          Fabricate.times(3, :repository)
          Fabricate :batch
          Sunspot.commit
          visit blacklight_advanced_search_engine.advanced_search_path
          click_button 'Search'
        end
        scenario 'actions drop down shows an option to "add to batch"', js: true do
          click_button I18n.t('meta.app.action_widget.name')
          within '#action-dropdown' do
            expect(page).to have_link I18n.t('meta.app.action_widget.batch')
          end
        end
        scenario 'clicking "add to batch" with no records selected shows an
                  alert', js: true do
          click_button I18n.t('meta.app.action_widget.name')
          page.accept_confirm 'Please select at least one record to perform this action' do
            click_on I18n.t('meta.app.action_widget.batch')
          end
        end
        scenario 'selecting a record and add it to a batch', js: true do
          find("#select-#{Item.last.id}").click
          batch = Batch.last
          click_button I18n.t('meta.app.action_widget.name')
          click_on I18n.t('meta.app.action_widget.batch')
          expect(page).to have_selector('#ajax-modal', visible: true)
          expect(page).to have_selector('ul.list-group')
          expect(page).to have_selector('li.list-group-item', count: 1)
          expect(page).to have_button(batch.name)
          batch_button = find_button(batch.name)
          batch_button.click
          expect(page).to have_link(
            'here',
            href: batch_batch_imports_path(batch)
          )
        end
      end
    end
    context 'field truncation on index page behavior' do
      before :each do
        big_description = []
        600.times { big_description << '0123456789' }
        item = Fabricate(:repository).items.first
        item.dcterms_description = [big_description.join(' ')]
        item.save
        Sunspot.commit
        visit root_path
        fill_in 'title', with: ''
        click_button 'Search'
      end
      scenario 'description field is truncated and contains no <br> tags' do
        description_displayed = find('dd.blacklight-dcterms_description_display').text
        expect(description_displayed.length).to eq 2500
        expect(description_displayed).to include I18n.t('meta.search.index.truncated_field')
      end
    end
  end
  context 'for basic user' do
    let(:basic_user) { Fabricate :basic }
    before :each do
      login_as basic_user, scope: :user
    end
    context 'edit button and checkbox functionality' do
      before :each do
        Fabricate :collection_with_repo_and_item
        Fabricate :collection_with_repo_and_item
        basic_user.collections << Collection.last
        Sunspot.commit
        visit root_path
        fill_in 'title', with: ''
        click_button 'Search'
      end
      scenario 'edit buttons, checkboxes and action menu are displayed' do
        expect(page).to have_link 'Edit'
        expect(page).to have_link 'Show'
        expect(page).to have_css 'input.action-item'
        expect(page).to have_button I18n.t('meta.app.action_widget.name')
      end
      scenario 'user sees an error when trying to edit item from unassigned
                collection' do
        find("a[href='#{edit_item_path(Collection.first.items.first)}']").click
        expect(page).to have_text I18n.t('unauthorized.manage.all', { action: :edit, subject: :item })
      end
      scenario 'user sees an error when trying to edit item from unassigned
                collection' do
        find("a[href='#{edit_item_path(Collection.last.items.first)}']").click
        expect(page).to have_current_path edit_item_path(Collection.last.items.first)
      end
      scenario 'user does not see the action to delete checked items' do
        expect(page).not_to have_link multiple_destroy_items_path
      end
    end
    context 'thumbnails rendering' do
      before :each do
        @collection = Fabricate :collection_with_repo_and_item
        Sunspot.commit
        visit blacklight_advanced_search_engine.advanced_search_path
        click_button 'Search'
      end
      scenario 'items have a thumbnail built from slugs' do
        item = Item.last
        image_url = "https://dlg.galileo.usg.edu/#{item.repository.slug}/#{item.collection.slug}/do-th:#{item.slug}"
        within '.document-position-1' do
          expect(page).to have_xpath("//img[contains(@src,\"#{image_url}\")]")
        end
      end
      scenario 'collections have thumbnails inherited from the repository' do
        within '.document-position-0' do
          expect(page.html).to include "https://dlg.galileo.usg.edu/do-th:#{@collection.repository.slug}"
        end
      end
    end
  end
end