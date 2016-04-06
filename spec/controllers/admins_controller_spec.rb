require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  let(:super_user) {
    Fabricate(:super)
  }

  let(:coordinator_user) {
    Fabricate(:coordinator)
  }

  before(:each) do
    sign_in super_user
  end

  let(:valid_attributes) {
    {
        email: 'test@admin.com',
        password: 'password',
    }
  }

  let(:invalid_attributes) {
    {
        email: nil,
    }
  }

  let(:valid_session) { {} }

  describe 'GET #index' do

    it 'only shows a coordinator their created admins' do
      sign_out super_user
      coordinator_user_2 = Fabricate(:coordinator)
      sign_in coordinator_user_2
      created_user = Fabricate(:basic) { creator coordinator_user_2 }
      alien_user = Fabricate(:admin)
      get :index, {}, valid_session
      expect(assigns(:users)).to include created_user
      expect(assigns(:users)).not_to include alien_user
    end

    it 'assigns all admins as @admins' do
      admin = Admin.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:users)).to include(admin)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested admin as @admin' do
      admin = Admin.create! valid_attributes
      get :show, {:id => admin.to_param}, valid_session
      expect(assigns(:admin)).to eq(admin)
    end
  end

  describe 'GET #new' do
    it 'assigns a new admin as @admin' do
      get :new, {}, valid_session
      expect(assigns(:admin)).to be_a_new(Admin)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested admin as @admin' do
      admin = Admin.create! valid_attributes
      get :edit, {:id => admin.to_param}, valid_session
      expect(assigns(:admin)).to eq(admin)
    end

    it 'restricts coordinator admins from editing Admins they did not create' do
      sign_out super_user
      sign_in coordinator_user
      admin = Fabricate(:admin)
      get :edit, {:id => admin.to_param}, valid_session
      expect(response).to redirect_to root_url
    end

    it 'allow coordinator admins to edit Admins they created' do
      sign_out super_user
      coordinator_user = Fabricate(:coordinator)
      sign_in coordinator_user
      admin = Fabricate(:admin) { creator coordinator_user }
      get :edit, {:id => admin.to_param}, valid_session
      expect(assigns(:admin)).to eq(admin)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Admin' do
        expect {
          post :create, {:admin => valid_attributes}, valid_session
        }.to change(Admin, :count).by(1)
      end

      it 'assigns a newly created admin as @admin' do
        post :create, {:admin => valid_attributes}, valid_session
        expect(assigns(:admin)).to be_a(Admin)
        expect(assigns(:admin)).to be_persisted
      end

      it 'redirects to the created admin' do
        post :create, {:admin => valid_attributes}, valid_session
        expect(response).to redirect_to(user_path(Admin.last))
      end

    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved admin as @admin' do
        post :create, {:admin => invalid_attributes}, valid_session
        expect(assigns(:admin)).to be_a_new(Admin)
      end

      it 're-renders the "new" template' do
        post :create, {:admin => invalid_attributes}, valid_session
        expect(response).to render_template('new')
      end

    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        {
          email: 'changed@email.com'
        }
      }

      it 'updates the requested admin' do
        admin = Admin.create! valid_attributes
        put :update, {:id => admin.to_param, :admin => new_attributes}, valid_session
        admin.reload
        expect(assigns(:admin).email).to eq 'changed@email.com'
      end

      it 'assigns the requested admin as @admin' do
        admin = Admin.create! valid_attributes
        put :update, {:id => admin.to_param, :admin => new_attributes}, valid_session
        expect(assigns(:admin)).to eq(admin)
      end

      it 'redirects to the admin' do
        admin = Admin.create! valid_attributes
        put :update, {:id => admin.to_param, :admin => new_attributes}, valid_session
        expect(response).to redirect_to(user_path(admin))
      end

      it 'restricts coordinator admins from updating Admins they did not create' do
        sign_out super_user
        sign_in coordinator_user
        admin = Admin.create! valid_attributes
        post :update, {:id => admin.to_param, :admin => new_attributes}, valid_session
        expect(response).to redirect_to root_url
      end

      it 'allows coordinator admins to update Admins they created' do
        sign_out super_user
        coordinator_user = Fabricate(:coordinator)
        sign_in coordinator_user
        owned_user = Fabricate(:admin)
        coordinator_user.admins << owned_user
        post :update, {:id => owned_user.to_param, :admin => new_attributes}, valid_session
        owned_user.reload
        expect(assigns(:admin).email).to eq 'changed@email.com'
      end
    end

    context 'with invalid params' do
      it 'assigns the admin as @admin' do
        admin = Admin.create! valid_attributes
        put :update, {:id => admin.to_param, :admin => invalid_attributes}, valid_session
        expect(assigns(:admin)).to eq(admin)
      end

      it 're-renders the "edit" template' do
        admin = Admin.create! valid_attributes
        put :update, {:id => admin.to_param, :admin => invalid_attributes}, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested admin' do
      admin = Admin.create! valid_attributes
      expect {
        delete :destroy, {:id => admin.to_param}, valid_session
      }.to change(Admin, :count).by(-1)
    end

    it 'redirects to the admins list' do
      admin = Admin.create! valid_attributes
      delete :destroy, {:id => admin.to_param}, valid_session
      expect(response).to redirect_to(admins_url)
    end
  end

end
