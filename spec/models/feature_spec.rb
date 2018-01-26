require 'rails_helper'

RSpec.describe Feature, type: :model do
  it 'has none to begin with' do
    expect(Feature.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate(:feature)
    expect(Feature.count).to eq 1
  end
  context 'when a basic feature is created' do
    let(:feature) { Fabricate :feature }
    it 'has an acceptable area' do
      expect(Feature.available_areas).to include feature.area
    end
    it 'has a boolean primary' do
      expect(feature.primary).to eq false
    end
    it 'has a title' do
      expect(feature.title).not_to be_empty
    end
    it 'has a title link' do
      expect(feature.title_link).not_to be_empty
    end
    it 'has a institution' do
      expect(feature.institution).not_to be_empty
    end
    it 'has a institution link' do
      expect(feature.institution_link).not_to be_empty
    end
    it 'has no short description' do
      expect(feature.short_description).to be_nil
    end
    it 'has no external link' do
      expect(feature.external_link).to be_nil
    end
  end
  context 'when an external feature is created' do
    let(:feature) { Fabricate :external_feature }
    it 'has a external link' do
      expect(feature.external_link).not_to be_nil
    end
  end
  context 'tab feature' do
    let(:feature) { Fabricate :tab_feature }
    it 'has a short description' do
      expect(feature.short_description).not_to be_nil
    end
  end
  context 'validations' do
    it 'requires title, title_link, institution, institution_link and image' do
      feature = Feature.new
      feature.save
      expect(feature.errors.keys).to eq %i[title title_link institution institution_link image]
    end
    it 'does not require a large_image if non-primary tabs feature' do
      feature = Fabricate.build :tab_feature
      feature.save
      expect(feature.errors).not_to have_key :large_image
    end
    it 'requires a large_image if primary tabs feature' do
      feature = Fabricate.build(:tab_feature, primary: true)
      feature.save
      expect(feature.errors).to have_key :large_image
    end
  end
end
