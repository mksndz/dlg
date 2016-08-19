require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Document' do

  let(:super_user) { Fabricate :super }

  context 'for super user' do

    before :each do
      login_as super_user, scope: :user
    end

    scenario 'document view shows a rights icon that links to the uri' do

      i = Fabricate :item
      Sunspot.commit

      visit solr_document_path(i.record_id)

      expect(page).to have_css '.rights-statement-icon'
      expect(page).to have_xpath '//a[@href = "' + i.dc_right.first + '"]'

    end

  end

  context 'for basic user' do

    scenario '' do


    end

  end

end