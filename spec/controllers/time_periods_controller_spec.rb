require 'rails_helper'

RSpec.describe TimePeriodsController, type: :controller do

  before(:each) do
    sign_in Fabricate(:super)
  end

  let(:valid_attributes) {
    { name: 'Pre-Cambrian Period' }
  }

  let(:invalid_attributes) {
    { name: nil }
  }

  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'assigns all time periods as @time_periods' do
      time_period = TimePeriod.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:time_periods)).to eq([time_period])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested time period as @time_period' do
      time_period = TimePeriod.create! valid_attributes
      get :show, {:id => time_period.to_param}, valid_session
      expect(assigns(:time_period)).to eq(time_period)
    end
  end

  describe 'GET #new' do
    it 'assigns a new time period as @time_period' do
      get :new, {}, valid_session
      expect(assigns(:time_period)).to be_a_new(TimePeriod)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested time period as @time_period' do
      time_period = TimePeriod.create! valid_attributes
      get :edit, {:id => time_period.to_param}, valid_session
      expect(assigns(:time_period)).to eq(time_period)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new time period' do
        expect {
          post :create, {:time_period => valid_attributes}, valid_session
        }.to change(TimePeriod, :count).by(1)
      end

      it 'assigns a newly created time period as @time_period' do
        post :create, {:time_period => valid_attributes}, valid_session
        expect(assigns(:time_period)).to be_a(TimePeriod)
        expect(assigns(:time_period)).to be_persisted
      end

      it 'redirects to the created time period' do
        post :create, {:time_period => valid_attributes}, valid_session
        expect(response).to redirect_to(time_period_path(TimePeriod.last))
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved time period as @time_period' do
        post :create, {:time_period => invalid_attributes}, valid_session
        expect(assigns(:time_period)).to be_a_new(TimePeriod)
      end

      it 're-renders the "new" template' do
        post :create, {:time_period => invalid_attributes}, valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        { name: 'Post-Cambrian Period' }
      }

      it 'updates the requested time period' do
        time_period = TimePeriod.create! valid_attributes
        put :update, {:id => time_period.to_param, :time_period => new_attributes}, valid_session
        time_period.reload
        expect(response).to redirect_to(time_period_path(time_period))
        expect(time_period.name).to eq 'Post-Cambrian Period'
      end

      it 'assigns the requested time_period as @time_period' do
        time_period = TimePeriod.create! valid_attributes
        put :update, {:id => time_period.to_param, :time_period => valid_attributes}, valid_session
        expect(assigns(:time_period)).to eq(time_period)
      end

      it 'redirects to the time period' do
        time_period = TimePeriod.create! valid_attributes
        put :update, {:id => time_period.to_param, :time_period => valid_attributes}, valid_session
        expect(response).to redirect_to(time_period_path(time_period))
      end
    end

    context 'with invalid params' do
      it 'assigns the time period as @time_period' do
        time_period = TimePeriod.create! valid_attributes
        put :update, {:id => time_period.to_param, :time_period => invalid_attributes}, valid_session
        expect(assigns(:time_period)).to eq(time_period)
      end

      it 're-renders the "edit" template' do
        time_period = TimePeriod.create! valid_attributes
        put :update, {:id => time_period.to_param, :time_period => invalid_attributes}, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested time period' do
      time_period = TimePeriod.create! valid_attributes
      expect {
        delete :destroy, {:id => time_period.to_param}, valid_session
      }.to change(TimePeriod, :count).by(-1)
    end

    it 'redirects to the time periods list' do
      time_period = TimePeriod.create! valid_attributes
      delete :destroy, {:id => time_period.to_param}, valid_session
      expect(response).to redirect_to(time_periods_url)
    end
  end

end
