require 'rails_helper'

RSpec.describe MetadataCleaner, type: :model do
  let(:collection) { Fabricate :empty_collection }
  context 'basic cleaning' do
    let(:item) do
      Fabricate(:item,
                collection: collection,
                portals: collection.portals) do
        dcterms_description ['Blah<br>blah<BR/>BLAH<br />blahblah']
        # dcterms_title ['<p><b>Blah</b> <i>blah</i></p>', '<u>Blah</u>', '<em>Blah</em><sup>1</sup>']
        dc_relation ['<a href="https://www.blah.edu">Blah</a>', '<a href=\'http://blahblah.edu\'>Blah blah</a>', '<a href="http://www.blah.com">BLAH</a>']
      end
    end
    before :each do
      MetadataCleaner.new.clean item
    end
    it 'converts <br> tags to newlines' do
      expect(item.dcterms_description).to eq ["Blah\nblah\nBLAH\nblahblah"]
    end
    # TODO: HTML scrubbing is proving problematic
    # it 'removes presentation-related html tags' do
    #   expect(item.dcterms_title).to eq ['Blah blah', 'Blah', 'Blah1']
    # end
    # it 'removes <a> links leaving only the link text and url' do
    #   expect(item.dc_relation).to eq(
    #     [
    #       'Blah (https://www.blah.edu)',
    #       'Blah blah',
    #       'BLAH (http://www.blah.com)'
    #     ]
    #   )
    # end
  end
  context 'advanced cleanings' do
    it 'handles links with params' do
      item = Fabricate.build(:item,
                             collection: collection,
                             portals: collection.portals) do
        dc_relation ['<a href="http://archon.kennesaw.edu/index.php?p=collections/controlcard&id=98&q=bell" target="_blank">Bell Aircraft Georgia Division (Marietta) Collection, 1942-1945</a>']
      end
      MetadataCleaner.new.clean item
      expect(item.dc_relation.first).to eq 'Bell Aircraft Georgia Division (Marietta) Collection, 1942-1945 (http://archon.kennesaw.edu/index.php?p=collections/controlcard&id=98&q=bell)'
    end
    it 'handles mailto links' do
      item = Fabricate.build(:item,
                             collection: collection,
                             portals: collection.portals) do
        dc_relation ['please contact us at <a href="mailto:DSU@auctr.edu">DSU@auctr.edu</a>.']
      end
      MetadataCleaner.new.clean item
      expect(item.dc_relation.first).to eq 'please contact us at DSU@auctr.edu.'
    end
    it 'strips leading and trailing whitespace' do
      item = Fabricate.build(:item,
                             collection: collection,
                             portals: collection.portals) do
        dc_relation ['<br>Blah Blah<br><br>']
      end
      MetadataCleaner.new.clean item
      expect(item.dc_relation.first).to eq 'Blah Blah'
    end
  end
end
