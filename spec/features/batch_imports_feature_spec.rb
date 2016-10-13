require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Batch Importing Stuff' do

  let(:super_user) { Fabricate :super }
  let(:basic_user) { Fabricate :basic }
  let(:coordinator_user) { Fabricate :coordinator }
  let(:committer_user) { Fabricate :committer }
  let(:uploader_user) { Fabricate :uploader}

  let(:batch) { Fabricate :batch }
  let(:batch_import) { Fabricate :batch_import }
  let(:completed_batch_import) { Fabricate :completed_batch_import }

  context :uploader_user do

    before :each do
      login_as super_user, scope: :user
    end

    scenario 'can load the form to import some xml' do

      visit new_batch_batch_import_path(batch)

      expect(page).to have_field I18n.t('meta.batch.labels.import.xml_text')
      expect(page).to have_field I18n.t('meta.batch.labels.import.xml_file')


    end

    scenario 'can submit the form with some valid xml with one record' do

      visit new_batch_batch_import_path(batch)

      fill_in I18n.t('meta.batch.labels.import.xml_text'), with: batch_import.xml

      click_on I18n.t('meta.defaults.actions.save')

      # todo

    end

  end

end