require 'rails_helper'

RSpec.describe RepositoriesController, type: :controller do
  let(:portal) { Fabricate :portal }
  before(:each) { sign_in Fabricate :super }
  let(:valid_attributes) do
    {
      slug: 'test-controller-slug',
      title: 'Test Controller Title',
      portal_ids: [portal.id]
    }
  end
  let(:invalid_attributes) do
    { slug: 'invalid collection slug' }
  end
  describe 'GET #index' do
    it 'assigns all repositories as @repositories' do
      repository = Repository.create! valid_attributes
      get :index
      expect(assigns(:repositories)).to eq [repository]
    end
  end
  describe 'GET #show' do
    it 'assigns the requested repository as @repository' do
      repository = Repository.create! valid_attributes
      get :show, id: repository.id
      expect(assigns(:repository)).to eq repository
    end
  end
  describe 'GET #new' do
    it 'assigns a new repository as @repository' do
      get :new
      expect(assigns(:repository)).to be_a_new Repository
    end
  end
  describe 'GET #edit' do
    it 'assigns the requested repository as @repository' do
      repository = Repository.create! valid_attributes
      get :edit, id: repository.id
      expect(assigns(:repository)).to eq repository
    end
  end
  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Repository' do
        expect do
          post :create, repository: valid_attributes
        end.to change(Repository, :count).by 1
      end
      it 'assigns a newly created repository as @repository' do
        post :create, repository: valid_attributes
        expect(assigns(:repository)).to be_a Repository
        expect(assigns(:repository)).to be_persisted
      end
      it 'redirects to the created repository' do
        post :create, repository: valid_attributes
        expect(response).to redirect_to repository_path Repository.last
      end
    end
    context 'with invalid params' do
      it 'assigns a newly created but unsaved repository as @repository' do
        post :create, repository: invalid_attributes
        expect(assigns(:repository)).to be_a_new Repository
      end
      it 're-renders the "new" template' do
        post :create, repository: invalid_attributes
        expect(response).to render_template 'new'
      end
    end
  end
  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { title: 'Updated Title' } }
      it 'updates the requested repository' do
        repository = Repository.create! valid_attributes
        put :update, id: repository.id, repository: new_attributes
        repository.reload
        expect(assigns(:repository).title).to eq 'Updated Title'
      end
      it 'assigns the requested repository as @repository' do
        repository = Repository.create! valid_attributes
        put :update, id: repository.id, repository: valid_attributes
        expect(assigns(:repository)).to eq repository
      end
      it 'redirects to the repository' do
        repository = Repository.create! valid_attributes
        put :update, id: repository.id, repository: valid_attributes
        expect(response).to redirect_to repository_path repository
      end
    end
    context 'with invalid params' do
      it 'assigns the repository as @repository' do
        repository = Repository.create! valid_attributes
        put :update, id: repository.id, repository: invalid_attributes
        expect(assigns(:repository)).to eq repository
      end
      it 're-renders the "edit" template' do
        repository = Repository.create! valid_attributes
        put :update, id: repository.id, repository: invalid_attributes
        expect(response).to render_template 'edit'
      end
    end
  end
  describe 'DELETE #destroy' do
    before :each do
      Fabricate :repository
    end
    it 'destroys the requested repository' do
      expect do
        delete :destroy, id: Repository.last.id
      end.to change(Repository, :count).by(-1)
    end
    it 'redirects to the repositories list' do
      delete :destroy, id: Repository.last.id
      expect(response).to redirect_to repositories_url
    end
  end
end
