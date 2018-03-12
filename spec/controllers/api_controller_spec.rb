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
        expect(response_object['title']).to eq item.dcterms_title
        expect(response_object['institution']).to eq item.dcterms_provenance
      end
      it 'returns a collection using record_id with expected values' do
        get :info, record_id: item.collection.record_id
        expect(response.code).to eq '200'
        response_object = JSON.parse(response.body)
        expect(response_object['image']).to eq item.repository.image.url
      end
      context 'getting featured records' do
        before :each do
          Fabricate.times 5, :feature
          Fabricate.times 5, :tab_feature
          Fabricate :external_feature
          Fabricate :feature, primary: true
          Fabricate :primary_tab_feature
        end
        it 'retrieves featured items for tabs, properly ordered' do
          get :tab_features, count: 8
          response_object = JSON.parse(response.body)
          response_features = response_object['records']
          expect(response_object['limit']).to eq '8'
          expect(response_features.length).to eq 6
          expect(response_features.first['primary']).to be true
        end
        it 'retrieves featured items for carousel, properly ordered' do
          get :carousel_features, count: 11
          response_object = JSON.parse(response.body)
          response_features = response_object['records']
          expect(response_object['limit']).to eq '11'
          expect(response_features.length).to eq 7
          expect(response_features.first['primary']).to be true
        end
      end
    end
  end
end
