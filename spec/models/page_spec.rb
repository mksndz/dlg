require 'rails_helper'

describe Page do
  let(:page) { Fabricate :page_with_item_and_text }
  context 'basic attributes' do
    it 'has an Item' do
      expect(page.item).to be_an Item
    end
    it 'has a number as a string' do
      expect(page.number).to be_a String
    end
    it 'has a title' do
      expect(page.title).to be_a String
    end
    it 'has fulltext' do
      expect(page.fulltext).to be_a String
    end
    it 'has a file type' do
      expect(page.file_type).to be_a String
    end
  end
  context 'validations' do
    it 'requires a number' do
      p = Fabricate.build(:page, number: nil)
      p.valid?
      expect(p.errors).to have_key :number
    end
    it 'requires a unique number per Item' do
      p = Fabricate.build(:page, number: page.number, item: page.item)
      p.valid?
      expect(p.errors).to have_key :number
    end
  end
end
