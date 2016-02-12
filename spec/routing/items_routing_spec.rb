require 'rails_helper'

RSpec.describe ItemsController, type: :routing do
  describe 'routing' do

    before(:all){
      @item = Fabricate(:item)
    }

    it 'routes to #index' do
      expect(get: '/admin/items').to route_to('items#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/items/new').to route_to('items#new')
    end

    it 'routes to #show' do
      expect(get: "/admin/items/#{@item.id}").to route_to(controller: 'items', action: 'show', id: @item.id.to_s)
    end

    it 'routes to #edit' do
      expect(get: "/admin/items/#{@item.id}/edit").to route_to(controller: 'items', action: 'edit', id: @item.id.to_s)
    end

    it 'routes to #create' do
      expect(post: '/admin/items').to route_to('items#create')
    end

    it 'routes to #update via PUT' do
      expect(put: "/admin/items/#{@item.id}").to route_to(controller: 'items', action: 'update', id: @item.id.to_s)
    end

    it 'routes to #update via PATCH' do
      expect(patch: "/admin/items/#{@item.id}").to route_to(controller: 'items', action: 'update', id: @item.id.to_s)
    end

    it 'routes to #destroy' do
      expect(delete: "/admin/items/#{@item.id}").to route_to(controller: 'items', action: 'destroy', id: @item.id.to_s)
    end

  end
end
