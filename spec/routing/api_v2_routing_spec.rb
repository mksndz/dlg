require 'rails_helper'

RSpec.describe Api::V2::ItemsController do
  describe 'routing' do
    it 'routes to #ok' do
      expect(get: 'api/v2/ok.json').to route_to(
        controller: 'api/v2/base',
        action: 'ok',
        format: 'json'
      )
    end
  end
end

RSpec.describe Api::V2::ItemsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: 'api/v2/items.json').to route_to(
        controller: 'api/v2/items',
        action: 'index',
        format: 'json'
      )
    end

    it 'routes to #show' do
      expect(get: 'api/v2/items/r_c_i.json?').to route_to(
        controller: 'api/v2/items',
        action: 'show',
        format: 'json',
        id: 'r_c_i'
      )
    end
  end
end

RSpec.describe Api::V2::CollectionsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: 'api/v2/collections.json').to route_to(
        controller: 'api/v2/collections',
        action: 'index',
        format: 'json'
      )
    end

    it 'routes to #show' do
      expect(get: 'api/v2/collections/r_c_i.json?').to route_to(
        controller: 'api/v2/collections',
        action: 'show',
        format: 'json',
        id: 'r_c_i'
      )
    end
  end
end

RSpec.describe Api::V2::HoldingInstitutionsController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: 'api/v2/holding_institutions.json').to route_to(
        controller: 'api/v2/holding_institutions',
        action: 'index',
        format: 'json'
      )
    end

    it 'routes to #show' do
      expect(get: 'api/v2/holding_institutions/1.json?').to route_to(
        controller: 'api/v2/holding_institutions',
        action: 'show',
        format: 'json',
        id: '1'
      )
    end
  end
end

RSpec.describe Api::V2::FeaturesController do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: 'api/v2/features.json').to route_to(
        controller: 'api/v2/features',
        action: 'index',
        format: 'json'
      )
    end
  end
end
