Rails.application.routes.draw do
  resources :genders
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  devise_for :users
  root 'static_pages#index'

  # resources :payments
  resources :applications
  resources :lodgings
  resources :workshops

  resources :application_settings

  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/privacy', to: 'static_pages#privacy'
  get '/terms_of_service', to: 'static_pages#terms_of_use'
  get '/conference_closed', to: 'static_pages#conference_closed'
  get '/conference_full', to: 'static_pages#conference_full'
  get '/accept_offer', to: 'static_pages#accept_offer'
  get '/subscription', to: 'applications#subscription'
  get '/special_scholarship', to: 'static_pages#special_scholarship'

  get 'payments', to: 'payments#index'
  get 'payment_receipt', to: 'payments#payment_receipt'
  post 'payment_receipt', to: 'payments#payment_receipt' # needed to address PCI gateway rqrmts
  get 'payment_show', to: 'payments#payment_show', as: 'all_payments'
  get 'make_payment', to: 'payments#make_payment'
  post 'make_payment', to: 'payments#make_payment'

  post 'delete_manual_payment/:id', to: 'payments#delete_manual_payment', as: :delete_manual_payment

  post 'run_lotto', to: 'application_settings#run_lottery'

  post 'duplicate_conference', to: 'application_settings#duplicate_conference_settings'

  post '/send_offer/:id', to: 'application_settings#send_offer', as: 'send_offer'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Send email to applicants who a balance due
  post '/send_balance_due', to: 'applications#send_balance_due', as: 'send_balance_due'

  if Rails.env.development? || Rails.env.staging?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end

