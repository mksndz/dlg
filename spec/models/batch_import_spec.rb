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

    it 'returns false for completed' do
      expect(b.completed?).to be false
    end

  end

  context :completed do

    let(:b) { Fabricate :completed_batch_import }

    it 'has integer failed' do
      expect(b.failed).to be_kind_of Integer
    end

    it 'has integer added' do
      expect(b.added).to be_kind_of Integer
    end

    it 'returns true for completed' do
      expect(b.completed?).to be true
    end

  end

end
