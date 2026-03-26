Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  resources :posts, only: [:index, :create, :destroy] do
    member do
      post :like
      post :reply
    end
  end

  get  "/profile/edit",        to: "profiles#edit",   as: :edit_profile
  patch "/profile",            to: "profiles#update",  as: :update_profile
  get  "/:username",           to: "profiles#show",   as: :profile, constraints: { username: /[a-z0-9_]+/ }

  root "posts#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
