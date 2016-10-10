require 'rails_helper'

RSpec.describe BatchImportsController, type: :routing do
  describe 'routing' do

    it 'routes to #show' do
      expect(get: '/batches/1/batch_imports/1').to route_to(controller: 'batch_imports', action: 'show', batch_id: '1', id: '1')
    end

    it 'routes to #index' do
      expect(get: '/batches/1/batch_imports').to route_to(controller: 'batch_imports', action: 'index', batch_id: '1')
    end

    it 'routes to #new' do
      expect(get: '/batches/1/batch_imports/new').to route_to(controller: 'batch_imports', action: 'new', batch_id: '1')
    end

    it 'routes to #create' do
      expect(post: '/batches/1/batch_imports').to route_to(controller: 'batch_imports', action: 'create', batch_id: '1')
    end

  end
end
