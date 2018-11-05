require 'rails_helper'

RSpec.describe 'API V2 for Features', type: :request do
  headers = { 'X-User-Token' => Rails.application.secrets.api_token }
  context 'can list using #index' do
    before(:each) do
      Fabricate.times 5, :feature # carousel
      Fabricate.times 5, :tab_feature
      Fabricate :external_feature # carousel
      Fabricate :feature, primary: true # carousel
      Fabricate :primary_tab_feature
    end
    it 'returns an array of tab features, properly ordered' do
      get '/api/v2/features.json', { type: 'tab' }, headers
      json = JSON.parse(response.body)
      expect(json.length).to eq 6
      expect(json.first['primary']).to be true
    end
    it 'returns an array of carousel features, properly ordered' do
      get '/api/v2/features.json', { type: 'carousel' }, headers
      json = JSON.parse(response.body)
      expect(json.length).to eq 7
      expect(json.first['primary']).to be true
    end
    it 'returns error code for unsupported type' do
      get '/api/v2/features.json', { type: 'collection' }, headers
      expect(response.status).to eq 400
    end
  end
end