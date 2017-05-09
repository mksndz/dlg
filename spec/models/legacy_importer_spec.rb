require 'rails_helper'

RSpec.describe LegacyImporter, type: :model do

  before :all do

    Subject.create!(
      [
        { name: 'The Arts' },
        { name: 'Business & Industry' },
        { name: 'Education' },
        { name: 'Folklife' },
        { name: 'Government & Politics' },
        { name: 'Land & Resources' },
        { name: 'Literature' },
        { name: 'Media' },
        { name: 'Peoples & Cultures' },
        { name: 'Religion' },
        { name: 'Science & Medicine' },
        { name: 'Sports & Recreation' },
        { name: 'Transportation' }
      ]
    )

    TimePeriod.create!(
      [
        { name: 'Archaeology & Early History' },
        { name: 'Colonial Era', start: 1733, finish: 1775 },
        { name: 'Revolution & Early Republic', start: 1775, finish: 1800 },
        { name: 'Antebellum Era', start: 1800, finish: 1860 },
        { name: 'Civil War & Reconstruction', start: 1861, finish: 1877 },
        { name: 'Late Nineteenth Century', start: 1877, finish: 1900 },
        { name: 'Progressive Era to World War II', start: 1900, finish: 1945 },
        { name: 'Civil Rights & Sunbelt Georgia', start: 1945, finish: 1980 },
        { name: 'Georgia at the Turn of the Millennium', start: 1990 }
      ]
    )

    Portal.create!(
      [
        { name: 'The Digital Library of Georgia', code: 'georgia' },
        { name: 'The Civil War in the American South', code: 'amso' },
        { name: 'The Civil Rights Digital Library', code: 'crdl' },
        { name: 'Other', code: 'other' }
      ]
    )
  end

  after :all do
    Subject.delete_all
    TimePeriod.delete_all
    Portal.delete_all
  end

  context 'repository creation' do

    let :valid_xml_repository_node do
      Nokogiri::XML(
        "
          <repo>
            <slug>zgp</slug>
            <public type='boolean'>true</public>
            <portals type='array'>
              <portal>
                <code>georgia</code>
              </portal>
            </portals>
            <title>Elbert County Library</title>
            <short_description>
              Public library system serving Elbert County, Georgia.
            </short_description>
            <description>
              Public library system serving Elbert County, Georgia.
            </description>
            <address>345 Heard Street\nElberton, GA 30635</address>
            <coordinates>34.107382, -82.859526</coordinates>
            <homepage_url>http://www.elbertlibrary.org/</homepage_url>
            <in_georgia type='boolean'>true</in_georgia>
          </repo>
        "
      ).css('repo')
    end

    it 'create a new repository' do

      repository = LegacyImporter.create_repository(
        Hash.from_xml(valid_xml_repository_node.to_s)
      )

      expect(repository.slug).to eq 'zgp'
      expect(repository.in_georgia).to be_truthy
      expect(repository.portals.collect(&:code)).to include 'georgia'

    end

  end

  context 'collection creation' do

    let(:valid_xml_collection_node) do
      Nokogiri::XML(
        "
          <coll>
            <slug>56000my</slug>
            <repository>
               <slug>gsg</slug>
            </repository>
            <public type='boolean'>true</public>
            <portals type='array'>
               <portal>
                  <code>georgia</code>
               </portal>
            </portals>
            <local type='boolean'>true</local>
            <display_title>City of Savannah, Georgia Records - Mayor&apos;s Office </display_title>
            <short_description>Records of the mayor of Savannah from the period of 1869 through 1904 an speeches of the mayor dating from 1960 to 1966.</short_description>
            <color>EEEEEE</color>
            <time_period type='array'>
                <time_period>Antebellum Era 1800-1860</time_period>
                <time_period>Civil War &amp; Reconstruction 1861-1877</time_period>
                <time_period>Late Nineteenth Century 1877-1900</time_period>
                <time_period>Progressive Era to World War II, 1900-1945</time_period>
                <time_period>Civil Rights &amp; Sunbelt Georgia, 1945-1980s</time_period>
            </time_period>
            <topic type='array'>
                <topic>Government &amp; Politics</topic>
                <topic>Science &amp; Medicine</topic>
            </topic>
            <dc_format type='array'>
                <dc_format>application/pdf</dc_format>
            </dc_format>
            <dc_date type='array'>
                <dc_date>1817/1851</dc_date>
                <dc_date>1869/1874</dc_date>
                <dc_date>1877/1891</dc_date>
                <dc_date>1895/1904</dc_date>
                <dc_date>1960/1966</dc_date>
            </dc_date>
            <dcterms_description type='array'>
                <dcterms_description>Records of the mayor of Savannah from the period of 1869 through 1904 an speeches of the mayor dating from 1960 to 1966.</dcterms_description>
            </dcterms_description>
            <dcterms_medium type='array'>
                <dcterms_medium>Municipal government records</dcterms_medium>
                <dcterms_medium>Letterbooks</dcterms_medium>
                <dcterms_medium>Speeches (documents)</dcterms_medium>
            </dcterms_medium>
            <dcterms_spatial type='array'>
                <dcterms_spatial>United States, Georgia, Chatham County, Savannah, 32.0835407, -81.0998342</dcterms_spatial>
            </dcterms_spatial>
            <dcterms_title type='array'>
                <dcterms_title>City of Savannah, Georgia records - mayor&apos;s office</dcterms_title>
            </dcterms_title>
            <dcterms_type type='array'>
                <dcterms_type>Text</dcterms_type>
            </dcterms_type>
            <edm_is_shown_at type='array'>
                <edm_is_shown_at>http://dlg.galileo.usg.edu/CollectionsA-Z/56000my_search.html</edm_is_shown_at>
            </edm_is_shown_at>
            <edm_is_shown_by type='array'>
                <edm_is_shown_by>http://dlg.galileo.usg.edu/CollectionsA-Z/56000my_search.html</edm_is_shown_by>
            </edm_is_shown_by>
            <dcterms_provenance type='array'>
                <dcterms_provenance>Savannah (Ga.). Research Library and Municipal Archives</dcterms_provenance>
            </dcterms_provenance>
          </coll>
        "
      ).css('coll')
    end

    let(:collection_display_title) { "City of Savannah, Georgia Records - Mayor's Office " }

    it 'updates an existing collection with metadata from the xml' do

      Fabricate(:repository) {
        slug 'gsg'
        collections { [Fabricate(:collection) { slug '56000my' }] }
      }

      collection = LegacyImporter.create_collection Hash.from_xml(valid_xml_collection_node.to_s)

      expect(collection.display_title).to eq collection_display_title
      expect(collection.time_periods.count).to eq 5
      expect(collection.time_periods.first).to be_a TimePeriod
      expect(collection.subjects.count).to eq 2
      expect(collection.subjects.first).to be_a Subject

    end

    it 'creates and populates a new collection with metadata from the xml' do

      repo = Fabricate(:repository) { slug 'gsg' }

      collection = LegacyImporter.create_collection Hash.from_xml(valid_xml_collection_node.to_s)

      expect(collection.display_title).to eq collection_display_title
      expect(collection.time_periods.count).to eq 5
      expect(collection.time_periods.first).to be_a TimePeriod
      expect(collection.subjects.count).to eq 2
      expect(collection.subjects.first).to be_a Subject
      expect(collection.repository).to eq repo
    end

  end

end