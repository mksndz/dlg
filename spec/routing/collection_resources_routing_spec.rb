require 'rails_helper'

RSpec.describe CollectionResourcesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/collections/1/collection_resources')
        .to route_to(controller: 'collection_resources',
                     action: 'index',
                     collection_id: '1')
    end

    it 'routes to #new' do
      expect(get: '/collections/1/collection_resources/new')
        .to route_to(controller: 'collection_resources',
                     action: 'new',
                     collection_id: '1')
    end

    it 'routes to #show' do
      expect(get: '/collections/1/collection_resources/1')
        .to route_to(controller: 'collection_resources',
                     action: 'show', collection_id: '1',
                     id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/collections/1/collection_resources/1/edit')
        .to route_to(controller: 'collection_resources',
                     action: 'edit', collection_id: '1',
                     id: '1')
    end

    it 'routes to #create' do
      expect(post: '/collections/1/collection_resources')
        .to route_to(controller: 'collection_resources',
                     action: 'create',
                     collection_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/collections/1/collection_resources/1')
        .to route_to(controller: 'collection_resources',
                     action: 'update', collection_id: '1',
                     id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/collections/1/collection_resources/1')
        .to route_to(controller: 'collection_resources',
                     action: 'update', collection_id: '1',
                     id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/collections/1/collection_resources/1')
        .to route_to(controller: 'collection_resources',
                     action: 'destroy',
                     collection_id: '1',
                     id: '1')
    end

  end
end
