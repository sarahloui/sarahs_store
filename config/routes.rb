Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root "offers#home"
  match 'accept_offer', to: 'offers#accept', via: :post
  match 'checkout_path', to: 'orders#create', via: :post
  get 'checkout_success', to: 'offers#checkout_success'
  get "orders/cancel"

  resources :products
  resources :orders

end
