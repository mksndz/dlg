require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { Fabricate :user }
  let(:valid_attributes) do
    {
      email: 'test@user.com',
      password: 'password'
    }
  end
  let(:invalid_attributes) { { email: nil } }
  context 'for super user' do
    let(:super_user) { Fabricate(:super) }
    before(:each) { sign_in super_user }
    describe 'GET #index' do
      it 'assigns all users as @users' do
        user = User.create! valid_attributes
        get :index
        expect(assigns(:users)).to include user
      end
    end
    describe 'GET #show' do
      it 'assigns the requested user as @user' do
        get :show, id: super_user.id
        expect(assigns(:user)).to eq super_user
      end
    end
    describe 'GET #new' do
      it 'assigns a new user as @user' do
        get :new
        expect(assigns(:user)).to be_a_new User
      end
    end
    describe 'GET #edit' do
      it 'assigns the requested user as @user' do
        get :edit, id: super_user.id
        expect(assigns(:user)).to eq super_user
      end
    end
    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new User' do
          expect do
            post :create, user: valid_attributes
          end.to change(User, :count).by 1
        end
        it 'assigns a newly created user as @user' do
          post :create, user: valid_attributes
          expect(assigns(:user)).to be_a User
          expect(assigns(:user)).to be_persisted
        end
        it 'redirects to the created user' do
          post :create, user: valid_attributes
          expect(response).to redirect_to user_path User.last
        end
      end
      context 'with invalid params' do
        it 'assigns a newly created but unsaved user as @user' do
          post :create, user: invalid_attributes
          expect(assigns(:user)).to be_a_new User
        end
        it 're-renders the "new" template' do
          post :create, user: invalid_attributes
          expect(response).to render_template 'new'
        end
      end
    end
    describe 'PUT #update' do
      context 'with valid params' do
        let(:new_attributes) { { email: 'changed@email.com' } }
        it 'updates the requested user' do
          put :update, id: user.id, user: new_attributes
          user.reload
          expect(assigns(:user).email).to eq 'changed@email.com'
        end
        it 'assigns the requested user as @user' do
          put :update, id: user.id, user: new_attributes
          expect(assigns(:user)).to eq user
        end
        it 'redirects to the user' do
          put :update, id: user.id, user: new_attributes
          expect(response).to redirect_to user_path user
        end
      end
      context 'with invalid params' do
        it 'assigns the user as @user' do
          put :update, id: user.id, user: invalid_attributes
          expect(assigns(:user)).to eq user
        end
        it 're-renders the "edit" template' do
          put :update, id: user.id, user: invalid_attributes
          expect(response).to render_template 'edit'
        end
      end
    end
    describe 'DELETE #destroy' do
      before(:each) { Fabricate :user }
      it 'destroys the requested user' do
        expect do
          delete :destroy, id: User.last.id
        end.to change(User, :count).by(-1)
      end
      it 'redirects to the users list' do
        delete :destroy, id: User.last.id
        expect(response).to redirect_to users_url
      end
    end
  end
  context 'for coordinator user' do
    let(:coordinator_user) { Fabricate :coordinator }
    context 'access control error handling' do
      let(:repository) { Fabricate :repository }
      before(:each) { sign_in coordinator_user }
      describe 'POST #create' do
        it 'shows an error message when an invalid collection is passed' do
          attributes = valid_attributes
          attributes[:collection_ids] = [repository.collections.first.id]
          request.env['HTTP_REFERER'] = new_user_url
          post :create, user: attributes
          expect(response).to redirect_to new_user_path
        end
        it 'shows an error message when an invalid repository is passed' do
          attributes = valid_attributes
          attributes[:repository_ids] = [repository.id]
          request.env['HTTP_REFERER'] = new_user_url
          post :create, user: attributes
          expect(response).to redirect_to new_user_path
        end
        it 'shows an error message if a role is specified' do
          attributes = valid_attributes
          attributes[:is_super] = '1'
          request.env['HTTP_REFERER'] = new_user_url
          post :create, user: attributes
          expect(response).to redirect_to new_user_path
        end
      end
    end
  end
end
