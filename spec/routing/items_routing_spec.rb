require 'rails_helper'

RSpec.describe ItemsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/items').to route_to('items#index')
    end

    it 'routes to #new' do
      expect(get: '/items/new').to route_to('items#new')
    end

    it 'routes to #show' do
      expect(get: '/items/1').to route_to(controller: 'items', action: 'show', id: '1')
    end

    it 'routes to #copy' do
      expect(get: '/items/1/copy').to route_to(controller: 'items', action: 'copy', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/items/1/edit').to route_to(controller: 'items', action: 'edit', id: '1')
    end

    it 'routes to #fulltext' do
      expect(get: '/items/1/fulltext').to route_to(controller: 'items', action: 'fulltext', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/items').to route_to('items#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/items/1').to route_to(controller: 'items', action: 'update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/items/1').to route_to(controller: 'items', action: 'update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/items/1').to route_to(controller: 'items', action: 'destroy', id: '1')
    end

    it 'routes to #multiple_destroy' do
      expect(delete: '/items/multiple_destroy').to route_to('items#multiple_destroy')
    end

    it 'routes to #xml' do
      expect(post: '/items/xml').to route_to('items#xml')
    end

  end
end
