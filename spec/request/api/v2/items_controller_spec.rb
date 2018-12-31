require 'rails_helper'

RSpec.describe 'API V2 for Items', type: :request do
  headers = { 'X-User-Token' => Rails.application.secrets.api_token }
  context 'can list using #index' do
    before(:each) do
      Fabricate.times 11, :item_with_parents, public: true
      @item = Item.last
    end
    it 'returns an array of items' do
      get '/api/v2/items.json', {}, headers
      expect(JSON.parse(response.body).length).to eq 11
    end
    it 'paginates list of items' do
      get '/api/v2/items.json', { page: 2, per_page: 10 }, headers
      expect(JSON.parse(response.body).length).to eq 1
    end
    it 'returns items filtered by portal' do
      get '/api/v2/items.json',
          { portal: @item.portals.first.code },
          headers
      expect(JSON.parse(response.body).length).to eq 1
      expect(
        Item.find(JSON.parse(response.body)[0]['id']).portals.first.code
      ).to(
        eq(@item.portals.first.code)
      )
    end
    it 'returns items filtered by collection record_id' do
      get '/api/v2/items.json',
          { collection: @item.collection.record_id },
          headers
      expect(JSON.parse(response.body)[0]['collection']['display_title']).to(
        eq(@item.collection.display_title)
      )
    end
    it 'returns items filtered by collection database ID' do
      get '/api/v2/items.json',
          { collection: @item.collection.id },
          headers
      expect(JSON.parse(response.body)[0]['collection']['display_title']).to(
        eq(@item.collection.display_title)
      )
    end
  end
  context 'can get single record info using #show' do
    before(:each) do
      @item = Fabricate :item_with_parents, public: true
    end
    it 'returns all data about an item using record_id' do
      get "/api/v2/items/#{@item.record_id}.json",
          {},
          headers
      json = JSON.parse(response.body)
      expect(json['id']).to eq @item.id
    end
    it 'returns all data about an item using database ID' do
      get "/api/v2/items/#{@item.record_id}.json",
          {},
          headers
      json = JSON.parse(response.body)
      expect(json['id']).to eq @item.id
    end
  end
end