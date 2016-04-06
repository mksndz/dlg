require 'rails_helper'

RSpec.describe RolesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(:get => '/meta/roles').to route_to('meta/roles#index')
    end

    it 'routes to #new' do
      expect(:get => '/meta/roles/new').to route_to('meta/roles#new')
    end

    it 'routes to #show' do
      expect(:get => '/meta/roles/1').to route_to('meta/roles#show', :id => '1')
    end

    it 'routes to #edit' do
      expect(:get => '/meta/roles/1/edit').to route_to('meta/roles#edit', :id => '1')
    end

    it 'routes to #create' do
      expect(:post => '/meta/roles').to route_to('meta/roles#create')
    end

    it 'routes to #update via PUT' do
      expect(:put => '/meta/roles/1').to route_to('meta/roles#update', :id => '1')
    end

    it 'routes to #update via PATCH' do
      expect(:patch => '/meta/roles/1').to route_to('meta/roles#update', :id => '1')
    end

    it 'routes to #destroy' do
      expect(:delete => '/meta/roles/1').to route_to('meta/roles#destroy', :id => '1')
    end

  end
end
