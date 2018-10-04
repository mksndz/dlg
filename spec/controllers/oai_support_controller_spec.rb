require 'rails_helper'

RSpec.describe OaiSupportController, type: :controller do
  describe 'GET #dump' do
    context 'without authorization' do
      it 'returns unauthorized' do
        get :dump
        expect(response.code).to eq '401'
      end
    end
    context 'with authorization' do
      before :each do
        request.headers['X-User-Token'] = Rails.application.secrets.oai_token
      end
      context 'parameter support' do
        it 'sets a class to Repository' do
          get :dump, class: 'repository'
          expect(assigns(:class)).to eq Repository
        end
        it 'sets a class to Collection' do
          get :dump, class: 'collection'
          expect(assigns(:class)).to eq Collection
        end
        it 'sets a class to Item' do
          get :dump, class: 'item'
          expect(assigns(:class)).to eq Item
        end
        it 'handles unsupported classes' do
          get :dump, class: 'User'
          expect(response.code).to eq '400'
        end
        it 'it defaults to 50 rows' do
          get :dump, class: 'item'
          expect(assigns(:rows)).to eq 50
        end
        it 'disallows over 50000 rows' do
          get :dump, class: 'item', rows: 50001
          expect(assigns(:rows)).to eq 50000
        end
        it 'can handle garbage params' do
          get :dump, rows: 'HAXXOR', page: 'PWNED', class: 'item'
          response_object = JSON.parse(response.body)
          expect(response_object['total_count']).to eq 0
        end
        context 'pagination' do
          before(:each) { Fabricate.times 2, :repository }
          it 'can paginate through all the items' do
            get :dump, class: 'item', rows: 1, page: 2
            response_object = JSON.parse(response.body)
            expect(response_object['total_count']).to eq 2
            expect(response_object['records'].last['id']).to eq Item.last.id
          end
          it 'can paginate through all the collections' do
            get :dump, class: 'collection', rows: 1, page: 2
            response_object = JSON.parse(response.body)
            expect(response_object['total_count']).to eq 2
            expect(response_object['records'].last['id']).to eq Collection.last.id
            expect(response_object['records'].last['record_id']).to eq Collection.last.record_id
          end
        end
      end
      context 'returned objects' do
        before :each do
          PaperTrail.enabled = true
          Fabricate.times 3, :repository
          @item1 = Item.first
          @item2 = Item.second
          Item.third.destroy
          get :dump, class: 'item'
          @response_object = JSON.parse response.body
        end
        it 'returns JSON type' do
          expect(response.content_type).to eq 'application/json'
        end
        it 'returns a JSON object with a count' do
          expect(@response_object).to have_key 'total_count'
        end
        it 'returns a JSON object with items' do
          expect(@response_object).to have_key 'records'
        end
        it 'returns a JSON object with items array' do
          expect(@response_object['records']).to be_an Array
        end
        it 'returns a JSON object with items array containing expected fields' do
          item = @response_object['records'][0]
          expect(item).to have_key 'id'
          expect(item).to have_key 'public'
          expect(item).to have_key 'record_id'
          expect(item).to have_key 'updated_at'
        end
        context 'with a date parameter' do
          before :each do
            @item1.updated_at = '2015-01-01'
            @item1.save
            @item2.updated_at = '2017-01-01'
            @item2.save
            get :dump, class: 'item', date: '2016-01-01'
            @response_object = JSON.parse response.body
          end
          it 'gets a JSON dump of all records updated since a provided date' do
            expect(@response_object['total_count']).to eq 1
          end
        end
      end
    end
  end
  describe 'GET #deleted' do
    before :each do
      request.headers['X-User-Token'] = Rails.application.secrets.oai_token
      PaperTrail.enabled = true
      Fabricate :repository
      Item.last.destroy
      get :deleted
      @response_object = JSON.parse response.body
    end
    it 'returns a JSON object with items array containing information about a
        deleted item' do
      record = @response_object['records'][0]
      expect(record['id']).to eq 'deleted'
    end
  end
  describe 'GET #metadata' do
    before :each do
      request.headers['X-User-Token'] = Rails.application.secrets.oai_token
      Fabricate.times 3, :repository
      get(
        :metadata,
        class: 'item', ids: Item.pluck(:id).flatten.join(','), format: :json
      )
    end
    it 'returns JSON type' do
      expect(response.content_type).to eq 'application/json'
    end
    it 'sets records to the Items with the specified IDs' do
      expect(assigns(:records).collect(&:id)).to eq Item.pluck :id
    end
    context 'record metadata hash contents' do
      before :each do
        data = JSON.parse response.body
        @record_hash = data[0]
        @item = Item.find(data[0]['id'])
      end
      it 'response to contain portal code' do
        expect(@record_hash['portals'][0]).to have_key 'code'
      end
      it 'contains dcterms_provenance fields corresponding to holding_institutions' do
        expect(@record_hash).to have_key 'dcterms_provenance'
        expect(@record_hash['dcterms_provenance']).to include @item.holding_institution.display_name
      end
    end
    it 'returns nothing for a record where there is no ID match' do
      ids = Item.pluck(:id).join(',')
      ids += ',999999999'
      get :metadata, ids: ids, format: :json
      expect(assigns(:records).length).to eq 3
    end
  end
end
