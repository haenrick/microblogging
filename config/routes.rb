Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  get  "/verify-email/:token", to: "email_verifications#show",   as: :verify_email
  post "/verify-email/resend", to: "email_verifications#create", as: :resend_email_verification

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

  post   "/:username/follow",         to: "follows#create",  as: :follow_user
  delete "/:username/follow",         to: "follows#destroy", as: :unfollow_user
  patch  "/:username/follow/accept",  to: "follows#accept",  as: :accept_follow_request
  delete "/:username/follow/accept",  to: "follows#decline", as: :decline_follow_request

  post   "/:username/block",   to: "blocks#create",   as: :block_user
  delete "/:username/block",   to: "blocks#destroy",  as: :unblock_user

  namespace :admin do
    root "dashboard#index"
    resources :users, only: [:index, :destroy] do
      member { patch :toggle_admin }
    end
    resources :posts, only: [:index, :destroy]
    resources :error_logs, only: [:index, :show], param: :fingerprint do
      collection { delete :destroy_all }
      member     { delete :destroy }
    end
  end

  get  "/messages",           to: "messages#index",  as: :messages
  get  "/messages/new",       to: "messages#new_conversation", as: :new_message_conversation
  get  "/messages/:username", to: "messages#show",   as: :message,         constraints: { username: /[a-z0-9_]+/ }
  post "/messages/:username", to: "messages#create",                        constraints: { username: /[a-z0-9_]+/ }

  get    "/profile/edit",            to: "profiles#edit",            as: :edit_profile
  patch  "/profile",                 to: "profiles#update",          as: :update_profile
  patch  "/profile/change_password", to: "profiles#change_password", as: :change_password
  delete "/profile",                 to: "profiles#destroy",         as: :delete_account
  get "/:username/followers", to: "profiles#followers", as: :profile_followers, constraints: { username: /(?!admin)[a-z0-9_]+/ }
  get "/:username/following", to: "profiles#following", as: :profile_following, constraints: { username: /(?!admin)[a-z0-9_]+/ }
  get "/:username", to: "profiles#show", as: :profile, constraints: { username: /(?!admin)[a-z0-9_]+/ }

  post "/ai/suggest", to: "ai#suggest", as: :ai_suggest

  root "posts#index"

  get "up" => "rails/health#show", as: :rails_health_check

  get "/manifest.webmanifest" => "pwa#manifest", as: :pwa_manifest
  get "/service-worker.js"    => "pwa#service_worker", as: :pwa_service_worker
end
