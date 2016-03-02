require 'rails_helper'
require 'devise/test_helpers'

RSpec.describe BatchesController, type: :controller do

  before(:each) do
    sign_in Fabricate(:admin)
  end

  let(:user) {
    Fabricate(:user)
  }

  let(:valid_attributes) {
    {
        name: 'Test Batch',
        user_id: user.id
    }
  }

  let(:invalid_attributes) {
    {
        name: nil
    }
  }

  let(:valid_session) { { } }

  describe 'GET #index' do
    it 'assigns all batches as @batches' do
      batch = Batch.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:batches)).to eq([batch])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested batch as @batch' do
      batch = Batch.create! valid_attributes
      get :show, {:id => batch.to_param}, valid_session
      expect(assigns(:batch)).to eq(batch)
    end
  end

  describe 'GET #new' do
    it 'assigns a new batch as @batch' do
      get :new, {}, valid_session
      expect(assigns(:batch)).to be_a_new(Batch)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested batch as @batch' do
      batch = Batch.create! valid_attributes
      get :edit, {:id => batch.to_param}, valid_session
      expect(assigns(:batch)).to eq(batch)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Batch' do
        expect {
          post :create, {:batch => valid_attributes}, valid_session
        }.to change(Batch, :count).by(1)
      end

      it 'assigns a newly created batch as @batch' do
        post :create, {:batch => valid_attributes}, valid_session
        expect(assigns(:batch)).to be_a(Batch)
        expect(assigns(:batch)).to be_persisted
      end

      it 'redirects to the created batch' do
        post :create, {:batch => valid_attributes}, valid_session
        expect(response).to redirect_to(Batch.last)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved batch as @batch' do
        post :create, {:batch => invalid_attributes}, valid_session
        expect(assigns(:batch)).to be_a_new(Batch)
      end

      it 're-renders the "new" template' do
        post :create, {:batch => invalid_attributes}, valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        {
            notes: 'Notes test'
        }
      }

      it 'updates the requested batch' do
        batch = Batch.create! valid_attributes
        put :update, {:id => batch.to_param, :batch => new_attributes}, valid_session
        batch.reload
        expect(batch.notes).to eq 'Notes test'
      end

      it 'assigns the requested batch as @batch' do
        batch = Batch.create! valid_attributes
        put :update, {:id => batch.to_param, :batch => valid_attributes}, valid_session
        expect(assigns(:batch)).to eq(batch)
      end

      it 'redirects to the batch' do
        batch = Batch.create! valid_attributes
        put :update, {:id => batch.to_param, :batch => valid_attributes}, valid_session
        expect(response).to redirect_to(batch)
      end
    end

    context 'with invalid params' do
      it 'assigns the batch as @batch' do
        batch = Batch.create! valid_attributes
        put :update, {:id => batch.to_param, :batch => invalid_attributes}, valid_session
        expect(assigns(:batch)).to eq(batch)
      end

      it 're-renders the "edit" template' do
        batch = Batch.create! valid_attributes
        put :update, {:id => batch.to_param, :batch => invalid_attributes}, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested batch' do
      batch = Batch.create! valid_attributes
      expect {
        delete :destroy, {:id => batch.to_param}, valid_session
      }.to change(Batch, :count).by(-1)
    end

    it 'redirects to the batches list' do
      batch = Batch.create! valid_attributes
      delete :destroy, {:id => batch.to_param}, valid_session
      expect(response).to redirect_to(batches_url)
    end
  end

end
