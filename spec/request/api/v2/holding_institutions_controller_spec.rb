require 'rails_helper'

RSpec.describe 'API V2 for Holding Institutions', type: :request do
  headers = { 'X-User-Token' => Rails.application.secrets.api_token }
  context 'can list using #index' do
    before(:each) do
      @collection = Fabricate :empty_collection
      Fabricate.times(3, :holding_institution)
      @holding_institution = HoldingInstitution.last
    end
    it 'returns an array of holding institutions' do
      get '/api/v2/holding_institutions.json', {}, headers
      expect(response.content_type).to eq 'application/json'
      expect(response.status).to eq 200
      expect(JSON.parse(response.body).length).to eq 4
    end
    it 'paginates list of holding institutions' do
      get '/api/v2/holding_institutions.json', { page: 2, per_page: 2 }, headers
      expect(JSON.parse(response.body).length).to eq 2
    end
    it 'returns holding institutions filtered by institution type' do
      get '/api/v2/holding_institutions.json',
          { page: 4, per_page: 1, type: @holding_institution.institution_type },
          headers
      expect(JSON.parse(response.body)[0]['institution_type']).to(
        eq(@holding_institution.institution_type)
      )
    end
    it 'includes collection information' do
      get '/api/v2/holding_institutions.json', { page: 1, per_page: 1 }, headers
      json = JSON.parse(response.body)
      expect(json[0]['collections'].length).to eq 1
      expect(json[0]['collections'][0]['id']).to(
        eq(@collection.id)
      )
    end
  end
  context 'can get single record info using #show' do
    before(:each) do
      @collection = Fabricate :empty_collection
      @holding_institution = HoldingInstitution.last
    end
    it 'returns all data about a holding institution' do
      get "/api/v2/holding_institutions/#{@holding_institution.id}.json",
          {},
          headers
      json = JSON.parse(response.body)
      expect(response.content_type).to eq 'application/json'
      expect(response.status).to eq 200
      expect(json['id']).to eq @holding_institution.id
      expect(json['collections'].length).to eq 1
      expect(json['collections'][0]['id']).to(
        eq(@collection.id)
      )
    end
  end
end