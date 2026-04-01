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

  resources :notifications, only: [:index] do
    collection { delete :destroy_all }
  end

  resources :push_subscriptions, only: [:create, :destroy]

  post   "/:username/follow",  to: "follows#create",  as: :follow_user
  delete "/:username/follow",  to: "follows#destroy", as: :unfollow_user

  post   "/:username/block",   to: "blocks#create",   as: :block_user
  delete "/:username/block",   to: "blocks#destroy",  as: :unblock_user

  namespace :admin do
    root "dashboard#index"
    resources :users, only: [:index, :destroy] do
      member { patch :toggle_admin }
    end
    resources :posts, only: [:index, :destroy]
  end

  get    "/profile/edit",            to: "profiles#edit",            as: :edit_profile
  patch  "/profile",                 to: "profiles#update",          as: :update_profile
  patch  "/profile/change_password", to: "profiles#change_password", as: :change_password
  delete "/profile",                 to: "profiles#destroy",         as: :delete_account
  get "/:username/followers", to: "profiles#followers", as: :profile_followers, constraints: { username: /(?!admin)[a-z0-9_]+/ }
  get "/:username/following", to: "profiles#following", as: :profile_following, constraints: { username: /(?!admin)[a-z0-9_]+/ }
  get "/:username", to: "profiles#show", as: :profile, constraints: { username: /(?!admin)[a-z0-9_]+/ }

  root "posts#index"

  get "up" => "rails/health#show", as: :rails_health_check

  get "/manifest.webmanifest" => "pwa#manifest", as: :pwa_manifest
  get "/service-worker.js"    => "pwa#service_worker", as: :pwa_service_worker
end
