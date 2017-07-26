require 'rails_helper'

RSpec.describe ItemVersionsController, type: :controller do

  before(:each) {
    sign_in Fabricate(:super)
  }

  describe 'GET #diff' do

    with_versioning do

      it 'renders the diff template' do
        i1 = Fabricate(:item)
        i1.update(slug: 'changed-slug')
        v1 = i1.versions.last
        get :diff, { item_id: i1.id, id: v1.id }
        expect(response).to render_template('diff')
      end

    end

  end

  describe 'PATCH #rollback' do

    with_versioning do

      it 'rolls back to the designated version of item' do
        i1 = Fabricate(:item)
        i1.update(slug: 'changed-slug')
        v1 = i1.versions.last
        patch :rollback, { item_id: i1.id, id: v1.id }
        expect(assigns(:item)).to eq v1.reify
        expect(response).to redirect_to item_path(i1)
      end

    end

  end

  describe 'PATCH #restore' do

    with_versioning do

      it 'restores the deleted item from the ItemVersion' do
        i1 = Fabricate(:item)
        id = i1.id
        i1.destroy
        v1 = ItemVersion.where(item_id: id).first
        patch :restore, { id: v1.id }
        expect(assigns(:item).id).to eq id
        expect(response).to redirect_to item_path(i1)
      end

    end

  end

end
