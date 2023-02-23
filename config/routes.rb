Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root :to => "offers#home"
  post 'accept_offer', to: 'offers#accept'
  get 'checkout_success', to: 'offers#checkout_success'
  get 'cancel_checkout', to: 'offers#cancel_checkout'

end
