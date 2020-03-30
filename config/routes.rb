Rails.application.routes.draw do
  root 'application#hello'
  namespace :v1, defaults: {format: :json} do
    resources :articles
    resources :users, only: [:create, :show]
    resources :orders, only: [:create, :index, :show]
    resources :products, only: [:index, :show]
    resources :addresses, only: [:index, :show, :create, :update]
    resources :authentication, only: [:create, :update]
    resources :carts
    namespace :admin do
      resources :articles
      resources :users, except: [:new, :edit]
      resources :orders, except: [:new, :edit]
      resources :products
      resources :addresses
      resources :admin_users
      resources :authentication, only: [:create, :update]
    end
  end
end
