require 'rails_helper'

RSpec.describe CollectionsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Collection. As you add validations to Collection, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
        slug: 'test-collection-slug',
        display_title: 'Test Collections Display Title',
        dc_title: [
            'Test Collection DC Title'
        ]
    }  }

  let(:invalid_attributes) {
    {
        slug: 'invalid item slug'
    }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CollectionsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'assigns all collections as @collections' do
      collection = Collection.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:collections)).to eq([collection])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested collection as @collection' do
      collection = Collection.create! valid_attributes
      get :show, {:id => collection.to_param}, valid_session
      expect(assigns(:collection)).to eq(collection)
    end
  end

  describe 'GET #new' do
    it 'assigns a new collection as @collection' do
      get :new, {}, valid_session
      expect(assigns(:collection)).to be_a_new(Collection)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested collection as @collection' do
      collection = Collection.create! valid_attributes
      get :edit, {:id => collection.to_param}, valid_session
      expect(assigns(:collection)).to eq(collection)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Collection' do
        expect {
          post :create, {:collection => valid_attributes}, valid_session
        }.to change(Collection, :count).by(1)
      end

      it 'assigns a newly created collection as @collection' do
        post :create, {:collection => valid_attributes}, valid_session
        expect(assigns(:collection)).to be_a(Collection)
        expect(assigns(:collection)).to be_persisted
      end

      it 'redirects to the created collection' do
        post :create, {:collection => valid_attributes}, valid_session
        expect(response).to redirect_to(Collection.last)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved collection as @collection' do
        post :create, {:collection => invalid_attributes}, valid_session
        expect(assigns(:collection)).to be_a_new(Collection)
      end

      it 're-renders the "new" template' do
        post :create, {:collection => invalid_attributes}, valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        {
            dc_title: [
                'Updated Test DC Title'
            ]
        }
      }

      it 'updates the requested collection' do
        collection = Collection.create! valid_attributes
        put :update, {:id => collection.to_param, :collection => new_attributes}, valid_session
        collection.reload
        expect(assigns(:collection).dc_title).to include 'Updated Test DC Title'
      end

      it 'assigns the requested collection as @collection' do
        collection = Collection.create! valid_attributes
        put :update, {:id => collection.to_param, :collection => valid_attributes}, valid_session
        expect(assigns(:collection)).to eq(collection)
      end

      it 'redirects to the collection' do
        collection = Collection.create! valid_attributes
        put :update, {:id => collection.to_param, :collection => valid_attributes}, valid_session
        expect(response).to redirect_to(collection)
      end
    end

    context 'with invalid params' do
      it 'assigns the collection as @collection' do
        collection = Collection.create! valid_attributes
        put :update, {:id => collection.to_param, :collection => invalid_attributes}, valid_session
        expect(assigns(:collection)).to eq(collection)
      end

      it 're-renders the "edit" template' do
        collection = Collection.create! valid_attributes
        put :update, {:id => collection.to_param, :collection => invalid_attributes}, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested collection' do
      collection = Collection.create! valid_attributes
      expect {
        delete :destroy, {:id => collection.to_param}, valid_session
      }.to change(Collection, :count).by(-1)
    end

    it 'redirects to the collections list' do
      collection = Collection.create! valid_attributes
      delete :destroy, {:id => collection.to_param}, valid_session
      expect(response).to redirect_to(collections_url)
    end
  end

end
