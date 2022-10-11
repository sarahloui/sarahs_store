Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root "products#home"
  get "products/home"
  match 'checkout_path', to: 'orders#create', via: :post
  get "orders/new"
  get "orders/show"
  get "orders/cancel"
  get "orders/success"

  resources :products
  resources :orders

end
