require 'rails_helper'

RSpec.describe ItemsController, type: :controller do

  let(:super_user) {
    Fabricate(:super)
  }
  
  let(:collection) {
    Fabricate(:collection)
  }

  let(:valid_attributes) {
    {
        slug: 'test-item-slug',
        dcterms_title: "Test Item DC Title\nTest Subtitle",
        dc_date: '07-09-1975',
        dcterms_contributor: 'DLG',
        dcterms_spatial: 'Location',
        dcterms_type: 'Text',
        dc_right: 'CC-NA',
        collection_id: collection.id
    }
  }

  let(:invalid_attributes) {
    { slug: 'invalid item slug' }
  }

  before(:each) {
    sign_in super_user
  }

  describe 'GET #index' do
    it 'assigns all items as @items' do
      item = Fabricate(:item)
      get :index
      expect(assigns(:items)).to eq([item])
    end

    it 'assigns items connected to a user to @items' do
      sign_out super_user # todo
      basic_user = Fabricate(:basic)
      sign_in basic_user

      #repo items
      repository1 = Fabricate(:repository)
      collection1 = Fabricate(:collection)
      collection2 = Fabricate(:collection)
      repository2 = Fabricate(:repository)
      item1 = Fabricate(:item)
      item2 = Fabricate(:item)

      repository1.collections << collection1
      collection1.items << item1

      repository2.collections << collection2
      collection2.items << item2

      #collection items
      collection3 = Fabricate(:collection)
      collection4 = Fabricate(:collection)
      item3 = Fabricate(:item)
      item4 = Fabricate(:item)
      collection3.items << item3
      collection4.items << item4

      basic_user.repositories << repository1
      basic_user.collections << collection3

      get :index, {}
      expect(assigns(:items)).to include(item1, item3)
      expect(assigns(:items)).not_to include(item2, item4)
    end

  end

  describe 'GET #show' do
    it 'assigns the requested item as @item' do
      item = Fabricate(:item) 
      get :show, { id: item.id }
      expect(assigns(:item)).to eq(item)
    end
  end

  describe 'GET #new' do
    it 'assigns a new item as @item' do
      get :new
      expect(assigns(:item)).to be_a_new(Item)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested item as @item' do
      item = Fabricate(:item) 
      get :edit, { id: item.id }
      expect(assigns(:item)).to eq(item)
    end
  end

  describe 'GET #copy' do
    it 'assigns the requested item as @item and loads the edit form' do
      item = Fabricate(:item) 
      get :edit, { id: item.id }
      expect(assigns(:item)).to eq(item)
    end
  end

  describe 'POST #create' do

    context 'basic user without Repository or Collection assigned' do
      it 'restricts user from creating an Item' do
        sign_out super_user
        basic_user = Fabricate(:basic)
        sign_in basic_user
        post :create, { item: valid_attributes }
        expect(response).to redirect_to root_url
      end
    end

    context 'basic user with Repository assigned' do
      it 'allows creation of an Item if the user is assigned to the selected Repository' do
        sign_out super_user
        basic_user = Fabricate(:basic)
        sign_in basic_user
        repository = Fabricate(:repository)
        basic_user.repositories << repository
        collection = Fabricate(:collection) { repository repository }
        collection.repository = repository
        valid_attributes[:collection_id] = collection.id
        post :create, { item: valid_attributes }
        expect(response).to redirect_to item_path(assigns(:item))
      end
    end

    context 'basic user with Collection assigned' do
      it 'allows creation of an Item if the user is assigned to the selected Collection' do
        sign_out super_user
        basic_user = Fabricate(:basic)
        sign_in basic_user
        collection = Fabricate(:collection)
        basic_user.collections << collection
        valid_attributes[:collection_id] = collection.id
        post :create, { item: valid_attributes }
        expect(response).to redirect_to item_path(assigns(:item))
      end
    end

    context 'with valid params' do
      it 'creates a new Item' do
        expect {
          post :create, { item: valid_attributes }
        }.to change(Item, :count).by(1)
      end

      it 'assigns a newly created item as @item' do
        post :create, { item: valid_attributes }
        expect(assigns(:item)).to be_a(Item)
        expect(assigns(:item)).to be_persisted
      end

      it 'redirects to the created item' do
        post :create, { item: valid_attributes }
        expect(response).to redirect_to(item_path(Item.last))
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved item as @item' do
        post :create, { item: invalid_attributes }
        expect(assigns(:item)).to be_a_new(Item)
      end

      it 're-renders the "new" template' do
        post :create, { item: invalid_attributes }
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        {
            dcterms_title: "Updated Test DC Title\nNew Subtitle"
        }
      }

      it 'fails if user is not assigned the Item Collection or Item Repository' do
        sign_out super_user
        basic_user = Fabricate(:basic)
        sign_in basic_user
        item = Fabricate(:item) 
        put :update, { id: item.id, item: new_attributes }
        item.reload
        expect(response).to redirect_to root_url
      end

      it 'allows basic user to update a Item if Collection is assigned' do
        sign_out super_user
        basic_user = Fabricate(:basic)
        sign_in basic_user
        collection = Fabricate(:collection)
        basic_user.collections << collection
        item = Fabricate(:item) { collection collection }
        put :update, { id: item.id, item: new_attributes }
        item.reload
        expect(assigns(:item).dcterms_title).to include 'New Subtitle'
      end

      it 'allows basic user to update a Item if parent Repository is assigned' do
        sign_out super_user
        basic_user = Fabricate(:basic)
        sign_in basic_user
        repository = Fabricate(:repository)
        collection = Fabricate(:collection) { repository repository }
        basic_user.repositories << repository
        item = Fabricate(:item) { collection collection}
        put :update, { id: item.id, item: new_attributes }
        item.reload
        expect(assigns(:item).dcterms_title).to include 'New Subtitle'
      end
      
      it 'updates the requested item' do
        item = Fabricate(:item) 
        put :update, { id: item.id, item: new_attributes}
        item.reload
        expect(assigns(:item).dcterms_title).to include 'New Subtitle'
      end

      it 'assigns the requested item as @item' do
        item = Fabricate(:item) 
        put :update, { id: item.id, item: valid_attributes }
        expect(assigns(:item)).to eq(item)
      end

      it 'redirects to the item' do
        item = Fabricate(:item) 
        put :update, { id: item.id, item: valid_attributes }
        expect(response).to redirect_to(item_path(item))
      end
    end

    context 'with invalid params' do
      it 'assigns the item as @item' do
        item = Fabricate(:item) 
        put :update, { id: item.id, item: invalid_attributes }
        expect(assigns(:item)).to eq(item)
      end

      it 're-renders the "edit" template' do
        item = Fabricate(:item) 
        put :update, { id: item.id, item: invalid_attributes }
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested item' do
      item = Fabricate(:item) 
      expect {
        delete :destroy, { id: item.id }
      }.to change(Item, :count).by(-1)
    end

    it 'redirects to the items list' do
      item = Fabricate(:item) 
      delete :destroy, { id: item.id }
      expect(response).to redirect_to(items_url)
    end
  end

  describe 'GET #xml' do
    it 'return xml for the requested items' do
      item = Fabricate(:item)
      item2 = Fabricate(:item)
      get :xml, { entities: "#{item.id},#{item2.id}", format: :xml }
      expect(response.content_type).to eq 'application/xml'
      expect(response.body).to include item.slug
    end
  end

  describe 'DELETE #multiple_destroy' do
    it 'destroy the requested items' do
      item = Fabricate(:item)
      item2 = Fabricate(:item)
      expect {
        delete :multiple_destroy, { entities: "#{item.id},#{item2.id}", format: :json }
      }.to change(Item, :count).by(-2)
    end
  end

end
