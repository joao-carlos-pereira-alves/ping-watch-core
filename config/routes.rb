# frozen_string_literal: true

Rails.application.routes.draw do
  resources :notifications
  devise_for :users

  resources :sites
  resources :dashboard, only: %i[index]
  resources :exports, only: %i[index create destroy]
  resources :orders, only: %i[index show]

  get 'send_extract_xlsx_mailer', to: 'dashboard#send_extract_xlsx_mailer'

  root 'dashboard#index'
end
