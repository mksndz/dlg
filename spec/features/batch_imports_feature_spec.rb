require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

feature 'Batch Importing Batch Items' do

  let(:uploader_user) { Fabricate :uploader}
  let(:super_user) { Fabricate :super}

  context 'as an uploader user' do

    before :each do
      login_as uploader_user, scope: :user
    end

    context 'for a committed batch' do

      before(:each) do
        @batch = Fabricate :committed_batch
        @batch.user = uploader_user
        @batch.save
      end

      scenario 'the manage xml imports button should be displayed' do

        visit batch_path(@batch)

        expect(page).to have_link I18n.t('meta.batch.actions.batch_imports')

      end

      scenario 'the new import button should not be displayed' do

        visit batch_batch_imports_path(@batch)

        expect(page).not_to have_link I18n.t('meta.batch_import.action.new')

      end

    end

    context 'for a batch import from search results' do
      before :each do
        b = Fabricate :batch_from_search_results
        i = Fabricate :item
        b.batch_imports.first.item_ids = [i.id]
      end
      scenario 'a link to downlaod XML is shown on the index page' do
        batch = Batch.last
        visit batch_batch_imports_path(batch)
        expect(page).to have_button I18n.t('meta.batch_import.action.download_xml')
      end
    end

    context 'for an uncommited batch' do

      let(:dummy_xml) { '<xml></xml>' }

      before(:each) {
        @batch = Fabricate :batch
        @batch.user = uploader_user
        @batch.save
      }

      scenario 'can use the form to create a new batch import' do

        visit new_batch_batch_import_path(@batch)

        fill_in I18n.t('activerecord.attributes.batch_import.xml_text'), with: dummy_xml
        uncheck(I18n.t('activerecord.attributes.batch_import.validations'))
        check(I18n.t('activerecord.attributes.batch_import.match_on_id'))

        click_on I18n.t('meta.defaults.actions.save')

        expect(BatchImport.last.validations).to be false
        expect(BatchImport.last.match_on_id).to be true
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

        before(:each) do

          @batch_import = BatchImport.new(
            batch: @batch,
            user: uploader_user,
            xml: dummy_xml,
            format: 'text'
          )
          @batch_import.save

        end

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

  context 'as a super user' do

    before :each do
      login_as super_user, scope: :user
      ResqueSpec.reset!
      @batch = Fabricate :batch
      @robust_item = Fabricate :robust_item
    end

    let(:xml) { @robust_item.to_xml }

    context 'uploading xml with validates OFF' do

      before :each do
        visit new_batch_batch_import_path(@batch)
        fill_in I18n.t('activerecord.attributes.batch_import.xml_text'), with: xml
        uncheck(I18n.t('activerecord.attributes.batch_import.validations'))
        click_on I18n.t('meta.defaults.actions.save')
      end

      scenario 'batch_items records are created and no error messages displayed' do
        ResqueSpec.perform_all :xml
        visit batch_batch_import_path(@batch, BatchImport.last)
        expect(page).to have_text @robust_item.slug
        expect(page).not_to have_text 'Failed to import'
      end

    end

    scenario 'uploading xml and seeing the original filename' do

      bi = Fabricate :completed_batch_import_from_file
      bi.batch = @batch
      bi.save

      visit batch_batch_imports_path(@batch)

      expect(page).to have_text bi.file_name

    end

  end

end