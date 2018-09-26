require 'rails_helper'

RSpec.describe HoldingInstitutionsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/holding_institutions').to route_to('holding_institutions#index')
    end
    it 'routes to #new' do
      expect(get: '/holding_institutions/new').to route_to('holding_institutions#new')
    end
    it 'routes to #show' do
      expect(get: '/holding_institutions/1').to route_to('holding_institutions#show', id: '1')
    end
    it 'routes to #edit' do
      expect(get: '/holding_institutions/1/edit').to route_to('holding_institutions#edit', id: '1')
    end
    it 'routes to #create' do
      expect(post: '/holding_institutions').to route_to('holding_institutions#create')
    end
    it 'routes to #update via PUT' do
      expect(put: '/holding_institutions/1').to route_to('holding_institutions#update', id: '1')
    end
    it 'routes to #update via PATCH' do
      expect(patch: '/holding_institutions/1').to route_to('holding_institutions#update', id: '1')
    end
    it 'routes to #destroy' do
      expect(delete: '/holding_institutions/1').to route_to('holding_institutions#destroy', id: '1')
    end
  end
end
