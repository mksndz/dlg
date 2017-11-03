require 'rails_helper'

RSpec.describe CollectionsController, type: :controller do
  let(:repository) { Fabricate(:repository) }
  let(:portal) { Fabricate :portal }
  before(:each) { sign_in Fabricate :super }
  let(:valid_attributes) do
    {
      slug: 'test-collection-slug',
      dcterms_title: "Test Collection DC Title\nTest Subtitle",
      display_title: 'Test Collections Display Title',
      dcterms_type: ['Text'],
      edm_is_shown_at: 'http://dlg.galileo.usg.edu',
      edm_is_shown_by: 'http://dlg.galileo.usg.edu',
      dcterms_provenance: 'DLG',
      dcterms_subject: 'Georgia',
      repository_id: Fabricate(:empty_repository).id,
      portal_ids: [Portal.last.id]
    }
  end
  let(:invalid_attributes) { { slug: 'invalid item slug' } }
  describe 'GET #index' do
    it 'assigns all collections as @collections' do
      collection = Collection.create! valid_attributes
      get :index
      expect(assigns(:collections)).to eq [collection]
    end
  end
  describe 'GET #show' do
    it 'assigns the requested collection as @collection' do
      collection = Collection.create! valid_attributes
      get :show, id: collection.id
      expect(assigns(:collection)).to eq collection
    end
  end
  describe 'GET #new' do
    it 'assigns a new collection as @collection' do
      get :new
      expect(assigns(:collection)).to be_a_new Collection
    end
  end
  describe 'GET #edit' do
    it 'assigns the requested collection as @collection' do
      collection = Collection.create! valid_attributes
      get :edit, id: collection.id
      expect(assigns(:collection)).to eq collection
    end
  end
  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Collection' do
        expect do
          post :create, collection: valid_attributes
        end.to change(Collection, :count).by 1
      end
      it 'assigns a newly created collection as @collection' do
        post :create, collection: valid_attributes
        expect(assigns(:collection)).to be_a Collection
        expect(assigns(:collection)).to be_persisted
      end
      it 'redirects to the created collection' do
        post :create, collection: valid_attributes
        expect(response).to redirect_to collection_path Collection.last
      end
    end
    context 'with invalid params' do
      it 'assigns a newly created but unsaved collection as @collection' do
        post :create, collection: invalid_attributes
        expect(assigns(:collection)).to be_a_new Collection
      end
      it 're-renders the "new" template' do
        post :create, collection: invalid_attributes
        expect(response).to render_template 'new'
      end
    end
  end
  describe 'PUT #update' do
    let(:collection) { Collection.create! valid_attributes }
    context 'with valid params' do
      let(:new_attributes) do
        { dcterms_title: "Updated Test DC Title\nNew Subtitle" }
      end
      it 'updates the requested collection' do
        put :update, id: collection.id, collection: new_attributes
        collection.reload
        expect(assigns(:collection).dcterms_title).to include 'New Subtitle'
      end
      it 'assigns the requested collection as @collection' do
        put :update, id: collection.id, collection: new_attributes
        expect(assigns(:collection)).to eq collection
      end
      it 'redirects to the collection' do
        put :update, id: collection.id, collection: new_attributes
        expect(response).to redirect_to collection_path collection
      end
    end
    context 'with invalid params' do
      it 'assigns the collection as @collection' do
        put :update, id: collection.to_param, collection: invalid_attributes
        expect(assigns(:collection)).to eq collection
      end
      it 're-renders the "edit" template' do
        put :update, id: collection.to_param, collection: invalid_attributes
        expect(response).to render_template 'edit'
      end
    end
  end
  describe 'DELETE #destroy' do
    context 'with valid params' do
      before :each do
        Fabricate :empty_collection
      end
      it 'destroys the requested collection' do
        expect do
          delete :destroy, id: Collection.last.id
        end.to change(Collection, :count).by(-1)
      end
      it 'redirects to the collections list' do
        delete :destroy, id: Collection.last.id
        expect(response).to redirect_to collections_url
      end
    end
  end
end
