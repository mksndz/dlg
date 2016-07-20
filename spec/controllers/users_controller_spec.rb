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
        email: 'test@user.com',
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

    it 'only shows a coordinator their created users' do
      sign_out super_user
      coordinator_user_2 = Fabricate(:coordinator)
      sign_in coordinator_user_2
      created_user = Fabricate(:basic) { creator coordinator_user_2 }
      alien_user = Fabricate(:user)
      get :index, {}, valid_session
      expect(assigns(:users)).to include created_user
      expect(assigns(:users)).not_to include alien_user
    end

    it 'assigns all users as @users' do
      user = User.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:users)).to include(user)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested user as @user' do
      user = User.create! valid_attributes
      get :show, {:id => user.to_param}, valid_session
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'GET #new' do
    it 'assigns a new user as @user' do
      get :new, {}, valid_session
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested user as @user' do
      user = User.create! valid_attributes
      get :edit, {:id => user.to_param}, valid_session
      expect(assigns(:user)).to eq(user)
    end

    it 'restricts coordinator users from editing Users they did not create' do
      sign_out super_user
      sign_in coordinator_user
      user = Fabricate(:user)
      get :edit, {:id => user.to_param}, valid_session
      expect(response).to redirect_to root_url
    end

    it 'allow coordinator users to edit Users they created' do
      sign_out super_user
      coordinator_user = Fabricate(:coordinator)
      sign_in coordinator_user
      user = Fabricate(:user) { creator coordinator_user }
      get :edit, {:id => user.to_param}, valid_session
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new User' do
        expect {
          post :create, {:user => valid_attributes}, valid_session
        }.to change(User, :count).by(1)
      end

      it 'assigns a newly created user as @user' do
        post :create, {:user => valid_attributes}, valid_session
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user)).to be_persisted
      end

      it 'redirects to the created user' do
        post :create, {:user => valid_attributes}, valid_session
        expect(response).to redirect_to(user_path(User.last))
      end

    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved user as @user' do
        post :create, {:user => invalid_attributes}, valid_session
        expect(assigns(:user)).to be_a_new(User)
      end

      it 're-renders the "new" template' do
        post :create, {:user => invalid_attributes}, valid_session
        expect(response).to render_template('new')
      end

    end

    context 'with invalid things selected' do

      before :each do
        sign_out super_user
        sign_in coordinator_user
      end

      it 'shows an error message when an invalid collection is passed' do


        collection = Fabricate :collection
        attributes = valid_attributes
        attributes[:collection_ids] = [collection.id]
        request.env['HTTP_REFERER'] = new_user_url
        post :create, { user: attributes }

        expect(response).to redirect_to new_user_path

      end

      it 'shows an error message when an invalid repository is passed' do

        repository = Fabricate :repository
        attributes = valid_attributes
        attributes[:repository_ids] = [repository.id]
        request.env['HTTP_REFERER'] = new_user_url
        post :create, { user: attributes }

        expect(response).to redirect_to new_user_path

      end

      it 'shows an error message if a role is specified' do

        attributes = valid_attributes
        attributes[:is_super] = 1
        request.env['HTTP_REFERER'] = new_user_url
        post :create, { user: attributes }

        expect(response).to redirect_to new_user_path

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

      it 'updates the requested user' do
        user = User.create! valid_attributes
        put :update, {:id => user.to_param, :user => new_attributes}, valid_session
        user.reload
        expect(assigns(:user).email).to eq 'changed@email.com'
      end

      it 'assigns the requested user as @user' do
        user = User.create! valid_attributes
        put :update, {:id => user.to_param, :user => new_attributes}, valid_session
        expect(assigns(:user)).to eq(user)
      end

      it 'redirects to the user' do
        user = User.create! valid_attributes
        put :update, {:id => user.to_param, :user => new_attributes}, valid_session
        expect(response).to redirect_to(user_path(user))
      end

      it 'restricts coordinator users from updating Users they did not create' do
        sign_out super_user
        sign_in coordinator_user
        user = User.create! valid_attributes
        post :update, {:id => user.to_param, :user => new_attributes}, valid_session
        expect(response).to redirect_to root_url
      end

      it 'allows coordinator users to update Users they created' do
        sign_out super_user
        coordinator_user = Fabricate(:coordinator)
        sign_in coordinator_user
        owned_user = Fabricate(:user)
        coordinator_user.users << owned_user
        post :update, {:id => owned_user.to_param, :user => new_attributes}, valid_session
        owned_user.reload
        expect(assigns(:user).email).to eq 'changed@email.com'
      end
    end

    context 'with invalid params' do
      it 'assigns the user as @user' do
        user = User.create! valid_attributes
        put :update, {:id => user.to_param, :user => invalid_attributes}, valid_session
        expect(assigns(:user)).to eq(user)
      end

      it 're-renders the "edit" template' do
        user = User.create! valid_attributes
        put :update, {:id => user.to_param, :user => invalid_attributes}, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested user' do
      user = User.create! valid_attributes
      expect {
        delete :destroy, {:id => user.to_param}, valid_session
      }.to change(User, :count).by(-1)
    end

    it 'redirects to the users list' do
      user = User.create! valid_attributes
      delete :destroy, {:id => user.to_param}, valid_session
      expect(response).to redirect_to(users_url)
    end
  end

end
