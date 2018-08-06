require 'rails_helper'

describe FulltextIngest do
  it 'has none to begin with' do
    expect(FulltextIngest.count).to eq 0
  end
  context 'basic attributes' do
    let(:fti) { Fabricate :fulltext_ingest }
    it 'has a title' do
      expect(fti.title).not_to be_empty
    end
    it 'has a description' do
      expect(fti.description).not_to be_empty
    end
    it 'has an associated User' do
      expect(fti.user).to be_a User
    end
    it 'has a file' do
      expect(fti.file).not_to be_nil
    end
    it 'has a JSON results' do
      expect(fti.results).to eq({})
    end
    it 'has a field for queued time' do
      expect(fti.queued_at).to be_nil
    end
    it 'has a field for finished time' do
      expect(fti.finished_at).to be_nil
    end
    it 'has a field for undone time' do
      expect(fti.undone_at).to be_nil
    end
  end
  context 'stores outcomes in results' do
    context 'on full success' do
      let(:fti) { Fabricate :completed_fulltext_ingest_success }
      it 'has a false failed status and queued date' do
        expect(fti.failed?).to be_falsey
        expect(fti.queued_at).not_to be_blank
      end
      it 'has a success status and finished date' do
        expect(fti.success?).to be_truthy
        expect(fti.finished_at).not_to be_blank
      end
      it 'returns all modified record ids' do
        expect(fti.modified_record_ids).to eq %w(r1_c1_i1 r1_c1_i2)
      end
    end
    context 'on partial failure' do
      let(:fti) { Fabricate :completed_fulltext_ingest_with_errors }
      it 'has a false failed status and a false success status' do
        expect(fti.failed?).to be_falsey
        expect(fti.success?).to be_falsey
      end
      it 'has a true partial failure status' do
        expect(fti.partial_failure?).to be_truthy
      end
      it 'has information for each file processed' do
        processed_files = fti.processed_files
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
      let(:fti) { Fabricate :completed_fulltext_ingest_total_failure }
      it 'has a true failed status and message' do
        expect(fti.failed?).to be_truthy
        expect(fti.results['message']).not_to be_empty
      end
    end
    context 'after being undone' do
      let(:fti) { Fabricate :undone_fulltext_ingest }
      it 'has an undone date' do
        expect(fti.undone_at).not_to be_blank
      end
    end
  end

end
