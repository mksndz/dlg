require 'rails_helper'

RSpec.describe 'API V2 for Holding Institutions', type: :request do
  headers = { 'X-User-Token' => Rails.application.secrets.api_token }
  context 'can list using #index' do
    before(:each) do
      @collection = Fabricate :empty_collection,
                              public: true
      @holding_institution = HoldingInstitution.last
      Fabricate.times 3, :holding_institution, repositories: [@collection.repository]
      @np_coll = Fabricate :collection,
                           public: false,
                           repository: @collection.repository,
                           holding_institutions: [@holding_institution],
                           portals: @collection.portals
      @holding_institution.collections = [@collection, @np_coll]
      @holding_institution.save
    end
    it 'returns a sorted array of holding institutions' do
      get '/api/v2/holding_institutions.json', {}, headers
      expect(response.content_type).to eq 'application/json'
      expect(response.status).to eq 200
      records = JSON.parse(response.body)
      expect(records.length).to eq 4
      authorized_names = records.map do |r|
        r['authorized_name']
      end
      expect(authorized_names).to eq(
        HoldingInstitution.all.order(:authorized_name).pluck(:authorized_name)
      )
    end
    it 'paginates list of holding institutions' do
      get '/api/v2/holding_institutions.json', { page: 2, per_page: 2 }, headers
      expect(JSON.parse(response.body).length).to eq 2
    end
    it 'only returns public holding institutions' do
      non_public = Fabricate :holding_institution, public: false
      get '/api/v2/holding_institutions.json', { }, headers
      slugs = JSON.parse(response.body).collect do |hi|
        hi['slug']
      end
      expect(slugs).not_to include non_public.slug
    end
    it 'returns holding institutions filtered by institution type' do
      Fabricate(:holding_institution, institution_type: '###')
      get '/api/v2/holding_institutions.json',
          { page: 1, per_page: 1, type: '###' },
          headers
      expect(JSON.parse(response.body)[0]['institution_type']).to(
        eq('###')
      )
    end
    it 'returns holding institutions filtered by starting letter' do
      Fabricate(:holding_institution, authorized_name: '# Holding Inst')
      get '/api/v2/holding_institutions.json',
          { page: 1, per_page: 10, letter: '#' },
          headers
      expect(JSON.parse(response.body).length).to eq 1
    end
    it 'returns holding institutions filtered by portal' do
      portal = Fabricate :portal
      Fabricate(:holding_institution,
                repositories: [Fabricate(:empty_repository, portals: [portal])])
      get(
        '/api/v2/holding_institutions.json',
        { portal: portal.code },
        headers
      )
      json = JSON.parse(response.body)
      expect(json.length).to eq 1
      expect(json[0]['portals'][0]['code']).to eq portal.code
    end
    it 'returns holding institutions filtered by portal, letter and type' do
      portal = Fabricate :portal
      hi = Fabricate(:holding_institution,
                     repositories: [
                       Fabricate(:empty_repository, portals: [portal])
                     ])
      get(
        '/api/v2/holding_institutions.json',
        { portal: portal.code, letter: hi.authorized_name[0],
          type: hi.institution_type },
        headers
      )
      json = JSON.parse(response.body)
      expect(json.length).to eq 1
      expect(json[0]['authorized_name']).to eq hi.authorized_name
      expect(json[0]['portals'][0]['code']).to eq portal.code
    end
  end
  context 'can get single record info using #show' do
    context 'entity metadata' do
      before(:each) do
        @collection = Fabricate :empty_collection, public: true
        @holding_institution = HoldingInstitution.last
      end
      it 'returns all data about a holding institution' do
        get "/api/v2/holding_institutions/#{@holding_institution.slug}.json",
            {},
            headers
        json = JSON.parse(response.body)
        expect(response.content_type).to eq 'application/json'
        expect(response.status).to eq 200
        expect(json['slug']).to eq @holding_institution.slug

      end
    end
    context 'associated collection info' do
      before :each do
        @collection = Fabricate :collection_with_repo_and_item, public: true
        Fabricate :item,
                  collection: @collection, repository: @collection.repository,
                  portals: @collection.portals,
                  holding_institutions: @collection.holding_institutions
        other_hi = Fabricate :holding_institution
        @collection.items.last.holding_institution_ids = [other_hi.id]
        @collection.items.last.save
        @holding_institution = @collection.holding_institutions.first
      end
      it 'includes data about public collections' do
        get "/api/v2/holding_institutions/#{@holding_institution.slug}.json",
            {},
            headers
        json = JSON.parse(response.body)
        expect(json['public_collections'].length).to eq 1
        expect(json['public_collections'][0]['id']).to(
          eq(@collection.id)
        )
        json['public_collections'].each do |c|
          expect(c['public']).to be_truthy
        end
      end
      it 'includes information about assigned public collections' do
        get "/api/v2/holding_institutions/#{@holding_institution.slug}.json",
            {},
            headers
        json = JSON.parse(response.body)
        expect(json).to have_key'public_collections'
      end
      it 'returns item counts for collections that only count items with the
          holding institution assigned' do
        get "/api/v2/holding_institutions/#{@holding_institution.slug}.json",
            {},
            headers
        json = JSON.parse(response.body)
        returned_collection = json['public_collections'][0]
        expect(returned_collection).to have_key'collection_institution_item_count'
        expect(returned_collection['collection_institution_item_count']).to eq 1
      end
    end
  end
end