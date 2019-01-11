require 'rails_helper'

RSpec.describe 'DPLA Harvesting Support endpoint', type: :request do
  headers = { 'X-User-Token' => Rails.application.secrets.dpla_token }
  context 'can list using #index' do
    before(:all) do
      repo = Fabricate :empty_repository, public: true
      coll = Fabricate :empty_collection, repository: repo, portals: repo.portals, public: true
      Fabricate.times(11, :robust_item, collection: coll, portals: repo.portals, public: true, dpla: true)
      Sunspot.commit
    end
    it 'returns records and request specifications' do
      get '/dpla', {}, headers
      expect(JSON.parse(response.body)['items'].length).to eq 11
      expect(JSON.parse(response.body)['numFound']).to eq 11
      expect(JSON.parse(response.body)['nextCursorMark']).not_to be_empty
    end
    it 'returns records limited by a row param' do
      get '/dpla', { rows: 2 }, headers
      expect(JSON.parse(response.body)['items'].length).to eq 2
      expect(JSON.parse(response.body)['numFound']).to eq 11
      expect(JSON.parse(response.body)['nextCursorMark']).not_to be_empty
    end
    it 'returns records paginated using cursorMark' do
      get '/dpla', { rows: 2 }, headers
      cursormark = JSON.parse(response.body)['nextCursorMark']
      get '/dpla', { cursormark: cursormark }, headers
      expect(JSON.parse(response.body)['items'].length).to eq 9
      expect(JSON.parse(response.body)['numFound']).to eq 11
      expect(JSON.parse(response.body)['nextCursorMark']).not_to be_empty
    end
    it 'returns records paginated using cursorMark and limited by a row param' do
      get '/dpla', { rows: 2 }, headers
      cursormark = JSON.parse(response.body)['nextCursorMark']
      get '/dpla', { cursormark: CGI.escape(cursormark), rows: 3 }, headers
      expect(JSON.parse(response.body)['items'].length).to eq 3
      expect(JSON.parse(response.body)['numFound']).to eq 11
      expect(JSON.parse(response.body)['nextCursorMark']).not_to be_empty
    end
  end
end