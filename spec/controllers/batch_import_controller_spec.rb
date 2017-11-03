require 'rails_helper'
require 'devise/test_helpers'

RSpec.describe BatchImportsController, type: :controller do
  before(:each) { sign_in Fabricate(:super) }
  let(:batch) { Fabricate :batch }
  let(:committed_batch) { Fabricate :committed_batch }
  let(:test_xml) do
    <<-XML
    <?xml version="1.0" encoding="UTF-8"?>
    <item>
      <dpla type="boolean">true</dpla>
      <public type="boolean">true</public>
      <dc_format type="array">
        <dc_format>application/pdf</dc_format>
      </dc_format>
      <dc_right type="array"/>
      <dc_date type="array">
        <dc_date>1912</dc_date>
      </dc_date>
      <dc_relation type="array"/>
      <slug>ahc0091-001-001</slug>
      <dcterms_is_part_of type="array"/>
      <dcterms_contributor type="array"/>
      <dcterms_creator type="array">
        <dcterms_creator>Frank, Leo, 1884-1915</dcterms_creator>
      </dcterms_creator>
      <dcterms_description type="array"/>
      <dcterms_extent type="array"/>
      <dcterms_medium type="array">
        <dcterms_medium>Letters (correspondence)</dcterms_medium>
      </dcterms_medium>
      <dcterms_identifier type="array">
        <dcterms_identifier>http://dlg.galileo.usg.edu/ahc/leofrank/do:ahc0091-001-001</dcterms_identifier>
      </dcterms_identifier>
      <dcterms_language type="array"/>
      <dcterms_spatial type="array">
        <dcterms_spatial>United States, Georgia, Fulton County, Atlanta, 33.7489954, -84.3879824</dcterms_spatial>
      </dcterms_spatial>
      <dcterms_publisher type="array">
        <dcterms_publisher>Box 1 Folder 1, Leo Frank papers, MSS 91, Kenan Research Center at the Atlanta History Center.</dcterms_publisher>
      </dcterms_publisher>
      <dcterms_rights_holder type="array"/>
      <dcterms_subject type="array">
        <dcterms_subject>Jews--Georgia--Atlanta</dcterms_subject>
        <dcterms_subject>Frank, Leo, 1884-1915--Trials, litigation, etc.</dcterms_subject>
      </dcterms_subject>
      <dcterms_temporal type="array"/>
      <dcterms_title type="array">
        <dcterms_title>Letters of sympathy and support to Leo Frank, 1912</dcterms_title>
      </dcterms_title>
      <dcterms_type type="array">
        <dcterms_type>Text</dcterms_type>
      </dcterms_type>
      <edm_is_shown_at type="array">
        <edm_is_shown_at>http://dlg.galileo.usg.edu/id:geh_0091_ahc0091-001-001</edm_is_shown_at>
      </edm_is_shown_at>
      <edm_is_shown_by type="array">
        <edm_is_shown_by>http://dlg.galileo.usg.edu/id:geh_0091_ahc0091-001-001</edm_is_shown_by>
      </edm_is_shown_by>
      <dcterms_provenance type="array">
        <dcterms_provenance>Atlanta History Center</dcterms_provenance>
      </dcterms_provenance>
      <dlg_local_right type="array"/>
      <dcterms_bibliographic_citation type="array">
        <dcterms_bibliographic_citation>Cite as: Leo Frank papers, MSS 91, Kenan Research Center at the Atlanta History Center.</dcterms_bibliographic_citation>
      </dcterms_bibliographic_citation>
      <local type="boolean">true</local>
      <dlg_subject_personal type="array"/>
      <other_colls type="array"/>
      <collection>
        <record_id>geh_0091</record_id>
      </collection>
      <portals type="array">
        <portal>
          <code>georgia</code>
        </portal>
      </portals>
    </item>
    XML
  end
  describe 'GET #new' do
    context 'with an uncommitted batch' do
      it 'assigns a new batch_import as @batch_import' do
        get :new, batch_id: batch.id
        expect(assigns(:batch_import)).to be_a_new(BatchImport)
      end
    end
    context 'with a committed batch' do
      it 'redirect to index' do
        get :new, batch_id: committed_batch.id
        expect(response).to redirect_to batch_batch_imports_path(committed_batch)
      end
    end
  end
  describe 'POST #create' do
    context 'with valid params' do
      it 'enqueues a job and redirects to show using XML' do
        post :create, batch_id: batch.id, batch_import: { xml: test_xml }
        expect(assigns(:batch_import)).to eq BatchImport.last
      end
      it 'enqueues a job and redirects to show using item IDs' do
        post :create, batch_id: batch.id, batch_import: { item_ids: '1,2' }
        expect(assigns(:batch_import)).to eq BatchImport.last
      end
    end
  end
end
