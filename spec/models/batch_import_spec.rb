require 'rails_helper'

RSpec.describe BatchImport, type: :model do

  it 'has none to begin with' do
    expect(BatchImport.count).to eq 0
  end

  it 'has one after adding one' do
    Fabricate(:batch_import)
    expect(BatchImport.count).to eq 1
  end

  context :new do

    let(:b) { Fabricate :batch_import }

    it 'has a String format' do
      expect(b.format).to be_kind_of String
    end

    it 'belongs to a User' do
      expect(b.user).to be_kind_of User
    end

    it 'belongs to a Batch' do
      expect(b.batch).to be_kind_of Batch
    end

    it 'belongs to a Batch' do
      expect(b.item_ids).to be_an Array
    end

    it 'returns false for completed' do
      expect(b.completed?).to be false
    end

    it 'returns false for match_by_db_id' do
      expect(b.match_on_id?).to be false
    end

  end

  context :completed do

    let(:b) { Fabricate :completed_batch_import }

    it 'returns true for completed' do
      expect(b.completed?).to be true
    end

    it 'has BatchItems' do
      expect(b.batch_items.first).to be_kind_of BatchItem
    end

    it 'has boolean validations' do
      expect(b.validations?).to be_in([true, false])
    end

    it 'has a filename' do
      expect(Fabricate(:completed_batch_import_from_file).file_name).to eq 'xml_file.xml'
    end

    it 'has hash results' do
      expect(b.results).to be_kind_of Hash
    end

  end

  context :match_on_id do
    let(:b) { Fabricate :batch_import_to_match_on_id }

    it 'returns true for match_on_id' do
      expect(b.match_on_id).to be true
    end

    it 'has a placeholder for the ID in the xml' do
      expect(b.xml).to include '__ID__'
    end
  end

end
