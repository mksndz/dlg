require 'rails_helper'

RSpec.describe UsersController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(:get => '/meta/users').to route_to('meta/users#index')
    end

    it 'routes to #destroy' do
      expect(:delete => '/meta/users/1').to route_to('meta/users#destroy', :id => '1')
    end

  end
end
