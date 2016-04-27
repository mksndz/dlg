require 'rails_helper'

RSpec.describe BatchesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/batches').to route_to('batches#index')
    end

    it 'routes to #new' do
      expect(get: '/batches/new').to route_to('batches#new')
    end

    it 'routes to #show' do
      expect(get: '/batches/1').to route_to(controller: 'batches', action: 'show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/batches/1/edit').to route_to(controller: 'batches', action: 'edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/batches').to route_to('batches#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/batches/1').to route_to(controller: 'batches', action: 'update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/batches/1').to route_to(controller: 'batches', action: 'update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/batches/1').to route_to(controller: 'batches', action: 'destroy', id: '1')
    end

    it 'routes to #commit' do
      expect(get: '/batches/1/commit').to route_to(controller: 'batches', action: 'commit', id: '1')
    end

    it 'routes to filtered Batches list by User' do
      expect(get: '/batches/for/1').to route_to(controller: 'batches', action: 'index', user_id: '1')
    end

    it 'routes to #committed' do
      expect(get: '/batches/committed').to route_to('batches#committed')
    end

    it 'routes to #xml' do
      expect(get: '/batches/1/import_items').to route_to(controller: 'batches', action: 'xml', id: '1')
    end

    it 'routes to #commit' do
      expect(get: '/batches/1/commit').to route_to(controller: 'batches', action: 'commit', id: '1')
    end

    it 'routes to #results' do
      expect(get: '/batches/1/results').to route_to(controller: 'batches', action: 'results', id: '1')
    end
  end
end
