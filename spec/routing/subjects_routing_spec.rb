require 'rails_helper'

RSpec.describe Meta::SubjectsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(:get => '/meta/subjects').to route_to('meta/subjects#index')
    end

    it 'routes to #new' do
      expect(:get => '/meta/subjects/new').to route_to('meta/subjects#new')
    end

    it 'routes to #show' do
      expect(:get => '/meta/subjects/1').to route_to('meta/subjects#show', :id => '1')
    end

    it 'routes to #edit' do
      expect(:get => '/meta/subjects/1/edit').to route_to('meta/subjects#edit', :id => '1')
    end

    it 'routes to #create' do
      expect(:post => '/meta/subjects').to route_to('meta/subjects#create')
    end

    it 'routes to #update via PUT' do
      expect(:put => '/meta/subjects/1').to route_to('meta/subjects#update', :id => '1')
    end

    it 'routes to #update via PATCH' do
      expect(:patch => '/meta/subjects/1').to route_to('meta/subjects#update', :id => '1')
    end

    it 'routes to #destroy' do
      expect(:delete => '/meta/subjects/1').to route_to('meta/subjects#destroy', :id => '1')
    end

  end
end
