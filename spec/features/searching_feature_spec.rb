require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Searching' do

  let(:super_user) { Fabricate :super }

  context 'for super user', js: true do

    before :each do
      login_as super_user, scope: :user
    end

    after :each do
      Sunspot.remove_all! Item
      Sunspot.remove_all! Collection
      Sunspot.remove_all! Repository
    end

    scenario 'does a search and results are returned' do

      Fabricate(:collection) { items(count:1 ) }
      Sunspot.commit

      visit root_path

      fill_in 'title', with: ''

      click_button 'Search'

      expect(page).to have_css('.document')

    end

    scenario 'does a search and can navigate the edit forms for the results across items and collections' do

      c = Fabricate(:collection) { items(count: 1) }
      Sunspot.commit

      visit root_path

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

    context 'result URL display behavior' do

      scenario 'item record dcterms_is_shown_at value displayed as URL link' do

        url = 'http://dlg.galileo.usg.edu'

        Fabricate(:item) {
          dcterms_is_shown_at [url]
        }

        Sunspot.commit

        visit blacklight_advanced_search_engine.advanced_search_path
        click_button 'Search'

        expect(page).to have_css('dt.blacklight-dcterms_is_shown_at_display', text: "#{I18n.t('meta.search.labels.dcterms_is_shown_at')}:")
        expect(page).to have_css('dd.blacklight-dcterms_is_shown_at_display', text: url)
        expect(page).to have_link url

      end

      scenario 'item record dcterms_identifier value is displayed as Identifier link' do

        url = 'http://dlg.galileo.usg.edu'

        Fabricate(:item) {
          dcterms_identifier [url]
        }
        Sunspot.commit

        visit blacklight_advanced_search_engine.advanced_search_path
        click_button 'Search'

        expect(page).to have_selector('dt.blacklight-dcterms_identifier_display', text: "#{I18n.t('meta.search.labels.dcterms_identifier')}:")
        expect(page).to have_css('dd.blacklight-dcterms_identifier_display', text: url)

        expect(page).to have_link url

      end

    end

    context 'advanced searching functionality' do

      scenario 'all fields search returns results' do

        i = Fabricate(:item)
        Sunspot.commit

        visit blacklight_advanced_search_engine.advanced_search_path

        fill_in 'all_fields', with: i.dcterms_title.last

        click_button 'Search'

        expect(all('.edit-record').count).to eq 1

      end

      scenario 'slug search returns relevant results based on substrings' do

        Fabricate(:item) {
          slug 'polyester'
        }
        Sunspot.commit

        visit blacklight_advanced_search_engine.advanced_search_path

        fill_in 'slug', with: 'ester'

        click_button 'Search'

        expect(all('.edit-record').count).to eq 1

      end

      context 'facet behavior' do

        scenario 'there exists a portals facet' do

          Fabricate(:item) {
            portals(count: 1)
          }

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          expect(page).to have_text I18n.t('meta.search.facets.portals')

        end

        scenario 'advanced search facets are not limited to 11' do

          Fabricate.times(20, :item)

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          find('#repository_name_sms_chosen').click

          expect(page).to have_text(Repository.first.title)
          expect(page).to have_text(Repository.last.title)

        end

      end

      context 'dublin core terms' do

        before :each do
          Fabricate(:collection){ items(count:10) }
        end

        scenario 'title search returns only relevant results' do

          Fabricate(:item) {
            dcterms_title ['ZZZZZZZZZZ']
          }

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          fill_in 'title', with: 'ZZZZZZZZZZ'

          click_button 'Search'

          expect(all('.edit-record').count).to eq 1

        end

        scenario 'creator search returns only relevant results' do

          Fabricate(:item) {
            dcterms_creator ['ZZZZZZZZZZ']
          }

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          fill_in 'creator', with: 'ZZZZZZZZZZ'

          click_button 'Search'

          expect(all('.edit-record').count).to eq 1

        end

        scenario 'contributor search returns only relevant results' do

          Fabricate(:item) {
            dcterms_contributor ['ZZZZZZZZZZ']
          }

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          fill_in 'contributor', with: 'ZZZZZZZZZZ'

          click_button 'Search'

          expect(all('.edit-record').count).to eq 1

        end

        scenario 'subject search returns only relevant results' do

          Fabricate(:item) {
            dcterms_subject ['ZZZZZZZZZZ']
          }

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          fill_in 'subject', with: 'ZZZZZZZZZZ'

          click_button 'Search'

          expect(all('.edit-record').count).to eq 1

        end

        scenario 'description search returns only relevant results' do

          Fabricate(:item) {
            dcterms_description ['ZZZZZZZZZZ']
          }

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          fill_in 'description', with: 'ZZZZZZZZZZ'

          click_button 'Search'

          expect(all('.edit-record').count).to eq 1

        end

        scenario 'publisher search returns only relevant results' do

          Fabricate(:item) {
            dcterms_publisher ['ZZZZZZZZZZ']
          }

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          fill_in 'publisher', with: 'ZZZZZZZZZZ'

          click_button 'Search'

          expect(all('.edit-record').count).to eq 1

        end

        scenario 'date search returns only relevant results' do

          Fabricate(:item) {
            dc_date ['ZZZZZZZZZZ']
          }

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          fill_in 'date', with: 'ZZZZZZZZZZ'

          click_button 'Search'

          expect(all('.edit-record').count).to eq 1

        end

        scenario 'temporal search returns only relevant results' do

          Fabricate(:item) {
            dcterms_temporal ['9999']
          }

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          fill_in 'temporal', with: '9999'

          click_button 'Search'

          expect(all('.edit-record').count).to eq 1

        end

        scenario 'spatial search returns only relevant results' do

          Fabricate(:item) {
            dcterms_spatial ['ZZZZZZZZZZ']
          }

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          fill_in 'spatial', with: 'ZZZZZZZZZZ'

          click_button 'Search'

          expect(all('.edit-record').count).to eq 1

        end

        scenario 'is part of search returns only relevant results' do

          Fabricate(:item) {
            dcterms_is_part_of ['ZZZZZZZZZZ']
          }

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          fill_in 'is_part_of', with: 'ZZZZZZZZZZ'

          click_button 'Search'

          expect(all('.edit-record').count).to eq 1

        end

        scenario 'is shown at search returns only relevant results' do

          Fabricate(:item) {
            dcterms_is_shown_at ['ZZZZZZZZZZ']
          }

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          fill_in 'is_shown_at', with: 'ZZZZZZZZZZ'

          click_button 'Search'

          expect(all('.edit-record').count).to eq 1

        end

        scenario 'is shown at search returns results using a part of the url hierarchy' do

          Fabricate(:item) {
            dcterms_is_shown_at ['http://dlg.galileo.usg.edu/Topics/GovernmentPolitics.html']
          }

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          fill_in 'is_shown_at', with: 'http://dlg.galileo.usg.edu'

          click_button 'Search'

          expect(all('.edit-record').count).to eq 1

        end

        scenario 'identifier search returns only relevant results' do

          Fabricate(:item) {
            dcterms_identifier ['ZZZZZZZZZZ']
          }

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          fill_in 'identifier', with: 'ZZZZZZZZZZ'

          click_button 'Search'

          expect(all('.edit-record').count).to eq 1

        end

        scenario 'identifier search returns results using a part of the url hierarchy' do

          Fabricate(:item) {
            dcterms_identifier ['http://dlg.galileo.usg.edu/Topics/GovernmentPolitics.html']
          }

          Sunspot.commit

          visit blacklight_advanced_search_engine.advanced_search_path

          fill_in 'identifier', with: 'http://dlg.galileo.usg.edu'

          click_button 'Search'

          expect(all('.edit-record').count).to eq 1

        end

      end

    end

  end

  context 'for basic user' do

    scenario '' do



    end

  end

end