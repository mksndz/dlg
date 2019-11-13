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
  context 'has an undo action' do
    it 'removes added fulltext' do
      fti = Fabricate :completed_fulltext_ingest_for_undoing
      i = Item.last
      i.fulltext = 'Fulltext'
      i.save
      fti.undo
      expect(fti.undone_at).not_to be_blank
      i.reload
      expect(i.fulltext).to be_blank
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
        expect(fti.modified_record_ids.length).to eq 2
        expect(fti.modified_record_ids).to include Item.last.record_id
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
      it 'has information for failed files' do
        expect(fti.failed.length).to eq 1
        expect(fti.failed.first[1]).to eq 'Exception message'
      end
      it 'has information for succeeded files' do
        expect(fti.succeeded.length).to eq 1
        expect(fti.succeeded).to eq [Item.last.id]
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
