require 'rails_helper'

RSpec.describe 'API V2 for Collections', type: :request do
  headers = { 'X-User-Token' => Rails.application.secrets.api_token }
  context 'can list using #index' do
    before(:each) do
      Collection.destroy_all
      Fabricate.times 11, :empty_collection, public: true
      @collection = Collection.last
    end
    it 'returns an array of collections' do
      get '/api/v2/collections.json', {}, headers
      expect(JSON.parse(response.body).length).to eq 11
    end
    it 'paginates list of collections' do
      get '/api/v2/collections.json', { page: 2, per_page: 10 }, headers
      expect(JSON.parse(response.body).length).to eq 1
    end
    it 'returns collections filtered by portal' do
      get '/api/v2/collections.json',
          { portal: @collection.portals.first.code },
          headers
      expect(JSON.parse(response.body).length).to eq 1
      expect(
        Collection.find(JSON.parse(response.body)[0]['id']).portals.first.code
      ).to(
        eq(@collection.portals.first.code)
      )
    end
    it 'returns only public collections' do
      Fabricate(
        :collection,
        public: false,
        portals: @collection.portals,
        repository: @collection.repository
      )
      get '/api/v2/collections.json',
          { portal: @collection.portals.first.code },
          headers
      parsed_response = JSON.parse(response.body)
      expect(parsed_response.length).to eq 1
      expect(parsed_response[0]['public']).to be_truthy
    end
  end
  context 'can get single record info using #show' do
    before(:each) do
      @collection = Fabricate :empty_collection, public: true
    end
    it 'returns all data about an collection using record_id' do
      get "/api/v2/collections/#{@collection.record_id}.json",
          {},
          headers
      json = JSON.parse(response.body)
      expect(json['id']).to eq @collection.id
      expect(json['holding_institution_image']).to eq @collection.holding_institution_image
    end
    it 'returns all data about an item using database ID' do
      get "/api/v2/collections/#{@collection.id}.json",
          {},
          headers
      json = JSON.parse(response.body)
      expect(json['id']).to eq @collection.id
      expect(json.keys).to include 'sponsor_note', 'sponsor_image'
    end
    context 'with CollectionResources' do
      before(:each) do
        @collection.collection_resources << Fabricate.times(2, :collection_resource)
      end
      it 'returns CollectionResource info without content' do
        get "/api/v2/collections/#{@collection.id}.json",
            {},
            headers
        json = JSON.parse(response.body)
        expect(json['collection_resources'].length).to eq 2
        expect(json['collection_resources'][0].keys).to include 'slug', 'title', 'position'
      end
    end
  end
end