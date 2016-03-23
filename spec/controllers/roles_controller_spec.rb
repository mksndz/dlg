require 'rails_helper'

RSpec.describe Meta::RolesController, type: :controller do

  before(:each) do
    sign_in Fabricate(:super)
  end

  let(:valid_attributes) {
    { name: 'Test Role Name' }
  }

  let(:invalid_attributes) {
    { name: nil }
  }

  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'assigns all roles as @roles' do
      role = Meta::Role.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:roles)).to include(role)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested role as @role' do
      role = Meta::Role.create! valid_attributes
      get :show, {:id => role.to_param}, valid_session
      expect(assigns(:role)).to eq(role)
    end
  end

  describe 'GET #new' do
    it 'assigns a new role as @role' do
      get :new, {}, valid_session
      expect(assigns(:role)).to be_a_new(Meta::Role)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested role as @role' do
      role = Meta::Role.create! valid_attributes
      get :edit, {:id => role.to_param}, valid_session
      expect(assigns(:role)).to eq(role)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Role' do
        expect {
          post :create, {:role => valid_attributes}, valid_session
        }.to change(Meta::Role, :count).by(1)
      end

      it 'assigns a newly created role as @role' do
        post :create, {:role => valid_attributes}, valid_session
        expect(assigns(:role)).to be_a(Meta::Role)
        expect(assigns(:role)).to be_persisted
      end

      it 'redirects to the created role' do
        post :create, {:role => valid_attributes}, valid_session
        expect(response).to redirect_to(Meta::Role.last)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved role as @role' do
        post :create, {:role => invalid_attributes}, valid_session
        expect(assigns(:role)).to be_a_new(Meta::Role)
      end

      it 're-renders the "new" template' do
        post :create, {:role => invalid_attributes}, valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        { name: 'Revised Role Name' }
      }

      it 'updates the requested role' do
        role = Meta::Role.create! valid_attributes
        put :update, {:id => role.to_param, :role => new_attributes}, valid_session
        role.reload
        expect(assigns(:role).name).to eq 'Revised Role Name'
      end

      it 'assigns the requested role as @role' do
        role = Meta::Role.create! valid_attributes
        put :update, {:id => role.to_param, :role => valid_attributes}, valid_session
        expect(assigns(:role)).to eq(role)
      end

      it 'redirects to the role' do
        role = Meta::Role.create! valid_attributes
        put :update, {:id => role.to_param, :role => valid_attributes}, valid_session
        expect(response).to redirect_to(role)
      end
    end

    context 'with invalid params' do
      it 'assigns the role as @role' do
        role = Meta::Role.create! valid_attributes
        put :update, {:id => role.to_param, :role => invalid_attributes}, valid_session
        expect(assigns(:role)).to eq(role)
      end

      it 're-renders the "edit" template' do
        role = Meta::Role.create! valid_attributes
        put :update, {:id => role.to_param, :role => invalid_attributes}, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested role' do
      role = Meta::Role.create! valid_attributes
      expect {
        delete :destroy, {:id => role.to_param}, valid_session
      }.to change(Meta::Role, :count).by(-1)
    end

    it 'redirects to the roles list' do
      role = Meta::Role.create! valid_attributes
      delete :destroy, {:id => role.to_param}, valid_session
      expect(response).to redirect_to(admin_roles_url)
    end
  end

end
