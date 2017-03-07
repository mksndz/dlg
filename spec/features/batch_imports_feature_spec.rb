require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Batch Importing Batch Items' do

  let(:uploader_user) { Fabricate :uploader}

  before :each do
    login_as uploader_user, scope: :user
  end

  context 'as an uploader user' do

    context 'for a committed batch' do

      before(:each) {
        @batch = Fabricate :committed_batch
        @batch.user = uploader_user
        @batch.save
      }

      scenario 'the manage xml imports button should not be displayed' do

        visit batch_path(@batch)

        expect(page).not_to have_button I18n.t('meta.batch.actions.batch_imports')

      end

    end

    context 'for an uncommited batch' do

      let(:dummy_xml){ '<xml></xml>' }

      before(:each) {
        @batch = Fabricate :batch
        @batch.user = uploader_user
        @batch.save
      }

      scenario 'can use the form to create a new batch import' do

        visit new_batch_batch_import_path(@batch)

        fill_in I18n.t('activerecord.attributes.batch_import.xml_text'), with: dummy_xml
        uncheck(I18n.t('activerecord.attributes.batch_import.validations'))

        click_on I18n.t('meta.defaults.actions.save')

        expect(page).to have_current_path(batch_batch_import_path(@batch, BatchImport.last))
        expect(page).to have_text I18n.t('meta.batch_import.messages.success.created')

      end

      scenario 'gets an error when submitting an empty form' do

        visit new_batch_batch_import_path(@batch)

        click_on I18n.t('meta.defaults.actions.save')

        expect(page).to have_current_path(new_batch_batch_import_path(@batch))
        expect(page).to have_text I18n.t('meta.batch_import.messages.errors.no_data')

      end

      context 'and an incomplete batch import' do

        before(:each) {

          @batch_import = BatchImport.new( {
                              batch: @batch,
                              user: uploader_user,
                              xml: dummy_xml,
                              format: 'text'
                          } )
          @batch_import.save

        }

        scenario 'can see and click on button to manage XML imports' do

          visit batch_path(@batch)

          manage_xml_imports_link = I18n.t('meta.batch.actions.batch_imports')

          expect(page).to have_link manage_xml_imports_link

          click_on manage_xml_imports_link

          expect(page).to have_current_path batch_batch_imports_path(@batch)

        end

        scenario 'can view a listing of batch imports for a batch' do

          visit batch_batch_imports_path(@batch, @batch_import)

          expect(page).to have_link I18n.t('meta.batch_import.action.new')
          expect(page).to have_link I18n.t('meta.batch_import.action.info')
          expect(page).to have_link I18n.t('meta.batch_import.action.xml')
          expect(page).to have_link I18n.t('meta.defaults.actions.destroy')

          expect(page).to have_text uploader_user.email

        end

        scenario 'can view a batch import with details and actions' do

          visit batch_batch_import_path(@batch, @batch_import)

          expect(page).to have_link I18n.t('meta.batch_import.action.new')
          expect(page).to have_link I18n.t('meta.batch_import.action.xml')

          expect(page).to have_text uploader_user.email
          expect(page).to have_text @batch_import.format
          expect(page).to have_text @batch_import.created_at

        end

        scenario 'can go to and view provided XML' do

          visit batch_batch_import_path(@batch, @batch_import)

          click_on I18n.t('meta.batch_import.action.xml')

          expect(page).to have_text @batch_import.xml

        end

      end

    end

  end

end