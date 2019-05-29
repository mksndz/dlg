require 'rails_helper'

RSpec.describe 'API V2 for Collection Resources', type: :request do
  headers = { 'X-User-Token' => Rails.application.secrets.api_token }
  context 'can get single record info using #show' do
    before(:each) do
      @collection = Fabricate(:empty_collection)
      @resource = Fabricate(:collection_resource, collection: @collection)
    end
    it 'returns all data about an collection resource using record_id and slug' do
      get "/api/v2/collections/#{@collection.record_id}/resource/#{@resource.slug}.json",
          {},
          headers
      json = JSON.parse(response.body)
      expect(json['slug']).to eq @resource.slug
      expect(json['title']).to eq @resource.title
      expect(json['scrubbed_content']).to eq @resource.scrubbed_content
    end
  end
end