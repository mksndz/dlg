require 'rails_helper'
require 'devise/test_helpers'

RSpec.describe BatchImportsController, type: :controller do

  before(:each) do
    sign_in Fabricate(:super)
  end

  let(:batch) { Fabricate :batch }

  test_xml = '<?xml version="1.0" encoding="UTF-8"?>
      <items type="array">
        <item>
          <dpla type="boolean">true</dpla>
          <public type="boolean">true</public>
          <dc_format type="array">
            <dc_format>application/pdf</dc_format>
          </dc_format>
          <dc_right type="array"/>
          <dc_date type="array">
            <dc_date>1915-06-22/1915-06-30</dc_date>
          </dc_date>
          <dc_relation type="array"/>
          <slug>ahc0091-002-004</slug>
          <dcterms_medium type="array">
            <dcterms_medium>Letters (correspondence)</dcterms_medium>
          </dcterms_medium>
          <dcterms_identifier type="array">
            <dcterms_identifier>http://dlg.galileo.usg.edu/ahc/leofrank/do:ahc0091-002-004</dcterms_identifier>
          </dcterms_identifier>
          <dcterms_language type="array"/>
          <dcterms_spatial type="array">
            <dcterms_spatial>United States, Georgia, Fulton County, Atlanta, 33.7489954, -84.3879824</dcterms_spatial>
          </dcterms_spatial>
          <dcterms_publisher type="array">
            <dcterms_publisher>Box 2 Folder 4, Leo Frank papers, MSS 91, Kenan Research Center at the Atlanta History Center.</dcterms_publisher>
          </dcterms_publisher>
          <dcterms_rights_holder type="array"/>
          <dcterms_subject type="array">
            <dcterms_subject>Jews--Georgia--Atlanta</dcterms_subject>
          </dcterms_subject>
          <dcterms_temporal type="array"/>
          <dcterms_title type="array">
            <dcterms_title>Letters of sympathy and support to Leo Frank, 1915 June 22 - June 30</dcterms_title>
          </dcterms_title>
          <dcterms_type type="array">
            <dcterms_type>Text</dcterms_type>
          </dcterms_type>
          <dcterms_is_shown_at type="array">
            <dcterms_is_shown_at>http://dlg.galileo.usg.edu/id:geh_0091_ahc0091-002-004</dcterms_is_shown_at>
          </dcterms_is_shown_at>
          <dcterms_provenance type="array">
            <dcterms_provenance>Atlanta History Center</dcterms_provenance>
          </dcterms_provenance>
          <valid_item type="boolean">true</valid_item>
          <has_thumbnail type="boolean">false</has_thumbnail>
          <dcterms_bibliographic_citation type="array">
            <dcterms_bibliographic_citation>Cite as: Leo Frank papers, MSS 91, Kenan Research Center at the Atlanta History Center.</dcterms_bibliographic_citation>
          </dcterms_bibliographic_citation>
          <collection>
            <slug>0091</slug>
          </collection>
        </item>
      </items>'


  describe 'GET #new' do

    it 'assigns a new batch_import as @batch_import' do
      get :new, { batch_id: batch.id }
      expect(assigns(:batch_import)).to be_a_new(BatchImport)
    end

  end

  describe 'POST #create' do

    context 'with valid params' do

      it 'enqueues a job and redirects to show using XML' do
        post :create, { batch_id: batch.id, batch_import: { xml: test_xml } }
        expect(assigns(:batch_import)).to eq BatchImport.last
      end

      it 'enqueues a job and redirects to show using item IDs' do
        post :create, { batch_id: batch.id, batch_import: { item_ids: '1,2' } }
        expect(assigns(:batch_import)).to eq BatchImport.last
      end

    end

  end

end
