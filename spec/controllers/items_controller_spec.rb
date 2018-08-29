require 'rails_helper'

RSpec.describe ItemsController, type: :controller do
  let(:valid_attributes) do
    {
      slug: 'test-item-slug',
      dcterms_title: "Test Item DC Title\nTest Subtitle",
      dc_date: '07-09-1975',
      dcterms_contributor: 'DLG',
      dcterms_spatial: 'Location',
      dcterms_type: ['Text'],
      dc_right: I18n.t('meta.rights.zero.uri'),
      edm_is_shown_at: 'http://dlg.galileo.usg.edu',
      edm_is_shown_by: 'http://dlg.galileo.usg.edu',
      dcterms_subject: 'Georgia',
      collection_id: Fabricate(:empty_collection).id,
      portal_ids: [Portal.last.id],
      holding_institution_ids: HoldingInstitution.last.id
    }
  end
  let(:invalid_attributes) { { slug: 'invalid item slug' } }
  context 'for super users' do
    let(:item) { Fabricate(:repository).items.last }
    let(:super_user) { Fabricate(:super) }
    before(:each) { sign_in super_user }
    describe 'GET #index' do
      it 'assigns all items as @items' do
        get :index
        expect(assigns(:items)).to eq [item]
      end
    end
    describe 'GET #show' do
      it 'assigns the requested item as @item' do
        get :show, id: item.id
        expect(assigns(:item)).to eq item
      end
    end
    describe 'GET #new' do
      it 'assigns a new item as @item' do
        get :new
        expect(assigns(:item)).to be_a_new Item
      end
    end
    describe 'GET #edit' do
      it 'assigns the requested item as @item' do
        get :edit, id: item.id
        expect(assigns(:item)).to eq item
      end
    end
    describe 'GET #copy' do
      it 'assigns the requested item as @item and loads the edit form' do
        get :edit, id: item.id
        expect(assigns(:item)).to eq item
      end
    end
    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new Item' do
          expect do
            post :create, item: valid_attributes
          end.to change(Item, :count).by 1
        end
        it 'assigns a newly created item as @item' do
          post :create, item: valid_attributes
          expect(assigns(:item)).to be_a Item
          expect(assigns(:item)).to be_persisted
        end
        it 'redirects to the created item' do
          post :create, item: valid_attributes
          expect(response).to redirect_to item_path Item.last
        end
      end
      context 'with invalid params' do
        it 'assigns a newly created but unsaved item as @item' do
          post :create, item: invalid_attributes
          expect(assigns(:item)).to be_a_new Item
        end
        it 're-renders the "new" template' do
          post :create, item: invalid_attributes
          expect(response).to render_template 'new'
        end
      end
    end
    describe 'PUT #update' do
      context 'with valid params' do
        let(:new_attributes) do
          { dcterms_title: "Updated Test DC Title\nNew Subtitle" }
        end
        it 'updates the requested item' do
          put :update, id: item.id, item: new_attributes
          item.reload
          expect(assigns(:item).dcterms_title).to include 'New Subtitle'
        end
        it 'assigns the requested item as @item' do
          put :update, id: item.id, item: valid_attributes
          expect(assigns(:item)).to eq item
        end
        it 'redirects to the item' do
          put :update, id: item.id, item: valid_attributes
          expect(response).to redirect_to item_path item
        end
      end
      context 'with invalid params' do
        it 'assigns the item as @item' do
          put :update, id: item.id, item: invalid_attributes
          expect(assigns(:item)).to eq item
        end
        it 're-renders the "edit" template' do
          put :update, id: item.id, item: invalid_attributes
          expect(response).to render_template 'edit'
        end
      end
    end
    describe 'DELETE #destroy' do
      before(:each) { Fabricate :repository }
      it 'destroys the requested item' do
        expect do
          delete :destroy, id: Item.last.id
        end.to change(Item, :count).by(-1)
      end
      it 'redirects to the items list' do
        delete :destroy, id: Item.last.id
        expect(response).to redirect_to items_url
      end
    end
    describe 'GET #xml' do
      it 'return xml for the requested items' do
        item = Fabricate(:repository).items.first
        item2 = Fabricate(:repository).items.first
        get :xml, entities: "#{item.id},#{item2.id}", format: :xml
        expect(response.content_type).to eq 'application/xml'
        expect(response.body).to include item.slug
      end
    end
    describe 'DELETE #multiple_destroy' do
      it 'destroy the requested items' do
        item = Fabricate(:repository).items.first
        item2 = Fabricate(:repository).items.first
        expect do
          delete(
            :multiple_destroy,
            entities: "#{item.id},#{item2.id}",
            format: :json
          )
        end.to change(Item, :count).by(-2)
      end
    end
  end
end
