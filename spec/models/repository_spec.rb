require 'rails_helper'

RSpec.describe Repository, type: :model do
  it 'has none to begin with' do
    expect(Repository.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate(:empty_repository)
    expect(Repository.count).to eq 1
  end
  it 'requires a title' do
    r = Fabricate.build(:empty_repository, title: '')
    r.valid?
    expect(r.errors).to have_key :title
  end

  it 'requires a unique slug' do
    r = Fabricate :repository
    r2 = Fabricate.build(:repository, slug: r.slug)
    r2.valid?
    expect(r2.errors).to have_key :slug
  end
  context 'when created' do
    let(:repository) { Fabricate :repository }
    it 'has a Portal value' do
      expect(repository.portals.first).to be_a_kind_of Portal
    end
    it 'has a title' do
      expect(repository.title).not_to be_empty
    end
    it 'has a slug' do
      expect(repository.slug).not_to be_empty
    end
    context 'with associated Collections' do
      it 'can return Collections' do
        expect(repository.collections.count).to eq 1
        expect(repository.collections.first).to be_a_kind_of Collection
      end
      it 'contains Items through Collections' do
        expect(repository.items.first).to be_a_kind_of Item
      end
    end
    context 'has a display value' do
      context 'for a non-public repository' do
        it 'that returns false' do
          expect(repository.public).to eq false
          expect(repository.display?).to eq false
        end
      end
      context 'for a public repository' do
        it 'that returns true' do
          repository.public = true
          expect(repository.public).to eq true
          expect(repository.display?).to eq true
        end
      end
    end
  end
end
