require 'rails_helper'

describe FulltextIngest do
  it 'has none to begin with' do
    expect(FulltextIngest.count).to eq 0
  end
  context 'basic attributes' do
    before :all do
      Fabricate :fulltext_ingest
    end
    it 'has a title' do
      expect(FulltextIngest.last.title).not_to be_empty
    end
    it 'has a description' do
      expect(FulltextIngest.last.description).not_to be_empty
    end
    it 'has an associated User' do
      expect(FulltextIngest.last.user).to be_a User
    end
    it 'has a file name' do
      expect(FulltextIngest.last.file).not_to be_empty
    end
    it 'has a JSON results' do
      expect(FulltextIngest.last.results).to eq({})
    end
    it 'has a field for queued time' do
      expect(FulltextIngest.last.queued_at).to be_nil
    end
    it 'has a field for finished time' do
      expect(FulltextIngest.last.finished_at).to be_nil
    end
    it 'has a field for undone time' do
      expect(FulltextIngest.last.undone_at).to be_nil
    end
  end
end
