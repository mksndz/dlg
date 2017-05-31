require 'resque/server'

Rails.application.routes.draw do

  constraints(format: :json) do
    get 'oai_support/dump',           to: 'oai_support#dump',     as: 'oai_support_dump'
    get 'oai_support/deleted',        to: 'oai_support#deleted',  as: 'oai_support_deleted'
    get 'oai_support/metadata',       to: 'oai_support#metadata', as: 'oai_support_metadata'
  end

  concern :searchable, Blacklight::Routes::Searchable.new
  concern :exportable, Blacklight::Routes::Exportable.new

  devise_for :users, path: 'auth', controllers: {
    invitations: 'invitations'
  }

  devise_scope :user do
    get 'auth/invitations', to: 'invitations#index'
  end

  resource :profile, only: [:show, :edit], controller: 'profile' do
    collection do
      patch 'update', as: 'update'
    end
  end

  resources :repositories, :collections, :users, :roles, :subjects, :time_periods

  resources :item_versions, only: [] do
    member do
      patch :restore
    end
  end

  resources :items do

    resources :item_versions, only: [] do
      member do
        get :diff, to: 'item_versions#diff'
        patch :rollback, to: 'item_versions#rollback'
      end
    end

    collection do
      delete 'multiple_destroy', constraints: { format: :json }
      get 'xml', constraints: { format: :xml }
      get 'deleted'
    end

    member do
      get 'copy'
    end

  end

  resources :collections

  resources :batches do
    member do
      post 'recreate', to: 'batches#recreate'
      post 'commit', to: 'batches#commit'
      get 'commit_form', to: 'batches#commit_form'
      get 'import', to: 'batches#import'
      get 'results', to: 'batches#results'
    end
    collection do
      get 'select', to: 'batches#select'
    end

    resources :batch_items do
      collection do
        post 'import', to: 'batch_items#import', constraints: { format: :json }
      end
    end

    resources :batch_imports, except: [:edit, :update] do
      collection do
        get 'help'
      end
      member do
        get 'xml'
      end
    end

  end

  resource :catalog, only: [:index], controller: 'catalog', constraints: { id: /.*/, format: false } do
    concerns :searchable
    collection do
      get 'facets', to: 'catalog#facets'
    end
    get 'facet_values/:facet_field', to: 'catalog#all_facet_values', as: 'facet_values_csv', constraints: { format: :csv }
  end

  resources :solr_documents, only: [:show], path: '/record', controller: 'catalog', constraints: { id: /.*/, format: false } do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  # Resque Admin
  resque_constraint = lambda do |request|
    request.env['warden'].authenticate!( { scope: :user } )
  end
  constraints resque_constraint do
    mount Resque::Server.new => '/resque'
  end

  # Base Paths
  authenticated do
    root to: 'advanced#index', as: :authenticated_root
  end

  root to: redirect('auth/sign_in')

end
