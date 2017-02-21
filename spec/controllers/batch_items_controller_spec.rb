require 'rails_helper'
require 'devise/test_helpers'

RSpec.describe BatchItemsController, type: :controller do

  before(:each) do
    sign_in Fabricate(:super)
  end

  let(:batch) {
    Fabricate(:batch)
  }

  let(:collection) {
    Fabricate(:collection)
  }

  let(:valid_attributes) {
    {
        slug: 'test-item-slug',
        dcterms_type: ['Text'],
        dcterms_title: "Test Item DC Title\nSubtitle",
        dc_date: '07-09-1975',
        dcterms_contributor: 'DLG',
        dcterms_spatial: 'Location',
        dc_right: 'CC-NA',
        collection_id: collection.id,
        batch_id: batch.id
    }
  }

  let(:invalid_attributes) {
    { slug: 'invalid item slug' }
  }

  describe 'GET #index' do
    it 'assigns all batch_items as @batch_items' do
      batch_item = Fabricate(:batch_item, batch: batch)
      get :index, { batch_id: batch.id }
      expect(assigns(:batch_items)).to include(batch_item)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested batch_item as @batch_item' do
      batch_item = Fabricate(:batch_item, batch: batch)
      get :show, { batch_id: batch.id, id: batch_item.id }
      expect(assigns(:batch_item)).to eq(batch_item)
    end
  end

  describe 'GET #new' do
    it 'assigns a new batch_item as @batch_item' do
      get :new, { batch_id: batch.id }
      expect(assigns(:batch_item)).to be_a_new(BatchItem)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested batch_item as @batch_item' do
      batch_item = Fabricate(:batch_item, batch: batch)
      get :edit, { batch_id: batch.id, id: batch_item.id }
      expect(assigns(:batch_item)).to eq(batch_item)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new BatchItem' do
        expect {
          post :create, { batch_id: batch.id, batch_item: valid_attributes }
        }.to change(BatchItem, :count).by(1)
      end

      it 'assigns a newly created batch_item as @batch_item' do
        post :create, { batch_id: batch.id, batch_item: valid_attributes }
        expect(assigns(:batch_item)).to be_a(BatchItem)
        expect(assigns(:batch_item)).to be_persisted
      end

      it 'redirects to the created batch_item' do
        post :create, { batch_id: batch.id, batch_item: valid_attributes }
        expect(response).to redirect_to(batch_batch_item_url(batch, BatchItem.last))
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved batch_item as @batch_item' do
        post :create, { batch_id: batch.id, batch_item: invalid_attributes }
        expect(assigns(:batch_item)).to be_a_new(BatchItem)
      end

      it 're-renders the "new" template' do
        post :create, { batch_id: batch.id, batch_item: invalid_attributes }
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        {
            slug: 'a-new-test-item-slug',
            dcterms_title: "New Title\nNew Subtitle"
        }
      }

      it 'updates the requested batch_item' do
        batch_item = Fabricate(:batch_item, batch: batch)
        put :update, { batch_id: batch.id, id: batch_item.id, batch_item: new_attributes }
        batch_item.reload
        expect(batch_item.dcterms_title).to include 'New Subtitle'
      end

      it 'assigns the requested batch_item as @batch_item' do
        batch_item = Fabricate(:batch_item, batch: batch)
        put :update, { batch_id: batch.id, id: batch_item.id, batch_item: new_attributes }
        expect(assigns(:batch_item)).to eq(batch_item)
      end

      it 'redirects to the batch_item' do
        batch_item = Fabricate(:batch_item, batch: batch)
        put :update, { batch_id: batch.id, id:  batch_item.id, batch_item: new_attributes }
        expect(response).to redirect_to(batch_batch_item_url(batch, batch_item))
      end
    end

    context 'with invalid params' do
      it 'assigns the batch_item as @batch_item' do
        batch_item = Fabricate(:batch_item, batch: batch)
        put :update, { batch_id: batch.id, id: batch_item.id, batch_item: invalid_attributes }
        expect(assigns(:batch_item)).to eq(batch_item)
      end

      it 're-renders the "edit" template' do
        batch_item = Fabricate(:batch_item, batch: batch)
        put :update, { batch_id: batch.id, id: batch_item.id, batch_item: invalid_attributes }
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested batch_item' do
      batch_item = Fabricate(:batch_item, batch: batch)
      expect {
        delete :destroy, { batch_id: batch.id, id: batch_item.id }
      }.to change(BatchItem, :count).by(-1)
    end

    it 'redirects to the batch_items list' do
      batch_item = Fabricate(:batch_item, batch: batch)
      delete :destroy, { batch_id: batch.id, id: batch_item.id }
      expect(response).to redirect_to(batch_batch_items_url(batch))
    end
  end

  describe 'POST #bulk_add' do

    it 'returns JSON' do

      Fabricate.times(4, :item)

      batch = Fabricate :batch

      ids = Item.all.map(&:id)

      post :bulk_add, { batch_id: batch.id , ids: ids.join(',') }

      expect(response.content_type).to eq 'application/json'
      expect(response.status).to eq 200
      expect(response.body).to eq ''
      expect(BatchItem.all.count).to eq 4

    end

    it 'can return error JSON if partial success' do

      Fabricate.times(3, :item)

      batch = Fabricate :batch

      ids = Item.all.map(&:id)

      ids << '0'

      post :bulk_add, { batch_id: batch.id , ids: ids.join(',') }

      response_object = JSON.parse response.body

      expect(response.content_type).to eq 'application/json'
      expect(response.status).to eq 207
      expect(BatchItem.all.count).to eq 3
      expect(response_object).to be_an Array
      expect(response_object.length).to eq 1
      expect(response_object[0]).to have_text 'not be found'

    end

    it 'can return error JSON on total failure' do


      batch = Fabricate :batch

      ids = [0]

      post :bulk_add, { batch_id: batch.id , ids: ids.join(',') }

      response_object = JSON.parse response.body

      expect(response.content_type).to eq 'application/json'
      expect(response.status).to eq 422
      expect(BatchItem.all.count).to eq 0
      expect(response_object).to be_an Array
      expect(response_object.length).to eq 1
      expect(response_object[0]).to have_text 'not be found'

    end

  end

end
