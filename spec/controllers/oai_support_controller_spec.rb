require 'rails_helper'

RSpec.describe OaiSupportController, type: :controller do

  describe 'GET #dump' do

    context 'with many records' do

      it 'it defaults to 50 rows' do

        PaperTrail.enabled = true

        Fabricate(:collection) {
          items(count: 51)
        }

        get :dump

        response_object = JSON.parse(response.body)

        expect(response_object['count']).to eq 50

      end

      it 'can paginate through all the records' do

        Fabricate(:collection) {
          items(count: 2)
        }

        get :dump, { rows: 1, page: 2 }

        response_object = JSON.parse(response.body)

        expect(response_object['count']).to eq 1
        expect(response_object['items'].last['id']).to eq(Item.last.id)

      end

      it 'can handle garbage params' do

        get :dump, { rows: 'HAXXOR', page: 'PWNED' }

        response_object = JSON.parse(response.body)

        expect(response_object['count']).to eq 0

      end

    end

    context 'with no parameters' do

      before :each do

        PaperTrail.enabled = true

        @item = Fabricate :item
        fleeting_item = Fabricate :item
        fleeting_item.destroy

        get :dump

        @response_object = JSON.parse(response.body)

      end

      it 'returns JSON type' do

        expect(response.content_type).to eq 'application/json'

      end

      it 'returns a JSON object with a count' do

        expect(@response_object).to have_key 'count'

      end

      it 'returns a JSON object with items' do

        expect(@response_object).to have_key 'items'

      end

      it 'returns a JSON object with items array' do

        expect(@response_object['items']).to be_an Array

      end

      it 'returns a JSON object with items array containing expected fields' do

        item = @response_object['items'][0]

        expect(item).to have_key 'id'
        expect(item).to have_key 'public'
        expect(item).to have_key 'record_id'
        expect(item).to have_key 'updated_at'

      end

      it 'returns a JSON object with items array containing information about a deleted item' do

        item = @response_object['items'][1]

        expect(item['id']).to eq 'deleted'

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

        get :dump, { date: '2016-01-01' }

        @response_object = JSON.parse(response.body)

      end

      it 'gets a JSON dump of all records updated since a provided date' do

        expect(@response_object['count']).to eq 1

      end

    end


  end

  describe 'GET #metadata' do

    before :each do

      @items = Fabricate.times(3, :item)

      item_ids = @items.collect { |i| i.id }.join(',')

      get :metadata, { ids: item_ids, format: :json }

    end

    it 'returns JSON type' do

      expect(response.content_type).to eq 'application/json'

    end

    it 'sets @items to the Items with the specified IDs' do

      expect(assigns(:items)).to eq @items

    end

    it 'returns nothing for a record where there is no ID match' do

      ids = @items.collect { |i| i.id }.join(',')

      ids += ',999999999'

      get :metadata, { ids: ids, format: :json }

      expect(assigns(:items).length).to eq 3

    end

  end

end
