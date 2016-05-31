require 'rails_helper'

RSpec.describe VersionsController, type: :routing do
  describe 'versions' do

    it 'routes to #diff' do
      expect(get: '/items/1/versions/1/diff').to route_to(controller: 'versions', action: 'diff', item_id: '1', id: '1')
    end

    it 'routes to #rollback' do
      expect(patch: '/items/1/versions/1/rollback').to route_to(controller: 'versions', action: 'rollback', item_id: '1', id: '1')
    end

    # it 'routes to #destroy' do
    #   expect(delete: '/items/1/versions/1').to route_to(controller: 'versions', action: 'destroy', item_id: '1', id: '1')
    # end

  end
end
