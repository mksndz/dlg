require 'rails_helper'

RSpec.describe Subject, type: :model do
  it 'has none to begin with' do
    expect(Subject.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate(:subject)
    expect(Subject.count).to eq 1
  end
  context 'when created' do
    before :each do
      @subject = Fabricate :subject
    end
    it 'has a name' do
      expect(@subject.name).not_to be_empty
      expect(@subject.name).to be_a String
    end
    it 'can have Collections' do
      Fabricate :repository
      Collection.last.subjects << @subject
      expect(@subject).to respond_to 'collections'
      expect(@subject.collections.first).to be_a Collection
    end
  end
end
