require 'rails_helper'

RSpec.describe Meta::RepositoriesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/admin/repositories').to route_to('meta/repositories#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/repositories/new').to route_to('meta/repositories#new')
    end

    it 'routes to #show' do
      expect(get: '/admin/repositories/1').to route_to(controller: 'meta/repositories', action: 'show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/admin/repositories/1/edit').to route_to(controller: 'meta/repositories', action: 'edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/admin/repositories').to route_to('meta/repositories#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/admin/repositories/1').to route_to(controller: 'meta/repositories', action: 'update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/admin/repositories/1').to route_to(controller: 'meta/repositories', action: 'update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/admin/repositories/1').to route_to(controller: 'meta/repositories', action: 'destroy', id: '1')
    end

  end
end
