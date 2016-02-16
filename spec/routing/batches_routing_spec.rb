require 'rails_helper'

RSpec.describe BatchesController, type: :routing do
  describe 'routing' do

    before(:all){
      @batch = Fabricate(:batch)
    }

    it 'routes to #index' do
      expect(get: '/admin/batches').to route_to('batches#index')
    end

    it 'routes to #new' do
      expect(get: '/admin/batches/new').to route_to('batches#new')
    end

    it 'routes to #show' do
      expect(get: "/admin/batches/#{@batch.id}").to route_to(controller: 'batches', action: 'show', id: @batch.id.to_s)
    end

    it 'routes to #edit' do
      expect(get: "/admin/batches/#{@batch.id}/edit").to route_to(controller: 'batches', action: 'edit', id: @batch.id.to_s)
    end

    it 'routes to #create' do
      expect(post: '/admin/batches').to route_to('batches#create')
    end

    it 'routes to #update via PUT' do
      expect(put: "/admin/batches/#{@batch.id}").to route_to(controller: 'batches', action: 'update', id: @batch.id.to_s)
    end

    it 'routes to #update via PATCH' do
      expect(patch: "/admin/batches/#{@batch.id}").to route_to(controller: 'batches', action: 'update', id: @batch.id.to_s)
    end

    it 'routes to #destroy' do
      expect(delete: "/admin/batches/#{@batch.id}").to route_to(controller: 'batches', action: 'destroy', id: @batch.id.to_s)
    end
  end
end
