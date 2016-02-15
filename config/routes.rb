Rails.application.routes.draw do

  get 'admin/index'

  resources :admin, only: :index

  scope 'admin' do

    resources :repositories, :collections, :items
    resources :batches do
      resources :batch_items
    end

    get 'batches/for/:user_id', to: 'batches#index', as: :batches_for
    get 'items/for/:collection_id', to: 'items#index', as: :items_for
    get 'collections/for/:repository_id', to: 'collections#index', as: :collections_for

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
