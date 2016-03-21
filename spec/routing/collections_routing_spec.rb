require 'rails_helper'

RSpec.describe Admin::CollectionsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/admin/collections').to route_to('admin/collections#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/collections/new').to route_to('admin/collections#new')
    end

    it 'routes to #show' do
      expect(get: '/admin/collections/1').to route_to(controller: 'admin/collections', action: 'show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/admin/collections/1/edit').to route_to(controller: 'admin/collections', action: 'edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/admin/collections').to route_to('admin/collections#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin/collections/1').to route_to(controller: 'admin/collections', action: 'update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin/collections/1').to route_to(controller: 'admin/collections', action: 'update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/collections/1').to route_to(controller: 'admin/collections', action: 'destroy', id: '1')
    end

    it 'routes to filtered Collections list by Repository' do
      expect(get: '/admin/collections/for/1').to route_to(controller: 'admin/collections', action: 'index', repository_id: '1')
    end

  end
end
