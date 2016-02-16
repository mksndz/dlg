require "rails_helper"

RSpec.describe BatchItemsController, type: :routing do
  describe "routing" do

    before(:all){
      @batch = Fabricate(:batch)
      @item = @batch.batch_items.first
    }

    it 'routes to #index' do
      expect(get: "/admin/batches/#{@batch.id}/batch_items").to route_to(controller: 'batch_items', action: 'index', batch_id: @batch.id.to_s)
    end

    it 'routes to #new' do
      expect(get: "/admin/batches/#{@batch.id}/batch_items/new").to route_to(controller: 'batch_items', action: 'new', batch_id: @batch.id.to_s)
    end

    it 'routes to #show' do
      expect(get: "/admin/batches/#{@batch.id}/batch_items/#{@item.id}").to route_to(controller: 'batch_items', action: 'show', batch_id: @batch.id.to_s, id: @item.id.to_s)
    end

    it 'routes to #edit' do
      expect(get: "/admin/batches/#{@batch.id}/batch_items/#{@item.id}/edit").to route_to(controller: 'batch_items', action: 'edit', batch_id: @batch.id.to_s, id: @item.id.to_s)
    end

    it 'routes to #create' do
      expect(post: "/admin/batches/#{@batch.id}/batch_items").to route_to(controller: 'batch_items', action: 'create', batch_id: @batch.id.to_s)
    end

    it 'routes to #update via PUT' do
      expect(put: "/admin/batches/#{@batch.id}/batch_items/#{@item.id}").to route_to(controller: 'batch_items', action: 'update', batch_id: @batch.id.to_s, id: @item.id.to_s)
    end

    it 'routes to #update via PATCH' do
      expect(patch: "/admin/batches/#{@batch.id}/batch_items/#{@item.id}").to route_to(controller: 'batch_items', action: 'update', batch_id: @batch.id.to_s, id: @item.id.to_s)
    end

    it 'routes to #destroy' do
      expect(delete: "/admin/batches/#{@batch.id}/batch_items/#{@item.id}").to route_to(controller: 'batch_items', action: 'destroy', batch_id: @batch.id.to_s, id: @item.id.to_s)
    end

  end
end
