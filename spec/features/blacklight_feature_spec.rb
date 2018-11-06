require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Blacklight Functionality' do
  context 'for super user' do
    before :each do
      login_as Fabricate(:super), scope: :user
    end
    after :each do
      Sunspot.remove_all! Item
      Sunspot.remove_all! Collection
    end
    context 'show page' do
      context 'for Item' do
        before :each do
          Fabricate :collection_with_repo_and_robust_item
          Sunspot.commit
          @item = Item.last
          visit solr_document_path(@item.record_id)
        end
        scenario 'includes all populated and indexed fields configured to
                  show' do
          expect(page).to have_text @item.edm_is_shown_at.first
          expect(page).to have_text @item.edm_is_shown_by.first
          expect(page).to have_text @item.dcterms_identifier.first
          expect(page).to have_text @item.dlg_subject_personal.first
        end
        scenario 'includes link to edit Item' do
          expect(page).to have_link(
            I18n.t('meta.defaults.actions.edit'),
            href: edit_item_path(@item)
          )
        end
        context 'is_part_of special linkification' do
          before :each do
            item = Fabricate(:item_with_parents,
                             dcterms_is_part_of: [
                               'Visit our home at https://mocaga.pastperfectonline.com/archive/ECB9517F-A5D9-4569-9C88-451577396987',
                               'No link here!'
                             ])
            Sunspot.commit
            visit solr_document_path(item.record_id)
          end
          scenario 'item is_part_of field should turn things that look like
                    links into links' do
            expect(page).to have_link 'https://mocaga.pastperfectonline.com/archive/ECB9517F-A5D9-4569-9C88-451577396987'
          end
        end
      end
      context 'for Collection' do
        before :each do
          Fabricate :empty_collection
          Sunspot.commit
          @collection = Collection.last
          visit solr_document_path(@collection.record_id)
        end
        scenario 'includes all populated and indexed fields configured to
                  show' do
          expect(page).to have_text @collection.display_title
          expect(page).to have_text @collection.short_description
        end
        scenario 'includes a link to edit the Collection' do
          expect(page).to have_link(
            I18n.t('meta.defaults.actions.edit'),
            href: edit_collection_path(@collection)
          )
        end
      end
    end
  end
end