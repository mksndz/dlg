require 'rails_helper'

describe PageIngest do
  it 'has none to begin with' do
    expect(PageIngest.count).to eq 0
  end
  context 'basic attributes' do
    let(:page_ingest) { Fabricate :page_ingest }
    it 'has a title' do
      expect(page_ingest.title).not_to be_empty
    end
    it 'has a description' do
      expect(page_ingest.description).not_to be_empty
    end
    it 'has an associated User' do
      expect(page_ingest.user).to be_a User
    end
    it 'has a file' do
      expect(page_ingest.file).not_to be_nil
    end
    it 'has a JSON results' do
      expect(page_ingest.results_json).to eq({})
    end
    it 'has a field for queued time' do
      expect(page_ingest.queued_at).to be_nil
    end
    it 'has a field for finished time' do
      expect(page_ingest.finished_at).to be_nil
    end
  end
end
