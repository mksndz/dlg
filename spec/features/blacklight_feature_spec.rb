require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Blacklight Functionality' do

  let(:super_user) { Fabricate :super }

  context 'for super user', js: true do

    before :each do
      login_as super_user, scope: :user
    end

    after :each do
      Sunspot.remove_all! Item
      Sunspot.remove_all! Collection
    end

    context 'show page' do

      context 'for Item' do

        before :each do
          Fabricate(:robust_item)
          Sunspot.commit_if_dirty
        end

        scenario 'includes all populated and indexed fields configured to show' do

          i = Item.last

          visit solr_document_path(i.record_id)

          expect(page).to have_text i.edm_is_shown_at.first
          expect(page).to have_text i.edm_is_shown_by.first
          expect(page).to have_text i.dcterms_identifier.first
          expect(page).to have_text i.dlg_subject_personal.first

        end

      end

      context 'for Collection' do

        before :each do
          Fabricate(:collection)
          Sunspot.commit_if_dirty
        end

        scenario 'includes all populated and indexed fields configured to show' do

          c = Collection.last

          visit solr_document_path(c.record_id)

          expect(page).to have_text c.display_title
          expect(page).to have_text c.short_description

        end

      end

    end

  end

end