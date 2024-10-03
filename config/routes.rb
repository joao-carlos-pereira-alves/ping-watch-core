# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  
  resources :notifications
  resources :sites
  resources :dashboard, only: %i[index]
  resources :exports, only: %i[index create destroy]
  resources :orders, only: %i[index show]
  resources :plans

  get 'send_extract_xlsx_mailer', to: 'dashboard#send_extract_xlsx_mailer'

  root 'dashboard#index'
end
