Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root :to => "offers#home"
  match 'accept_offer', to: 'offers#accept', via: :post
  get 'checkout_success', to: 'offers#checkout_success'
  get 'cancel_checkout', to: 'offers#cancel_checkout'

end
