require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'XML Import' do

  context :uploader_user do

    let :uploader_user do
      Fabricate :uploader
    end

    before :each do
      login_as uploader_user, scope: :user
    end

    scenario 'uploader user sees a button to import XML and can load the form' do

      batch = Fabricate :batch
      batch.user = uploader_user
      batch.save

      visit edit_batch_path(batch)

      expect(page).to have_link I18n.t('meta.batch.actions.populate_with_xml')

      click_on I18n.t('meta.batch.actions.populate_with_xml')

      expect(page).to have_text I18n.t('meta.batch.labels.import.xml_file') # todo
      expect(page).to have_field I18n.t('meta.batch.labels.import.xml_text')
      expect(page).to have_field I18n.t('meta.batch.labels.import.bypass_validations')

    end

  end

end