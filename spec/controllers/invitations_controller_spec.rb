require 'rails_helper'

RSpec.describe InvitationsController, type: :controller do
  let(:super_user) { Fabricate(:super) }
  let(:repository) { Fabricate(:repository) }
  before(:each) do
    sign_in super_user
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end
  let(:valid_attributes) do
    {
      email: 'test@user.com',
      collection_ids: [repository.collections.first.id],
      repository_ids: [repository.id]
    }
  end
  let(:invalid_attributes) { { email: nil } }
  describe 'GET #index' do
    it 'assigns all pending invitations as @pending_invitations' do
      user = User.invite!(email: 'test@test.com') do |u|
        u.skip_invitation = true
      end
      user.invitation_sent_at = Time.now
      user.save
      get :index
      expect(assigns(:pending_invitations)).to include user
    end
  end
  describe 'POST #create' do
    context 'with valid params' do
      it 'assigns a newly created user as @user with no roles' do
        post :create, user: valid_attributes
        expect(assigns(:user).roles).to be_empty
      end
      it 'assigns a newly created user as @user with assigned entities' do
        post :create, user: valid_attributes
        expect(assigns(:user).collections).not_to be_empty
        expect(assigns(:user).repositories).not_to be_empty
      end
      it 'assigns a newly created user as @user with creator set to user who
          created the invite' do
        post :create, user: valid_attributes
        expect(assigns(:user).creator.email).to eq super_user.email
      end
    end
  end

end