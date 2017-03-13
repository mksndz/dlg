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

          get :dump, { class: 'repository' }

          expect(assigns(:class)).to eq Repository

        end

        it 'sets a class to Collection' do

          get :dump, { class: 'collection' }

          expect(assigns(:class)).to eq Collection

        end

        it 'sets a class to Item' do

          get :dump, { class: 'item' }

          expect(assigns(:class)).to eq Item

        end

        it 'handles unsupported classes' do

          get :dump, { class: 'User' }

          expect(response.code).to eq '400'

        end

        it 'it defaults to 50 rows' do

          get :dump, { class: 'item' }

          expect(assigns(:rows)).to eq 50

        end

        it 'disallows over 50000 rows' do

          get :dump, { class: 'item', rows: 50001 }

          expect(assigns(:rows)).to eq 50000

        end

        it 'can handle garbage params' do

          get :dump, { rows: 'HAXXOR', page: 'PWNED', class: 'item' }

          response_object = JSON.parse(response.body)

          expect(response_object['total_count']).to eq 0

        end

        context 'pagination' do

          it 'can paginate through all the items' do

            Fabricate(:collection) {
              items(count: 2)
            }

            get :dump, { class: 'item', rows: 1, page: 2 }

            response_object = JSON.parse(response.body)

            expect(response_object['total_count']).to eq 2
            expect(response_object['records'].last['id']).to eq(Item.last.id)

          end

          it 'can paginate through all the collections' do

            Fabricate.times(2, :collection)

            get :dump, { class: 'collection', rows: 1, page: 2 }

            response_object = JSON.parse(response.body)

            expect(response_object['total_count']).to eq 2
            expect(response_object['records'].last['id']).to eq(Collection.last.id)

          end

        end

      end

      context 'returned objects' do

        before :each do

          PaperTrail.enabled = true

          @item = Fabricate :item
          fleeting_item = Fabricate :item
          fleeting_item.destroy

          get :dump, { class: 'item' }

          @response_object = JSON.parse(response.body)

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

      end

      context 'with a date parameter' do

        before :each do

          @i1 = Fabricate(:item) {
            updated_at '2015-01-01'
          }

          @i2 = Fabricate(:item) {
            updated_at '2017-01-01'
          }

          get :dump, { class: 'item', date: '2016-01-01' }

          @response_object = JSON.parse(response.body)

        end

        it 'gets a JSON dump of all records updated since a provided date' do

          expect(@response_object['total_count']).to eq 1

        end

      end

    end

  end

  describe 'GET #deleted' do

    before :each do

      request.headers['X-User-Token'] = Rails.application.secrets.oai_token

      PaperTrail.enabled = true

      @item = Fabricate :item
      fleeting_item = Fabricate :item
      fleeting_item.destroy

      get :deleted

      @response_object = JSON.parse(response.body)

    end

    it 'returns a JSON object with items array containing information about a deleted item' do

      record = @response_object['records'][0]

      expect(record['id']).to eq 'deleted'

    end

  end

  describe 'GET #metadata' do

    before :each do

      request.headers['X-User-Token'] = Rails.application.secrets.oai_token

      @items = Fabricate.times(3, :item)

      item_ids = @items.collect { |i| i.id }.join(',')

      get :metadata, { class: 'item', ids: item_ids, format: :json }

    end

    it 'returns JSON type' do

      expect(response.content_type).to eq 'application/json'

    end

    it 'sets @items to the Items with the specified IDs' do

      expect(assigns(:records)).to eq @items

    end

    it 'returns nothing for a record where there is no ID match' do

      ids = @items.collect { |i| i.id }.join(',')

      ids += ',999999999'

      get :metadata, { ids: ids, format: :json }

      expect(assigns(:records).length).to eq 3

    end

  end

end
