require 'rails_helper'

RSpec.describe CollectionsController, type: :routing do
  describe 'routing' do

    before(:all){
      @collection = Fabricate(:collection)
    }

    it 'routes to #index' do
      expect(get: '/admin/collections').to route_to('collections#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/collections/new').to route_to('collections#new')
    end

    it 'routes to #show' do
      expect(get: "/admin/collections/#{@collection.id}").to route_to(controller: 'collections', action: 'show', id: @collection.id.to_s)
    end

    it 'routes to #edit' do
      expect(get: "/admin/collections/#{@collection.id}/edit").to route_to(controller: 'collections', action: 'edit', id: @collection.id.to_s)
    end

    it 'routes to #create' do
      expect(post: '/admin/collections').to route_to('collections#create')
    end

    it 'routes to #update via PUT' do
      expect(put: "/admin/collections/#{@collection.id}").to route_to(controller: 'collections', action: 'update', id: @collection.id.to_s)
    end

    it 'routes to #update via PATCH' do
      expect(patch: "/admin/collections/#{@collection.id}").to route_to(controller: 'collections', action: 'update', id: @collection.id.to_s)
    end

    it 'routes to #destroy' do
      expect(delete: "/admin/collections/#{@collection.id}").to route_to(controller: 'collections', action: 'destroy', id: @collection.id.to_s)
    end

  end
end
