require 'rails_helper'

RSpec.describe FulltextIngest, type: :model do
  it 'has none to begin with' do
    expect(BatchImport.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate(:fulltext_ingest)
    expect(BatchImport.count).to eq 1
  end
  context :new do
    let(:b) { Fabricate :fulltext_ingest }
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
end
