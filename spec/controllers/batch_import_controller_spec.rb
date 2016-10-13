require 'rails_helper'
require 'devise/test_helpers'

RSpec.describe BatchImportsController, type: :controller do

  before(:each) do
    sign_in Fabricate(:super)
  end

  let(:batch) { Fabricate :batch }

  # let(:batch_import) { Fabricate :batch_import }

  describe 'GET #index' do

  end

  describe 'GET #show' do

  end

  describe 'GET #new' do

    it 'assigns a new batch_import as @batch_import' do
      get :new, { batch_id: batch.id }
      expect(assigns(:batch_import)).to be_a_new(BatchImport)
    end

  end

  describe 'POST #create' do

    context 'with valid params' do

    end

    context 'with invalid params' do

    end

  end

end
