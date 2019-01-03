require 'rails_helper'

RSpec.describe PagesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/items/1/pages').to route_to(
        controller: 'pages',
        action: 'index',
        item_id: '1'
      )
    end
    it 'routes to #new' do
      expect(get: '/items/1/pages/new').to route_to(
        controller: 'pages',
        action: 'new',
        item_id: '1'
      )
    end
    it 'routes to #show' do
      expect(get: '/items/1/pages/1').to route_to(
        controller: 'pages',
        action: 'show',
        item_id: '1',
        id: '1'
      )
    end
    it 'routes to #edit' do
      expect(get: '/items/1/pages/1/edit').to route_to(
        controller: 'pages',
        action: 'edit',
        item_id: '1',
        id: '1'
      )
    end
    it 'routes to #create' do
      expect(post: '/items/1/pages').to route_to(
        controller: 'pages',
        action: 'create',
        item_id: '1'
      )
    end
    it 'routes to #update via PUT' do
      expect(put: '/items/1/pages/1').to route_to(
        controller: 'pages',
        action: 'update',
        item_id: '1',
        id: '1'
      )
    end
    it 'routes to #update via PATCH' do
      expect(patch: '/items/1/pages/1').to route_to(
        controller: 'pages',
        action: 'update',
        item_id: '1',
        id: '1'
      )
    end
    it 'routes to #iiif' do
      expect(get: 'items/1/pages/1/iiif').to route_to(
        controller: 'pages',
        action: 'iiif',
        item_id: '1',
        id: '1'
      )
    end
  end
end
