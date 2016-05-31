Rails.application.routes.draw do

  devise_for :users, path: 'auth', controllers: {
    invitations: 'invitations'
  }

  devise_scope :user do
    get 'auth/invitations', to: 'invitations#index'
  end

  # resources :dashboard, only: [:index]

  resources :repositories, :collections, :users, :roles, :subjects, :time_periods

  resources :versions, only: [] do
    member do
      patch :restore
    end
  end

  resources :items do

    resources :versions, only: [:destroy] do
      member do
        get :diff, to: 'versions#diff'
        patch :rollback, to: 'versions#rollback'
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

    resources :batch_items do
      collection do
        post 'import',  to: 'batch_items#import', constraints: { format: :json }
      end
    end

  end

  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  concern :searchable, Blacklight::Routes::Searchable.new
  concern :exportable, Blacklight::Routes::Exportable.new

  resource :catalog, only: [:index], controller: 'catalog' do
    concerns :searchable
  end

  resources :solr_documents, only: [:show], controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  authenticated do
    root to: 'catalog#index', as: :authenticated_root
  end

  root to: redirect('auth/sign_in')

end
