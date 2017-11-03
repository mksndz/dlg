require 'rails_helper'

RSpec.describe ItemVersionsController, type: :controller do
  before(:each) { sign_in Fabricate(:super) }
  let(:item) { Fabricate(:repository).items.first }
  describe 'GET #diff' do
    with_versioning do
      it 'renders the diff template' do
        item.update(slug: 'changed-slug')
        v1 = item.versions.last
        get :diff, item_id: item.id, id: v1.id
        expect(response).to render_template 'diff'
      end
    end
  end
  describe 'PATCH #rollback' do
    with_versioning do
      it 'rolls back to the designated version of item' do
        item.update slug: 'changed-slug'
        v1 = item.versions.last
        patch :rollback, item_id: item.id, id: v1.id
        expect(assigns(:item)).to eq v1.reify
        expect(response).to redirect_to item_path item
      end
    end
  end
  describe 'PATCH #restore' do
    with_versioning do
      it 'restores the deleted item from the ItemVersion' do
        id = item.id
        item.destroy
        v1 = ItemVersion.where(item_id: id).first
        patch :restore, id: v1.id
        expect(assigns(:item).id).to eq id
        expect(response).to redirect_to item_path item
      end
    end
  end
end
