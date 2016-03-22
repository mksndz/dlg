require 'rails_helper'

RSpec.describe Admin::SubjectsController, type: :controller do

  before(:each) do
    sign_in Fabricate(:admin)
  end

  let(:valid_attributes) {
    { name: 'Rspec Testing' }
  }

  let(:invalid_attributes) {
    { name: nil }
  }

  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'assigns all subjects as @subjects' do
      subject = Subject.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:subjects)).to eq([subject])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested subject as @subject' do
      subject = Subject.create! valid_attributes
      get :show, {:id => subject.to_param}, valid_session
      expect(assigns(:subject)).to eq(subject)
    end
  end

  describe 'GET #new' do
    it 'assigns a new subject as @subject' do
      get :new, {}, valid_session
      expect(assigns(:subject)).to be_a_new(Subject)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested subject as @subject' do
      subject = Subject.create! valid_attributes
      get :edit, {:id => subject.to_param}, valid_session
      expect(assigns(:subject)).to eq(subject)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Subject' do
        expect {
          post :create, {:subject => valid_attributes}, valid_session
        }.to change(Subject, :count).by(1)
      end

      it 'assigns a newly created subject as @subject' do
        post :create, {:subject => valid_attributes}, valid_session
        expect(assigns(:subject)).to be_a(Subject)
        expect(assigns(:subject)).to be_persisted
      end

      it 'redirects to the created subject' do
        post :create, {:subject => valid_attributes}, valid_session
        expect(response).to redirect_to(admin_subject_path(Subject.last))
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved subject as @subject' do
        post :create, {:subject => invalid_attributes}, valid_session
        expect(assigns(:subject)).to be_a_new(Subject)
      end

      it 're-renders the "new" template' do
        post :create, {:subject => invalid_attributes}, valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        { name: 'Advanced Rspec Testing' }
      }

      it 'updates the requested subject' do
        subject = Subject.create! valid_attributes
        put :update, {:id => subject.to_param, :subject => new_attributes}, valid_session
        subject.reload
        expect(response).to redirect_to(admin_subject_path(subject))
        expect(subject.name).to eq 'Advanced Rspec Testing'
      end

      it 'assigns the requested subject as @subject' do
        subject = Subject.create! valid_attributes
        put :update, {:id => subject.to_param, :subject => valid_attributes}, valid_session
        expect(assigns(:subject)).to eq(subject)
      end

      it 'redirects to the subject' do
        subject = Subject.create! valid_attributes
        put :update, {:id => subject.to_param, :subject => valid_attributes}, valid_session
        expect(response).to redirect_to(admin_subject_path(subject))
      end
    end

    context 'with invalid params' do
      it 'assigns the subject as @subject' do
        subject = Subject.create! valid_attributes
        put :update, {:id => subject.to_param, :subject => invalid_attributes}, valid_session
        expect(assigns(:subject)).to eq(subject)
      end

      it 're-renders the "edit" template' do
        subject = Subject.create! valid_attributes
        put :update, {:id => subject.to_param, :subject => invalid_attributes}, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested subject' do
      subject = Subject.create! valid_attributes
      expect {
        delete :destroy, {:id => subject.to_param}, valid_session
      }.to change(Subject, :count).by(-1)
    end

    it 'redirects to the subjects list' do
      subject = Subject.create! valid_attributes
      delete :destroy, {:id => subject.to_param}, valid_session
      expect(response).to redirect_to(admin_subjects_url)
    end
  end

end
