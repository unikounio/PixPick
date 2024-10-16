# frozen_string_literal: true

Rails.application.routes.draw do
  get 'entries/new'
  root 'home#index'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  resources :contests, except: :index do
    resources :entries, except: %i[index edit]
  end

  get 'users/:user_id/contests', to: 'contests#index', as: :user_contests

  get 'photos/index', to: 'photos#index'

  get 'up' => 'rails/health#show', as: :rails_health_check
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest
end
