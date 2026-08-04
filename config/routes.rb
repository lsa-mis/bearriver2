Rails.application.routes.draw do
  devise_for :admin_users, path: 'admin', path_names: { sign_in: 'login', sign_out: 'logout' },
             controllers: { sessions: 'admin_users/sessions' }

  namespace :admin do
    root to: 'dashboard#show'
    resources :applications do
      member { post :send_offer }
    end
    resources :payments, only: %i[index show new create destroy]
    resources :application_settings, except: %i[new create] do
      collection do
        post :duplicate
        post :run_lottery
      end
    end
    resources :payment_gateway_callbacks, only: %i[index show]
    resources :users
    resources :admin_users
    resources :workshops
    resources :lodgings
    resources :partner_registrations
    resources :genders
    post :send_balance_due, to: 'applications#send_balance_due'
  end

  devise_for :users
  root 'static_pages#index'

  resources :applications

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

  if Rails.env.development? || Rails.env.staging?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
