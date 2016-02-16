require 'rails_helper'
require 'devise/test_helpers'

RSpec.describe BatchItemsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # BatchItem. As you add validations to BatchItem, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
        slug: 'test-item-slug',
        dc_title: [
            'Test Item DC Title'
        ]
    }
  }

  let(:invalid_attributes) {
    {
        slug: 'invalid item slug'
    }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # BatchItemsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all batch_items as @batch_items" do
      batch_item = BatchItem.create! valid_attributes
      get :index, {batch_id: '1'}, valid_session
      expect(assigns(:batch_items)).to eq([batch_item])
    end
  end

  describe "GET #show" do
    it "assigns the requested batch_item as @batch_item" do
      batch_item = BatchItem.create! valid_attributes
      get :show, {:id => batch_item.to_param}, valid_session
      expect(assigns(:batch_item)).to eq(batch_item)
    end
  end

  describe "GET #new" do
    it "assigns a new batch_item as @batch_item" do
      get :new, {}, valid_session
      expect(assigns(:batch_item)).to be_a_new(BatchItem)
    end
  end

  describe "GET #edit" do
    it "assigns the requested batch_item as @batch_item" do
      batch_item = BatchItem.create! valid_attributes
      get :edit, {:id => batch_item.to_param}, valid_session
      expect(assigns(:batch_item)).to eq(batch_item)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new BatchItem" do
        expect {
          post :create, {:batch_item => valid_attributes}, valid_session
        }.to change(BatchItem, :count).by(1)
      end

      it "assigns a newly created batch_item as @batch_item" do
        post :create, {:batch_item => valid_attributes}, valid_session
        expect(assigns(:batch_item)).to be_a(BatchItem)
        expect(assigns(:batch_item)).to be_persisted
      end

      it "redirects to the created batch_item" do
        post :create, {:batch_item => valid_attributes}, valid_session
        expect(response).to redirect_to(BatchItem.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved batch_item as @batch_item" do
        post :create, {:batch_item => invalid_attributes}, valid_session
        expect(assigns(:batch_item)).to be_a_new(BatchItem)
      end

      it "re-renders the 'new' template" do
        post :create, {:batch_item => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested batch_item" do
        batch_item = BatchItem.create! valid_attributes
        put :update, {:id => batch_item.to_param, :batch_item => new_attributes}, valid_session
        batch_item.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested batch_item as @batch_item" do
        batch_item = BatchItem.create! valid_attributes
        put :update, {:id => batch_item.to_param, :batch_item => valid_attributes}, valid_session
        expect(assigns(:batch_item)).to eq(batch_item)
      end

      it "redirects to the batch_item" do
        batch_item = BatchItem.create! valid_attributes
        put :update, {:id => batch_item.to_param, :batch_item => valid_attributes}, valid_session
        expect(response).to redirect_to(batch_item)
      end
    end

    context "with invalid params" do
      it "assigns the batch_item as @batch_item" do
        batch_item = BatchItem.create! valid_attributes
        put :update, {:id => batch_item.to_param, :batch_item => invalid_attributes}, valid_session
        expect(assigns(:batch_item)).to eq(batch_item)
      end

      it "re-renders the 'edit' template" do
        batch_item = BatchItem.create! valid_attributes
        put :update, {:id => batch_item.to_param, :batch_item => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested batch_item" do
      batch_item = BatchItem.create! valid_attributes
      expect {
        delete :destroy, {:id => batch_item.to_param}, valid_session
      }.to change(BatchItem, :count).by(-1)
    end

    it "redirects to the batch_items list" do
      batch_item = BatchItem.create! valid_attributes
      delete :destroy, {:id => batch_item.to_param}, valid_session
      expect(response).to redirect_to(batch_items_url)
    end
  end

end
