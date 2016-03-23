require 'rails_helper'

RSpec.describe Meta::ItemsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/meta/items').to route_to('meta/items#index')
    end

    it 'routes to #new' do
      expect(get: '/meta/items/new').to route_to('meta/items#new')
    end

    it 'routes to #show' do
      expect(get: '/meta/items/1').to route_to(controller: 'meta/items', action: 'show', id: '1')
    end

    it 'routes to #copy' do
      expect(get: '/meta/items/1/copy').to route_to(controller: 'meta/items', action: 'copy', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/meta/items/1/edit').to route_to(controller: 'meta/items', action: 'edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/meta/items').to route_to('meta/items#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/meta/items/1').to route_to(controller: 'meta/items', action: 'update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/meta/items/1').to route_to(controller: 'meta/items', action: 'update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/meta/items/1').to route_to(controller: 'meta/items', action: 'destroy', id: '1')
    end

    it 'routes to filtered Items list by Collection' do
      expect(get: '/meta/items/for/1').to route_to(controller: 'meta/items', action: 'index', collection_id: '1')
    end

  end
end
