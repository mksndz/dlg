require 'rails_helper'

RSpec.describe FulltextIngestsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/fulltext_ingests').to route_to('fulltext_ingests#index')
    end
    it 'routes to #new' do
      expect(get: '/fulltext_ingests/new').to route_to('fulltext_ingests#new')
    end
    it 'routes to #show' do
      expect(get: '/fulltext_ingests/1').to route_to('fulltext_ingests#show', id: '1')
    end
    it 'routes to #create' do
      expect(post: '/fulltext_ingests').to route_to('fulltext_ingests#create')
    end
    it 'routes to #destroy' do
      expect(delete: '/fulltext_ingests/1').to route_to('fulltext_ingests#destroy', id: '1')
    end
  end
end
