# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#top'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  resources :contests, except: :index do
    member do
      get 'ranking'
      get 'invite'
      get :upload_status, to: 'entries#status'
    end

    resources :entries, except: %i[index edit] do
      get 'photo', to: 'entries#image_proxy', on: :member
      get 'thumbnail', to: 'entries#thumbnail_proxy', on: :member
      resources :votes, only: :create
    end

    resources :participants, only: %i[new create destroy]
  end

  resources :users, only: :destroy

  get 'users/:user_id/contests', to: 'contests#index', as: :user_contests
  get 'terms', to: 'home#terms'
  get 'privacy', to: 'home#privacy'

  get 'up' => 'rails/health#show', as: :rails_health_check
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest
end
