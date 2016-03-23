require 'rails_helper'

RSpec.describe Meta::CollectionsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/meta/collections').to route_to('meta/collections#index')
    end

    it 'routes to #new' do
      expect(get: '/meta/collections/new').to route_to('meta/collections#new')
    end

    it 'routes to #show' do
      expect(get: '/meta/collections/1').to route_to(controller: 'meta/collections', action: 'show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/meta/collections/1/edit').to route_to(controller: 'meta/collections', action: 'edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/meta/collections').to route_to('meta/collections#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/meta/collections/1').to route_to(controller: 'meta/collections', action: 'update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/meta/collections/1').to route_to(controller: 'meta/collections', action: 'update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/meta/collections/1').to route_to(controller: 'meta/collections', action: 'destroy', id: '1')
    end

    it 'routes to filtered Collections list by Repository' do
      expect(get: '/meta/collections/for/1').to route_to(controller: 'meta/collections', action: 'index', repository_id: '1')
    end

  end
end
