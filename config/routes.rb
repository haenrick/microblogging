Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  get  "/register", to: "registrations#new",    as: :new_register
  post "/register", to: "registrations#create", as: :register

  resources :posts, only: [:index, :create, :show, :update, :destroy] do
    member do
      post :like
      post :reply
    end
  end

  get "/search",   to: "search#index",   as: :search
  get "/discover", to: "discover#index", as: :discover

  post   "/:username/follow",  to: "follows#create",  as: :follow_user
  delete "/:username/follow",  to: "follows#destroy", as: :unfollow_user

  post   "/:username/block",   to: "blocks#create",   as: :block_user
  delete "/:username/block",   to: "blocks#destroy",  as: :unblock_user

  get    "/profile/edit",            to: "profiles#edit",            as: :edit_profile
  patch  "/profile",                 to: "profiles#update",          as: :update_profile
  patch  "/profile/change_password", to: "profiles#change_password", as: :change_password
  delete "/profile",                 to: "profiles#destroy",         as: :delete_account
  get  "/:username",    to: "profiles#show",   as: :profile, constraints: { username: /[a-z0-9_]+/ }

  namespace :admin do
    root "dashboard#index"
    resources :users, only: [:index, :destroy] do
      member { patch :toggle_admin }
    end
    resources :posts, only: [:index, :destroy]
  end

  root "posts#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
