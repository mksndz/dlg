require 'rails_helper'

RSpec.describe ApiController do
  describe 'GET #info' do
    context 'without authorization' do
      it 'returns unauthorized' do
        get :info
        expect(response.code).to eq '401'
      end
    end
    context 'with authorization' do
      before :each do
        request.headers['X-User-Token'] = Rails.application.secrets.api_token
      end
      let(:item) { Fabricate(:repository).items.first }
      it 'returns 404 if item not found' do
        get :info, record_id: 'a_b_c'
        expect(response.code).to eq '404'
      end
      it 'returns an item using record_id with expected values' do
        get :info, record_id: item.record_id
        expect(response.code).to eq '200'
        response_object = JSON.parse(response.body)
        expect(response_object['id']).to eq item.record_id
        expect(response_object['title']).to eq item.title
        expect(response_object['institution']).to eq item.dcterms_provenance.join ', '
      end
    end
  end
end
