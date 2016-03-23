require 'rails_helper'

RSpec.describe Meta::AdminsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(:get => '/meta/admins').to route_to('meta/admins#index')
    end

    it 'routes to #new' do
      expect(:get => '/meta/admins/new').to route_to('meta/admins#new')
    end

    it 'routes to #show' do
      expect(:get => '/meta/admins/1').to route_to('meta/admins#show', :id => '1')
    end

    it 'routes to #edit' do
      expect(:get => '/meta/admins/1/edit').to route_to('meta/admins#edit', :id => '1')
    end

    it 'routes to #create' do
      expect(:post => '/meta/admins').to route_to('meta/admins#create')
    end

    it 'routes to #update via PUT' do
      expect(:put => '/meta/admins/1').to route_to('meta/admins#update', :id => '1')
    end

    it 'routes to #update via PATCH' do
      expect(:patch => '/meta/admins/1').to route_to('meta/admins#update', :id => '1')
    end

    it 'routes to #destroy' do
      expect(:delete => '/meta/admins/1').to route_to('meta/admins#destroy', :id => '1')
    end

  end
end
