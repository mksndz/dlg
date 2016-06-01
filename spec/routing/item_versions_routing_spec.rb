require 'rails_helper'

RSpec.describe ItemVersionsController, type: :routing do
  describe 'item versions' do

    it 'routes to #diff' do
      expect(get: '/items/1/item_versions/1/diff').to route_to(controller: 'item_versions', action: 'diff', item_id: '1', id: '1')
    end

    it 'routes to #rollback' do
      expect(patch: '/items/1/item_versions/1/rollback').to route_to(controller: 'item_versions', action: 'rollback', item_id: '1', id: '1')
    end

  end
end
