require 'rails_helper'

describe FulltextIngest do
  it 'has none to begin with' do
    expect(FulltextIngest.count).to eq 0
  end
  context 'basic attributes' do
    before(:all) { Fabricate :fulltext_ingest }
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
  context 'stores outcomes in results' do
    context 'on full success' do
      before(:all) { Fabricate :completed_fulltext_ingest_success }
      it 'has a false failed status and queued date' do
        expect(FulltextIngest.last.failed?).to be_falsey
        expect(FulltextIngest.last.queued_at).not_to be_blank
      end
      it 'has a success status and finished date' do
        expect(FulltextIngest.last.success?).to be_truthy
        expect(FulltextIngest.last.finished_at).not_to be_blank
      end
    end
    context 'on partial failure' do
      before(:all) { Fabricate :completed_fulltext_ingest_with_errors }
      it 'has a false failed status and a false success status' do
        expect(FulltextIngest.last.failed?).to be_falsey
        expect(FulltextIngest.last.success?).to be_falsey
      end
      it 'has a true partial failure status' do
        expect(FulltextIngest.last.partial_failure?).to be_truthy
      end
      it 'has information for each file processed' do
        processed_files = FulltextIngest.last.processed_files
        expect(processed_files.length).to eq 2
        expect(processed_files).to have_key 'r1_c1_i1'
        expect(processed_files).to have_key 'r1_c1_i2'
        expect(processed_files['r1_c1_i1']).to have_key 'status'
        expect(processed_files['r1_c1_i1']).to have_key 'item'
        expect(processed_files['r1_c1_i2']).to have_key 'status'
        expect(processed_files['r1_c1_i2']).to have_key 'reason'
        expect(processed_files['r1_c1_i1']['status']).to eq 'success'
        expect(processed_files['r1_c1_i1']['item']).to eq Item.last.id
        expect(processed_files['r1_c1_i2']['status']).to eq 'failed'
        expect(processed_files['r1_c1_i2']['reason']).to eq 'Exception message'
      end
    end
    context 'on total failure' do
      before(:all) { Fabricate :completed_fulltext_ingest_total_failure }
      it 'has a true failed status' do
        expect(FulltextIngest.last.failed?).to be_truthy
      end
    end
    context 'after being undone' do
      before(:all) { Fabricate :undone_fulltext_ingest }
      it 'has an undone date' do
        expect(FulltextIngest.last.undone_at).not_to be_blank
      end
    end
  end

end
