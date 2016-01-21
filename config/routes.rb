Rails.application.routes.draw do

  scope :admin do
    resources :repositories, :collections, :items
  end

  blacklight_for :catalog
  devise_for :users

  root to: 'catalog#index'

end
