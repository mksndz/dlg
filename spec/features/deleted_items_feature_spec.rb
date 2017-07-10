require 'rails_helper'
require 'chosen-rails/rspec'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Item Management' do

  let(:super_user) { Fabricate :super }

  context 'for super user' do

    before :each do
      login_as super_user, scope: :user
      PaperTrail.enabled = true
    end

    context 'deleted items index' do

      scenario 'should show only deleted items, not updated items' do

        item = Fabricate :item
        item2 = Fabricate :item

        item2_title = item2.dcterms_title.first

        item2.destroy

        old_item_title = item.dcterms_title.first

        item.dcterms_title = ['New Item Title']
        item.save

        visit deleted_items_path

        expect(page).not_to have_text old_item_title
        expect(page).to have_text item2_title

      end

    end

  end

end