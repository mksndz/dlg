require 'rails_helper'

RSpec.describe Repository, type: :model do

  it 'has none to begin with' do
    expect(Repository.count).to eq 0
  end

  it 'has one after adding one' do
    Fabricate(:repository)
    expect(Repository.count).to eq 1
  end

  it 'contains a Collection' do
    r = Fabricate(:repository) {
      collections(count: 1)
    }
    expect(r.collections.count).to be > 0
    expect(r.collections.first).to be_kind_of Collection
  end

  it 'has a title' do
    r = Fabricate(:repository)
    expect(r.title).not_to be_empty
  end

  it 'has a slug' do
    r = Fabricate(:repository)
    expect(r.slug).not_to be_empty
  end

  it 'has a thumbnail_path that is a url' do
    r = Fabricate(:repository)
    expect { URI.parse(r.thumbnail_path) }.not_to raise_exception
  end

  it 'contains Items through Collection' do
    r = Fabricate(:repository) {
      collections { Fabricate.times(1, :collection) {
        items(count: 1)
      }}
    }
    expect(r.items.first).to be_kind_of Item
  end

  it 'has a set of coordinates stored as a string' do
    r = Fabricate :repository
    expect(r.coordinates).to be_an String
  end

  it 'has an array of Portals' do

    r = Fabricate :repository
    p = Fabricate :portal

    r.portals << p

    expect(r.portals.first).to be_a Portal

  end

  # VALIDATIONS

  it 'requires a title' do
    r = Fabricate.build(:repository, title: '')
    r.valid?
    expect(r.errors).to have_key :title
  end

  it 'requires coordinates' do
    r = Fabricate.build(:repository, coordinates: '')
    r.valid?
    expect(r.errors).to have_key :coordinates
  end

  it 'requires a properly formatted set of coordinates' do
    r = Fabricate.build(:repository, coordinates: 'A, B')
    r.valid?
    expect(r.errors).to have_key :coordinates
  end

  it 'requires a coordinates to not be a single number' do
    r = Fabricate.build(:repository, coordinates: '1.1')
    r.valid?
    expect(r.errors).to have_key :coordinates
  end

  it 'requires a coordinates with acceptable values' do
    r = Fabricate.build(:repository, coordinates: '-99, 199')
    r.valid?
    expect(r.errors).to have_key :coordinates
  end

  context 'public_display? behavior' do

    context 'non-public repository' do
      before :each do
        @repository = Fabricate :repository
      end

      it 'repository should return false for public_display?' do
        expect(@repository.public).to eq false
        expect(@repository.display?).to eq false
      end
    end

    context 'public repository' do
      before :each do
        @repository = Fabricate(:repository) { public { true } }
      end

      it 'repository should return false for public_display?' do
        expect(@repository.public).to eq true
        expect(@repository.display?).to eq true
      end
    end

  end

end
