require 'rails_helper'

RSpec.describe RepositoriesController, type: :routing do
  describe 'routing' do

    before(:all){
      @repository = Fabricate(:repository)
    }

    it 'routes to #index' do
      expect(get: '/admin/repositories').to route_to('repositories#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/repositories/new').to route_to('repositories#new')
    end

    it 'routes to #show' do
      expect(get: "/admin/repositories/#{@repository.id}").to route_to(controller: 'repositories', action: 'show', id: @repository.id.to_s)
    end

    it 'routes to #edit' do
      expect(get: "/admin/repositories/#{@repository.id}/edit").to route_to(controller: 'repositories', action: 'edit', id: @repository.id.to_s)
    end

    it 'routes to #create' do
      expect(post: '/admin/repositories').to route_to('repositories#create')
    end

    it 'routes to #update via PUT' do
      expect(put: "/admin/repositories/#{@repository.id}").to route_to(controller: 'repositories', action: 'update', id: @repository.id.to_s)
    end

    it 'routes to #update via PATCH' do
      expect(patch: "/admin/repositories/#{@repository.id}").to route_to(controller: 'repositories', action: 'update', id: @repository.id.to_s)
    end

    it 'routes to #destroy' do
      expect(delete: "/admin/repositories/#{@repository.id}").to route_to(controller: 'repositories', action: 'destroy', id: @repository.id.to_s)
    end

  end
end
