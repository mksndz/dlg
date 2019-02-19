require 'rails_helper'

RSpec.describe 'DPLA Harvesting Support endpoint', type: :request do
  headers = { 'X-User-Token' => Rails.application.secrets.dpla_token }
  context 'can list using #index' do
    before(:each) do
      repo = Fabricate :empty_repository, public: true
      coll = Fabricate :empty_collection, repository: repo, portals: repo.portals, public: true
      Fabricate.times(11, :robust_item, collection: coll, portals: repo.portals, public: true, dpla: true)
      Sunspot.commit
    end
    after(:each) do
      Sunspot.remove_all! Item
      Sunspot.remove_all! Collection
    end
    it 'returns records and request specifications' do
      get '/dpla', {}, headers
      body = JSON.parse(response.body)
      expect(response.code).to eq '200'
      expect(body['items'].length).to eq 11
      expect(body['numFound']).to eq 11
      expect(body['nextCursorMark']).not_to be_empty
    end
    it 'returns records limited by a row param' do
      get '/dpla', { rows: 2 }, headers
      body = JSON.parse(response.body)
      expect(body['items'].length).to eq 2
      expect(body['numFound']).to eq 11
      expect(body['nextCursorMark']).not_to be_empty
    end
    it 'returns records paginated using cursorMark' do
      get '/dpla', { rows: 2 }, headers
      cursormark = JSON.parse(response.body)['nextCursorMark']
      get '/dpla', { cursormark: cursormark }, headers
      body = JSON.parse(response.body)
      expect(body['items'].length).to eq 9
      expect(body['numFound']).to eq 11
      expect(body['nextCursorMark']).not_to be_empty
    end
    it 'returns records paginated using cursorMark and limited by a row param' do
      get '/dpla', { rows: 2 }, headers
      cursormark = JSON.parse(response.body)['nextCursorMark']
      get '/dpla', { cursormark: CGI.escape(cursormark), rows: 3 }, headers
      body = JSON.parse(response.body)
      expect(body['items'].length).to eq 3
      expect(body['numFound']).to eq 11
      expect(body['nextCursorMark']).not_to be_empty
    end
  end
  context 'can show using #show' do
    before(:each) do
      repo = Fabricate :empty_repository, public: true
      coll = Fabricate :empty_collection, repository: repo, portals: repo.portals, public: true
      @item = Fabricate :robust_item, collection: coll, portals: repo.portals, public: true, dpla: true
      @nonpublic_item = Fabricate :robust_item, collection: coll, portals: repo.portals, public: false, dpla: true
      @nondpla_item = Fabricate :robust_item, collection: coll, portals: repo.portals, public: true, dpla: false
      Sunspot.commit
    end
    after(:each) do
      Sunspot.remove_all! Item
      Sunspot.remove_all! Collection
    end
    it 'returns data for appropriate items' do
      get "/dpla/#{@item.record_id}", {}, headers
      expect(response.code).to eq '200'
      body = JSON.parse(response.body)
      expect(body['id']).to eq @item.record_id
    end
    it 'fails to return data for non public items' do
      get "/dpla/#{@nonpublic_item.record_id}", {}, headers
      expect(response.code).to eq '404'
    end
    it 'fails to return data for non DPLA items' do
      get "/dpla/#{@nondpla_item.record_id}", {}, headers
      expect(response.code).to eq '404'
    end
    it 'returns a record with a . in the record_id' do
      @item.record_id = @item.record_id + '.abc'
      @item.save
      Sunspot.commit
      get "/dpla/#{@item.record_id}", {}, headers
      expect(response.code).to eq '200'
      body = JSON.parse(response.body)
      expect(body['id']).to eq @item.record_id
    end
  end
end