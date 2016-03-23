require 'rails_helper'

RSpec.describe Meta::BatchesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/meta/batches').to route_to('meta/batches#index')
    end

    it 'routes to #new' do
      expect(get: '/meta/batches/new').to route_to('meta/batches#new')
    end

    it 'routes to #show' do
      expect(get: '/meta/batches/1').to route_to(controller: 'meta/batches', action: 'show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/meta/batches/1/edit').to route_to(controller: 'meta/batches', action: 'edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/meta/batches').to route_to('meta/batches#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/meta/batches/1').to route_to(controller: 'meta/batches', action: 'update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/meta/batches/1').to route_to(controller: 'meta/batches', action: 'update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/meta/batches/1').to route_to(controller: 'meta/batches', action: 'destroy', id: '1')
    end

    it 'routes to filtered Batches list by User' do
      expect(get: '/meta/batches/for/1').to route_to(controller: 'meta/batches', action: 'index', user_id: '1')
    end
  end
end
