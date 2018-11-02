require 'rails_helper'

RSpec.describe Api::V2::BaseController do
  describe 'GET #ok' do
    it 'returns unauthorized if no token' do
      get :ok
      expect(response.code).to eq '401'
    end
    it 'returns ok with valid token' do
      request.headers['X-User-Token'] = Rails.application.secrets.api_token
      get :ok
      expect(response.code).to eq '200'
    end
  end
end