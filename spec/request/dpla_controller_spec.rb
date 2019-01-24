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
      expect(response.code).to eq 200
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
end