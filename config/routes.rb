Rails.application.routes.draw do
  resources :likes
  resources :tweets do
    member do
      post :like
      post :retweet
    end
  end
  devise_for :users, controllers: {registrations: 'users/registrations'}
  resources :users
  root 'home#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
