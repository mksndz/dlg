require 'rails_helper'

RSpec.describe ItemsController, type: :routing do
  describe 'routing' do

    it 'routes to #dump' do
      expect(get: '/oai_support/dump').to route_to('oai_support#dump')
    end

    it 'routes to #dump' do
      expect(get: '/oai_support/2016-01-01/dump').to route_to(controller: 'oai_support', action: 'dump', date: '2016-01-01')
    end

    it 'routes to #metadata' do
      expect(get: '/oai_support/metadata?ids=1').to route_to(controller: 'oai_support', action: 'metadata', ids: '1')
    end

    it 'routes to #metadata' do
      expect(get: '/oai_support/metadata?ids=1,2,3').to route_to(controller: 'oai_support', action: 'metadata', ids: '1,2,3')
    end

  end
end
