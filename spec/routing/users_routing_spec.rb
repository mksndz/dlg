require 'rails_helper'

RSpec.describe Meta::UsersController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(:get => '/admin/users').to route_to('meta/users#index')
    end

    it 'routes to #new' do
      expect(:get => '/admin/users/new').to route_to('meta/users#new')
    end

    it 'routes to #show' do
      expect(:get => '/admin/users/1').to route_to('meta/users#show', :id => '1')
    end

    it 'routes to #edit' do
      expect(:get => '/admin/users/1/edit').to route_to('meta/users#edit', :id => '1')
    end

    it 'routes to #create' do
      expect(:post => '/admin/users').to route_to('meta/users#create')
    end

    it 'routes to #update via PUT' do
      expect(:put => '/admin/users/1').to route_to('meta/users#update', :id => '1')
    end

    it 'routes to #update via PATCH' do
      expect(:patch => '/admin/users/1').to route_to('meta/users#update', :id => '1')
    end

    it 'routes to #destroy' do
      expect(:delete => '/admin/users/1').to route_to('meta/users#destroy', :id => '1')
    end

  end
end
