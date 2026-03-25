Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  resources :posts, only: [:index, :create, :destroy] do
    member do
      post :like
      post :reply
    end
  end

  root "posts#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
