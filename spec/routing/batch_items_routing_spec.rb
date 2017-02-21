require 'rails_helper'

RSpec.describe BatchItemsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/batches/1/batch_items').to route_to(controller: 'batch_items', action: 'index', batch_id: '1')
    end

    it 'routes to #new' do
      expect(get: '/batches/1/batch_items/new').to route_to(controller: 'batch_items', action: 'new', batch_id: '1')
    end

    it 'routes to #show' do
      expect(get: '/batches/1/batch_items/1').to route_to(controller: 'batch_items', action: 'show', batch_id: '1', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/batches/1/batch_items/1/edit').to route_to(controller: 'batch_items', action: 'edit', batch_id: '1', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/batches/1/batch_items').to route_to(controller: 'batch_items', action: 'create', batch_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/batches/1/batch_items/1').to route_to(controller: 'batch_items', action: 'update', batch_id: '1', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/batches/1/batch_items/1').to route_to(controller: 'batch_items', action: 'update', batch_id: '1', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/batches/1/batch_items/1').to route_to(controller: 'batch_items', action: 'destroy', batch_id: '1', id: '1')
    end

    it 'routes to #import' do
      expect(post: '/batches/1/batch_items/import').to route_to(controller: 'batch_items', action: 'import', batch_id: '1')
    end

    it 'routes to #bulk_add' do
      expect(post: '/batches/1/batch_items/bulk_add').to route_to(controller: 'batch_items', action: 'bulk_add', batch_id: '1')
    end

  end
end
