require 'rails_helper'

describe RecordImporter, type: :model do
  describe '#perform' do
    context 'with Item IDs' do
      it 'creates a Batch Item from an Item ID' do
        i = Fabricate(:repository).items.first
        batch_import = Fabricate(:batch_import) do
          item_ids { [i.id] }
          format { 'search query' }
        end
        expect{
          RecordImporter.perform(batch_import.id)
        }.to change(BatchItem, :count).by 1
        results = BatchImport.last.results
        expect(results['updated'].length).to eq 1
      end
      it 'records an error with an invalid ID' do
        batch_import = Fabricate(:batch_import) do
          item_ids { ['12345'] }
          format { 'search query' }
        end
        expect do
          RecordImporter.perform(batch_import.id)
        end.to change(BatchItem, :count).by 0
        results = BatchImport.last.results
        expect(results['failed'].length).to eq 1
      end
    end
    context 'with valid XML' do
      let(:batch_import) { Fabricate :batch_import }
      context 'with valid XML but no existing collection' do
        it 'should not create a BatchItem' do
          RecordImporter.perform batch_import.id
          batch_import.reload
          expect(batch_import.results['failed'][0]['message']).to(
            include 'could not be found using record id: geh_0091'
          )
        end
      end
      context 'with just valid XML' do
        before(:each) do
          p = Fabricate(:portal, code: 'georgia')
          r1 = Fabricate(:repository, slug: 'lpb', portals: [p])
          r2 = Fabricate(:repository, slug: 'geh', portals: [p])
          Fabricate(:collection, slug: 'aa', repository: r1, portals: [p])
          Fabricate(:collection, slug: '0091', repository: r2, portals: [p])
        end
        it 'should create a BatchItem' do
          expect do
            RecordImporter.perform(batch_import.id)
          end.to change(BatchItem, :count).by 1
        end
        it 'should create a BatchItem with a boolean local value' do
          RecordImporter.perform(batch_import.id)
          expect(BatchItem.last.local).to be true
        end
        it 'should create a BatchItem with dlg_subject_personal value' do
          RecordImporter.perform(batch_import.id)
          expect(BatchItem.last.dlg_subject_personal).to be_an Array
        end
        it 'should create a BatchItem with proper portal' do
          RecordImporter.perform(batch_import.id)
          expect(BatchItem.last.portals).to include Portal.last
        end
        it 'should create a BatchItem with proper collection' do
          RecordImporter.perform(batch_import.id)
          expect(BatchItem.last.collection.slug).to eq '0091'
        end
        it 'should create a BatchItem with proper other_collections array' do
          RecordImporter.perform(batch_import.id)
          expect(BatchItem.last.other_collections).to eq [Collection.find_by_record_id('lpb_aa').id]
        end
        it 'should update BatchImport results appropriately' do
          RecordImporter.perform(batch_import.id)
          expect(
              batch_import.reload.results['added'].length
          ).to eq 1
        end
        it 'should create a BatchItem linked to an existing Item' do
          i = Item.last
          c = Collection.find_by_record_id 'geh_0091'
          slug = batch_import.xml[/<slug>(.*?)<\/slug>/, 1]
          i.slug = slug
          i.collection = c
          i.save
          RecordImporter.perform(batch_import.id)
          expect(BatchItem.last.item).to eq i
        end
      end
    end
    context 'with unparseable xml' do
      let(:batch_import) do
        Fabricate(:batch_import) { xml { '<items><item>M</zzz>' } }
      end
      it 'should store a verbose error in results saying the XML could not be parsed' do
        RecordImporter.perform(batch_import.id)
        expect(
            batch_import.reload.results['failed'][0]['message']
        ).to include 'Fundamental XML parsing error:'
      end
    end
    context 'with xml with no item nodes' do
      let(:batch_import) {
        Fabricate(:batch_import) {
          xml { '<items><collection><slug>blah</slug></collection></items>' }
        }
      }
      it 'should store a verbose error in results saying no records found' do
        RecordImporter.perform(batch_import.id)
        expect(
          batch_import.reload.results['failed'][0]['message']
        ).to eq 'No records could be extracted from the XML'
      end
    end
    context 'with realistic xml' do
      before :each do
        @georgia_portal = Fabricate(:portal) { code { 'georgia' } }
        @crdl_portal = Fabricate(:portal) { code { 'crdl' } }
        @collection = Fabricate :empty_collection
        @other_collection = Fabricate :empty_collection
        @other_collection2 = Fabricate :empty_collection
        duplicate_date_xml = '<item>
            <dpla type="boolean">true</dpla>
            <public type="boolean">true</public>
            <dcterms_creator type="array">
              <dcterms_creator>WSB-TV (Television station : Atlanta, Ga.)</dcterms_creator>
            </dcterms_creator>
            <dcterms_subject type="array">
              <dcterms_subject>Presidents--United States--Election--1960</dcterms_subject>
              <dcterms_subject>International relations</dcterms_subject>
              <dcterms_subject>Elections</dcterms_subject>
            </dcterms_subject>
            <dcterms_spatial type="array">
              <dcterms_spatial>Cuba</dcterms_spatial>
            </dcterms_spatial>
            <dcterms_title type="array">
              <dcterms_title>UNDERWOOD CRITICIZES KENNEDY FOR INEPT FOREIGN POLICY BELIEFS (1960)</dcterms_title>
            </dcterms_title>
            <dcterms_temporal type="array">
              <dcterms_temporal>1960</dcterms_temporal>
            </dcterms_temporal>
            <dc_date type="array">
              <dc_date>1960</dc_date>
            </dc_date>
            <dlg_subject_personal type="array">
              <dlg_subject_personal>UNDERWOOD, NORMAN</dlg_subject_personal>
              <dlg_subject_personal>Kennedy, John F. (John Fitzgerald), 1917-1963</dlg_subject_personal>
              <dlg_subject_personal>Nixon, Richard M. (Richard Milhous), 1913-1994</dlg_subject_personal>
            </dlg_subject_personal>
            <dcterms_provenance type="array">
              <dcterms_provenance>Walter J. Brown Media Archives and Peabody Awards Collection</dcterms_provenance>
            </dcterms_provenance>
            <dc_format type="array">
              <dc_format>video/x-f4v</dc_format>
            </dc_format>
            <dcterms_type type="array">
              <dcterms_type>MovingImage</dcterms_type>
            </dcterms_type>
            <dcterms_medium type="array">
              <dcterms_medium>Moving images</dcterms_medium>
              <dcterms_medium>News</dcterms_medium>
              <dcterms_medium>Unedited footage</dcterms_medium>
            </dcterms_medium>
            <edm_is_shown_at type="array">
              <edm_is_shown_at>http://dlg.galileo.usg.edu/news/id:wsbn43083</edm_is_shown_at>
            </edm_is_shown_at>
            <edm_is_shown_by type="array">
              <edm_is_shown_by>http://dlg.galileo.usg.edu/news/do:wsbn43083</edm_is_shown_by>
            </edm_is_shown_by>
            <slug>wsbn43083</slug>
            <dcterms_extent type="array">
              <dcterms_extent>1 clip (about 8 min.): black-and-white, sound ; 16 mm.</dcterms_extent>
            </dcterms_extent>
            <dcterms_is_part_of type="array">
              <dcterms_is_part_of>Original found in the WSB-TV newsfilm collection.</dcterms_is_part_of>
            </dcterms_is_part_of>
            <dcterms_temporal type="array">
              <dcterms_temporal>1960</dcterms_temporal>
            </dcterms_temporal>
            <dc_date type="array">
              <dc_date>1960</dc_date>
            </dc_date>
            <dcterms_identifier type="array">
              <dcterms_identifier>Clip number: wsbn43083</dcterms_identifier>
            </dcterms_identifier>
            <dcterms_bibliographic_citation type="array">
              <dcterms_bibliographic_citation>Cite as: wsbn43083, (No title), WSB-TV newsfilm collection, reel 0962, 28:19/36:32, Walter J. Brown Media Archives and Peabody Awards Collection, The University of Georgia Libraries, Athens, Ga</dcterms_bibliographic_citation>
            </dcterms_bibliographic_citation>
            <dc_right type="array">
              <dc_right>http://rightsstatements.org/vocab/InC/1.0/</dc_right>
            </dc_right>
            <dc_relation type="array">
                  <dc_relation>\nForms part of the online collection: Individuals Active in Civil Disturbances Collection\nNew Line\n\t\t\t</dc_relation>
            </dc_relation>
            <dcterms_spatial type="array">
              <dcterms_spatial>United States</dcterms_spatial>
            </dcterms_spatial>
            <other_colls type="array">
              <other_coll>
                <record_id>__oc1__</record_id>
              </other_coll>
              <other_coll>
                <record_id>__oc2__</record_id>
              </other_coll>
            </other_colls>
            <collection>
              <record_id>ugabma_wsbn</record_id>
            </collection>
            <portals type="array">
              <portal>
                <code>georgia</code>
              </portal>
              <portal>
                <code>crdl</code>
              </portal>
            </portals>
            <dcterms_description type="array">
              <dcterms_description>Title supplied by cataloger.</dcterms_description>
            </dcterms_description>
            <local type="boolean">true</local>
          </item>'
        duplicate_date_xml.sub! 'ugabma_wsbn', @collection.record_id
        duplicate_date_xml.sub! '__oc1__', @other_collection.record_id
        duplicate_date_xml.sub! '__oc2__', @other_collection2.record_id
        bi = Fabricate(:batch_import) do
          xml { duplicate_date_xml }
        end
        RecordImporter.perform(bi.id)
        @batch_item = bi.batch.batch_items.first
      end
      it 'should not contain nested arrays' do
        expect(@batch_item.dc_date.first).not_to be_an Array
        expect(@batch_item.dcterms_spatial.first).not_to be_an Array
        expect(@batch_item.dcterms_temporal.first).not_to be_an Array
      end
      it 'should not contain duplicated array elements' do
        expect(@batch_item.dc_date).to eq ['1960']
        expect(@batch_item.dcterms_temporal).to eq ['1960']
        expect(@batch_item.dcterms_spatial).to eq ['Cuba', 'United States']
      end
      it 'should set multiple portal values properly' do
        expect(@batch_item.portals).to include @georgia_portal
        expect(@batch_item.portals).to include @crdl_portal
      end
      it 'should set multiple other_collection values properly' do
        expect(@batch_item.other_collections).to include @other_collection.id
        expect(@batch_item.other_collections).to include @other_collection2.id
      end
      it 'should trim leading and trailing whitespace from arrays of strings' do
        expect(@batch_item.dc_relation.first).to eq "Forms part of the online collection: Individuals Active in Civil Disturbances Collection\nNew Line"
      end
    end
    context 'with matching on db id' do
      before :each do
        c = Fabricate :empty_collection
        bi = Fabricate :batch_import_to_match_on_id
        @item = Fabricate(:repository).items.first
        @item.collection = c
        bi.xml = bi.xml.gsub '__ID__', @item.id.to_s
        bi.xml = bi.xml.gsub '__COLLECTION_RECORD_ID__', c.record_id
        bi.xml = bi.xml.gsub '__PORTAL_CODE__', Portal.last.code
        bi.save
        RecordImporter.perform(bi.id)
        @batch_item = bi.batch.batch_items.first
      end
      it 'should link the BatchItem to the Item for updating' do
        expect(@batch_item.item).to eq @item
      end
    end
    context 'for debugging xml' do
#       it 'works' do
#         x = ''
#         bi = Fabricate :batch_import, xml: x
#         r = Fabricate :empty_repository, slug: 'valdosta'
#         Fabricate :empty_collection, slug: 'blc', repository: r
#         RecordImporter.perform(bi.id)
#       end
    end
  end
end