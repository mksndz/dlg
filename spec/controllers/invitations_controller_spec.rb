require 'rails_helper'

RSpec.describe InvitationsController, type: :controller do

  let(:super_user) {
    Fabricate(:super)
  }

  let(:coordinator_user) {
    Fabricate(:coordinator)
  }

  let(:basic_role) {
    Fabricate(:basic_role)
  }

  let(:repository) {
    Fabricate(:repository)
  }

  let(:collection) {
    Fabricate(:collection)
  }

  before(:each) do
    sign_in super_user
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  let(:valid_attributes) {
    {
        email: 'test@user.com',
        role_ids: [basic_role.id],
        collection_ids: [collection.id],
        repository_ids: [repository.id]
    }
  }

  let(:invalid_attributes) {
    {
        email: nil,
    }
  }

  let(:valid_session) { {} }

  describe 'GET #index' do

    it 'assigns all pending invitations as @pending_invitations' do
      user = User.invite!(email: 'test@test.com') do |u|
        u.skip_invitation = true
      end
      user.invitation_sent_at = Time.now
      user.save
      get :index, {}, valid_session
      expect(assigns(:pending_invitations)).to include user

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

      it 'assigns a newly created user as @user with basic role' do
        post :create, {:user => valid_attributes}, valid_session
        expect(assigns(:user).roles).not_to be_empty
      end

      it 'assigns a newly created user as @user with assigned entities' do
        post :create, {:user => valid_attributes}, valid_session
        expect(assigns(:user).collections).not_to be_empty
        expect(assigns(:user).repositories).not_to be_empty
      end

      it 'assigns a newly created user as @user with creator set to user who created the invite' do
        post :create, {:user => valid_attributes}, valid_session
        expect(assigns(:user).creator.email).to eq super_user.email
      end
    end
  end

end