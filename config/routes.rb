Rails.application.routes.draw do

  devise_for :admins

  namespace :meta do

    get 'home', to: 'base#index'

    resources :repositories, :collections, :roles, :users, :subjects

    resources :items do
      collection do
        get 'for/:collection_id', to: 'items#index', as: :filtered
      end
      member do
        get 'copy'
      end
    end

    resources :collections do
      collection do
        get 'for/:repository_id', to: 'collections#index', as: :filtered
      end
    end

    resources :batches do
      collection do
        get 'for/:user_id', to: 'batches#index', as: :filtered
      end
      resources :batch_items do
        collection do
          get 'import/xml',       to: 'batch_items#xml',             as: :xml
          post 'import/process',  to: 'batch_items#create_from_xml', as: :xml_import
        end
      end
    end

  end

  mount Blacklight::Engine => '/'

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

  devise_for :users

  root to: 'catalog#index'

end
