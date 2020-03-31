Rails.application.routes.draw do
  root 'application#hello'
  namespace :v1, defaults: { format: :json } do
    resources :subscribers, only: %i[create]
    resources :users, only: %i[create show]
    resources :orders, only: %i[create index show]
    resources :products, only: %i[index show]
    resources :addresses, only: %i[index show create update]
    resources :authentication, only: %i[create update]
    resources :carts
    namespace :admin do
      resources :articles
      resources :users, except: %i[new edit]
      resources :orders, except: %i[new edit]
      resources :products
      resources :addresses
      resources :admin_users
      resources :authentication, only: %i[create update]
    end
  end
end
