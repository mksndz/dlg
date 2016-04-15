Rails.application.routes.draw do

  devise_for :users, path: 'auth', controllers: {
      invitations: 'invitations'
  }

  devise_scope :user do
    get 'auth/invitations', to: 'invitations#index'
  end

  concern :multiple_actionable do
     post 'multiple_action'
  end

  concern :ss_searchable do
    get 'search'
    get 'results'
  end

  resources :repositories, :collections, :users, :roles, :subjects

  resources :items do
    collection do
      concerns :ss_searchable
      concerns :multiple_actionable
    end
    member do
      get 'copy'
    end
  end

  resources :collections do
    collection do
      # get 'for/:repository_id', to: 'collections#index', as: :filtered
    end
  end

  resources :batches do
    collection do
      get 'for/:user_id', to: 'batches#index', as: :filtered
    end
    member do
      get 'commit', to: 'batches#commit', as: :commit
    end
    resources :batch_items do
      collection do
        get 'import/xml',       to: 'batch_items#xml',             as: :xml
        post 'import/process',  to: 'batch_items#create_from_xml', as: :xml_import
      end
      member do
        get 'commit', to: 'batch_items#commit', as: :commit
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
