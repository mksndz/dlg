require 'rails_helper'

RSpec.describe LegacyImporter, type: :model do

  let(:valid_xml_collection_node) { Nokogiri::XML(
    '<coll>
    <slug>zmos</slug>
    <display_title>Annual Reports of the Mayor of Savannah, Georgia, 1855-1923</display_title>
    <short_description>Annual reports dated from 1855 to 1923 covering Savannah&apos;s activities and finances, statistics, trade, and ordinances from  from the collections of the &lt;a href=&quot;http://purl.galileo.usg.edu/dlgbeta/Institutions/sava.html&quot;&gt;City of Savannah Municipal Archives&lt;/a&gt; and the &lt;a href=&quot;http://purl.galileo.usg.edu/dlgbeta/Institutions/gua.html&quot;&gt;University of Georgia Libraries&lt;/a&gt;</short_description>
    <teaser>Annual_Reports_of_the_Mayor_of_Savannah.gif</teaser>
    <color>F0EEE0</color>
    <time_period type="array">
        <time_period>Antebellum Era 1800-1860</time_period>
        <time_period>Civil War &amp; Reconstruction 1861-1877</time_period>
        <time_period>Late Nineteenth Century 1877-1900</time_period>
        <time_period>Progressive Era to World War II, 1900-1945</time_period>
    </time_period>
    <topic type="array">
        <topic>Government &amp; Politics</topic>
    </topic>
    <dc_date type="array">
        <dc_date>1855/1923</dc_date>
    </dc_date>
    <public type="boolean">true</public>
    <dcterms_creator type="array">
        <dcterms_creator>Savannah (Ga.). Mayor</dcterms_creator>
    </dcterms_creator>
    <dcterms_description type="array">
        <dcterms_description>The annual reports of the Mayor of the city of Savannah Georgia for the years 1855-1917 include information on city activities and finances, commercial statistics,  health including death and illness statistics, and information on trade, public schools, weather,  charitable institutions and city ordinances.  The documents also include reports of the City Attorney, the Police Department (including crime statistics), the City Engineer, the Fire Department (including statistics on fires and property losses), and the Board of Trade, among others.</dcterms_description>
    </dcterms_description>
    <dcterms_medium type="array">
        <dcterms_medium>Annual reports</dcterms_medium>
        <dcterms_medium>Reports</dcterms_medium>
        <dcterms_medium>Texts (document genres)</dcterms_medium>
    </dcterms_medium>
    <dcterms_language type="array">
        <dcterms_language>eng</dcterms_language>
    </dcterms_language>
    <dcterms_spatial type="array">
        <dcterms_spatial>United States, Georgia, Chatham County, Savannah, 32.0835407, -81.0998342</dcterms_spatial>
    </dcterms_spatial>
    <dcterms_publisher type="array">
        <dcterms_publisher>Annual reports of the mayor of Savannah, Georgia</dcterms_publisher>
    </dcterms_publisher>
    <dcterms_subject type="array">
        <dcterms_subject>Savannah (Ga.)--Politics and government--Periodicals</dcterms_subject>
        <dcterms_subject>Savannah (Ga.). Mayor</dcterms_subject>
    </dcterms_subject>
    <dcterms_title type="array">
        <dcterms_title>Annual reports of the mayor of Savannah, Georgia, 1855-1923</dcterms_title>
    </dcterms_title>
    <dcterms_is_shown_at type="array">
        <dcterms_is_shown_at>http://www.galileo.usg.edu/express?link=zmos</dcterms_is_shown_at>
    </dcterms_is_shown_at>
    <dcterms_provenance type="array">
        <dcterms_provenance>Savannah (Ga.). Research Library and Municipal Archives</dcterms_provenance>
        <dcterms_provenance>Georgia Historical Society</dcterms_provenance>
        <dcterms_provenance>University of Georgia. Libraries</dcterms_provenance>
    </dcterms_provenance>
    <repository>
       <slug>dlg</slug>
    </repository>
    <other_repository type="array">
        <other_repository>gsg</other_repository>
        <other_repository>gua</other_repository>
    </other_repository></coll>')
  }

  let(:display_title) {
    'Annual Reports of the Mayor of Savannah, Georgia, 1855-1923'
  }

  before(:each) {

    Subject.create!([
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
    ])

    TimePeriod.create!([
       { name: 'Archaeology & Early History' },
       { name: 'Colonial Era', start: 1733, finish: 1775 },
       { name: 'Revolution & Early Republic', start: 1775, finish: 1800 },
       { name: 'Antebellum Era', start: 1800, finish: 1860 },
       { name: 'Civil War & Reconstruction', start: 1861, finish: 1877 },
       { name: 'Late Nineteenth Century', start: 1877, finish: 1900 },
       { name: 'Progressive Era to World War II', start: 1900, finish: 1945 },
       { name: 'Civil Rights & Sunbelt Georgia', start: 1945, finish: 1980 },
       { name: 'Georgia at the Turn of the Millennium', start: 1990 },
     ])
  }

  after(:each) {
    Subject.delete_all
    TimePeriod.delete_all
  }

  it 'updates an existing collection with metadata from the xml' do

    Fabricate(:repository) {
      slug 'dlg'
      collections { [Fabricate(:collection) { slug 'zmos' }] }
    }

    LegacyImporter.create_collection valid_xml_collection_node

    expect(Collection.last.display_title).to eq display_title
    expect(Collection.last.time_periods.count).to eq 4
    expect(Collection.last.time_periods.first).to be_a TimePeriod
    expect(Collection.last.subjects.count).to eq 1
    expect(Collection.last.subjects.first).to be_a Subject

  end

  it 'creates and populates a new collection with metadata from the xml' do

    Fabricate(:repository) { slug 'dlg' }

    LegacyImporter.create_collection valid_xml_collection_node

    expect(Collection.last.display_title).to eq display_title
    expect(Collection.last.time_periods.count).to eq 4
    expect(Collection.last.time_periods.first).to be_a TimePeriod
    expect(Collection.last.subjects.count).to eq 1
    expect(Collection.last.subjects.first).to be_a Subject

  end

end