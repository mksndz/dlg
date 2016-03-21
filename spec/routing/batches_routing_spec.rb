require 'rails_helper'

RSpec.describe Admin::BatchesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/admin/batches').to route_to('admin/batches#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/batches/new').to route_to('admin/batches#new')
    end

    it 'routes to #show' do
      expect(get: '/admin/batches/1').to route_to(controller: 'admin/batches', action: 'show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/admin/batches/1/edit').to route_to(controller: 'admin/batches', action: 'edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/admin/batches').to route_to('admin/batches#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin/batches/1').to route_to(controller: 'admin/batches', action: 'update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin/batches/1').to route_to(controller: 'admin/batches', action: 'update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/batches/1').to route_to(controller: 'admin/batches', action: 'destroy', id: '1')
    end

    it 'routes to filtered Batches list by User' do
      expect(get: '/admin/batches/for/1').to route_to(controller: 'admin/batches', action: 'index', user_id: '1')
    end
  end
end
