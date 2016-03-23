require 'rails_helper'

RSpec.describe Meta::RepositoriesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/meta/repositories').to route_to('meta/repositories#index')
    end

    it 'routes to #new' do
      expect(get: '/meta/repositories/new').to route_to('meta/repositories#new')
    end

    it 'routes to #show' do
      expect(get: '/meta/repositories/1').to route_to(controller: 'meta/repositories', action: 'show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/meta/repositories/1/edit').to route_to(controller: 'meta/repositories', action: 'edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/meta/repositories').to route_to('meta/repositories#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/meta/repositories/1').to route_to(controller: 'meta/repositories', action: 'update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/meta/repositories/1').to route_to(controller: 'meta/repositories', action: 'update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/meta/repositories/1').to route_to(controller: 'meta/repositories', action: 'destroy', id: '1')
    end

  end
end
