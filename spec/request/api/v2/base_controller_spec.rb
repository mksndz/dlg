require 'rails_helper'

RSpec.describe 'API Version 2', type: :request do
  it 'returns unauthorized if no token' do
    get '/api/v2/ok'
    expect(response.code).to eq '401'
  end
  it 'returns ok with valid token' do
    headers = { 'X-User-Token' => Rails.application.secrets.api_token }
    get '/api/v2/ok', {}, headers
    expect(response.code).to eq '200'
  end
end