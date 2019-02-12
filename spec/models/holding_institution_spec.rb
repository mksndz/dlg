require 'rails_helper'

RSpec.describe HoldingInstitution, type: :model do
  it 'has none to begin with' do
    expect(HoldingInstitution.count).to eq 0
  end
  it 'has one after adding one' do
    Fabricate :holding_institution
    expect(HoldingInstitution.count).to eq 1
  end
  context 'when created' do
    let(:holding_institution) { Fabricate :holding_institution }
    it 'has a authorized_name' do
      expect(holding_institution.authorized_name).not_to be_empty
      expect(holding_institution.authorized_name).to be_a String
    end
    it 'has a set of coordinates stored as a string' do
      expect(holding_institution.coordinates).to be_a String
    end
    it 'has a boolean public value' do
      expect(holding_institution.public?).to be_truthy
    end
    it 'has a public_contact_address field' do
      expect(holding_institution).to respond_to :public_contact_address
    end
    it 'has a public_contact_email field' do
      expect(holding_institution).to respond_to :public_contact_email
    end
    it 'has a public_contact_phone field' do
      expect(holding_institution).to respond_to :public_contact_phone
    end
    it 'has Projects' do
      projects = Fabricate.times(2, :project)
      holding_institution.projects = projects
      expect(holding_institution.projects.first).to be_a Project
    end
    it 'has Repositories' do
      repositories = Fabricate.times(2, :empty_repository)
      holding_institution.repositories = repositories
      expect(holding_institution).to respond_to 'repositories'
      expect(holding_institution.repositories.count).to eq 2
      expect(holding_institution.repositories.first).to be_a Repository
    end
    it 'has Portals (via Repositories)' do
      repositories = Fabricate.times(2, :empty_repository)
      holding_institution.repositories = repositories
      expect(holding_institution.portal_names).to include Repository.last.portals.first.name
    end
    it 'has Batch Items' do
      batch_item = Fabricate(
        :batch_item,
        holding_institutions: [holding_institution]
      )
      expect(holding_institution.batch_items).to include batch_item
      expect(batch_item.holding_institutions).to include holding_institution
    end
    it 'has Items' do
      item = Fabricate(
        :item_with_parents,
        holding_institutions: [holding_institution]
      )
      expect(holding_institution.items).to include item
      expect(item.holding_institutions).to include holding_institution
    end
    it 'has Collections' do
      collection = Fabricate(
        :empty_collection,
        holding_institutions: [holding_institution]
      )
      expect(holding_institution.collections).to include collection
      expect(collection.holding_institutions).to include holding_institution
    end
  end
  context 'when validating' do
    it 'requires a authorized_name' do
      holding_institution = Fabricate.build(:holding_institution, authorized_name: nil)
      holding_institution.valid?
      expect(holding_institution.errors).to have_key :authorized_name
    end
    it 'requires a unique authorized_name' do
      Fabricate :holding_institution, authorized_name: 'Taken'
      holding_institution = Fabricate.build(:holding_institution, authorized_name: 'Taken')
      holding_institution.valid?
      expect(holding_institution.errors).to have_key :authorized_name
    end
    # it 'requires an institution_type' do
    #   holding_institution = Fabricate.build(:holding_institution, institution_type: nil)
    #   holding_institution.valid?
    #   expect(holding_institution.errors).to have_key :institution_type
    # end
    it 'requires a properly formatted set of coordinates' do
      holding_institution = Fabricate.build(:holding_institution, coordinates: 'A, B')
      holding_institution.valid?
      expect(holding_institution.errors).to have_key :coordinates
    end
    it 'requires a coordinates to not be a single number' do
      holding_institution = Fabricate.build(:holding_institution, coordinates: '1.1')
      holding_institution.valid?
      expect(holding_institution.errors).to have_key :coordinates
    end
    it 'requires a coordinates with acceptable values' do
      holding_institution = Fabricate.build(:holding_institution, coordinates: '-99, 199')
      holding_institution.valid?
      expect(holding_institution.errors).to have_key :coordinates
    end
  end
  context 'when deleting' do
    let(:holding_institution) do
      Fabricate :holding_institution, authorized_name: 'Test'
    end
    it 'does not delete if an item still uses it' do
      Fabricate(
        :item_with_parents,
        holding_institutions: [holding_institution]
      )
      expect do
        holding_institution.destroy
      end.to raise_error HoldingInstitutionInUseError
    end
    it 'does not delete if a collection still uses it' do
      Fabricate(
        :empty_collection,
        holding_institutions: [holding_institution]
      )
      expect do
        holding_institution.destroy
      end.to raise_error HoldingInstitutionInUseError
    end
  end
end
