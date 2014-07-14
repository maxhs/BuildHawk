Buildhawk::Application.routes.draw do
  default_url_options :host => "buildhawk.com"
  devise_for :users, :path => '', :controllers => {:registrations => "registrations"}
  root :to => "home#index"

  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new", :as => :login
    get "login", :to => "devise/sessions#new"
    get "registrations/new", :to => "devise/sessions#new"
    get "logout", :to => "devise/sessions#destroy", :as => :logout
    get '/register', :to => "registrations#new"
  end

  post "/projects/:id", :to => "projects#update"
  get "/projects/:id/update_report", :to => "projects#update_report"
  get "/projects/:id/update_worklist_item", :to => "projects#update_worklist_item"
  post "/users/preregister", :to => "users#preregister"
  post "/users/:id", :to => "users#update"
  post "/checklist_items/:id", :to => "checklist_items#update"
  post "/admin/billing", :to => "admin#update_billing"
  get "/task/:id", :to => "worklist_items#edit"
  get 'mobile', :to => "home#mobile_redirect", :as => 'mobile_redirect'

  resources :users do
    collection do 
      post :preregister
    end
    member do
      get :email_unsubscribe
    end
  end
  resources :home, only: [:index], path:"" do 
    collection do
      get :about
      get :privacy
      get :terms
    end
  end
  resources :admin do
    collection do
      get :users
      get :safety_topics
      get :edit_user
      get :new_user
      post :create_user
      get :new_subcontractor
      post :create_subcontractor
      get :reports
      get :checklists
      post :create_blank_template
      post :create_template
      get :new_project
      get :project_groups
      post :create_project
      get :billing
      get :edit_billing
      get :editor
      delete :delete_checklist
    end
    member do
      post :clone_topic
      delete :remove_template
      get :edit_user
      patch :update_billing
      patch :update_user
      patch :update_subcontractor
      patch :update_checklist
      delete :delete_user
    end
  end
  resources :company_subs, only: [:destroy]
  resources :uber_admin do
    collection do
      post :upload_template
      get :companies
      get :users
      get :core_checklists
      get :edit_company
      get :edit_user
      post :update_company
      post :update_user
      delete :destroy_company
      delete :destroy_user
      get :promo_codes
      get :safety_topics
      get :create_blank_template
    end
  end
  resources :promo_codes do
    member do
      get :cancel_editing
    end
  end

  resources :projects do
    member do
      post :archive
      post :unarchive
      get :worklist
      post :search_worklist
      get :checklist
      get :checklist_item
      get :documents
      get :show_photo
      get :document_photos
      get :checklist_photos
      get :worklist_photos
      get :report_photos
      get :destroy_confirmation
    end
    collection do
      post :search
    end
  end
  resources :companies
  resources :comments
  resources :project_groups
  resources :leads, only: [:create, :index]
  resources :messages
  resources :checklists do 
    collection do 
      post :order_phases
      post :order_categories
      post :order_items
    end
    member do
      post :search_items
      get :new_checklist_item
      post :create_checklist_item 
      get :subcategory
      get :load_items
      patch :update_category
      delete :destroy_phase
      delete :destroy_category
    end
  end
  resources :phases
  resources :categories
  resources :safety_topics
  resources :checklist_items do
    member do
      post :export
      get :generate
    end
  end
  resources :worklist_items do
    member do
      get :generate
    end
  end
  resources :photos do
    collection do 
      post :search
    end
    member do
      post :photo
    end
  end
  resources :worklists do
    collection do
      post :export
    end
  end
  resources :reports do
    member do
      get :generate
    end
    collection do
      post :search
    end
  end
  resources :folders
  resources :subs, :only => [:update]
  resources :charges do
    member do 
      patch :promo_code
    end
  end

  get "/api/v2/punchlists", to: "api/v2/worklists#index"
  get "/api/v2/punchlists/:id", to: "api/v2/worklists#show"
  get "/api/v2/punchlist_items/:id", to: "api/v2/worklist_items#show"
  post "/api/v2/punchlist_items", to: "api/v2/worklist_items#create"
  put "/api/v2/punchlist_items/:id", to: "api/v2/worklist_items#update"
  patch "/api/v2/punchlist_items/:id", to: "api/v2/worklist_items#update"
  post "/api/v2/punchlist_items/photo", to: "api/v2/worklist_items#photo"

  #temporary
  get "/api/v2/users/:id/worklist_connect", to: "api/v2/users#connect"
  post "/api/v2/company_subs", to: "api/v2/project_subs#create"
  #

  #mobile API v2
  namespace :api do
    namespace :v2 do
      resources :photos
      resources :sessions, :only => [:create, :forgot_password] do
        collection do 
          post :forgot_password
        end 
      end
      resources :users do
        member do
          get :connect
          post :add_alternate
          post :delete_alternate
        end
      end
      resources :companies do
        collection do
          get :search
          post :add
        end
      end
      resources :groups 
      resources :projects do
        member do
          get :dash
        end
        collection do
          get :dash
          get :archived
          get :groups
          get :demo
        end
        member do
          post :archive
          post :unarchive
          post :add_user
        end
      end
      resources :companies
      resources :checklists
      resources :checklist_items do
        collection do
          post :photo
        end
      end
      resources :worklists, :only => [:show, :index]
      resources :worklist_items do
        collection do
          post :photo
        end
      end
      resources :reminders, :only => [:create, :index, :destroy, :update]
      resources :notifications, :only => [:index, :destroy] do
        collection do 
          get :messages
        end
      end
      resources :comments
      resources :activities, only: [:destroy]
      resources :project_subs, :only => [:create] do
        member do
          post :add_user
        end
      end
      resources :subs, :only => [:create]
      resources :safety_topics, :only => [:destroy]
      resources :reports do
        member do
          get :review_report
        end
        collection do
          post :photo
          get :options
          delete :remove_personnel
        end
      end
    end
  end

  resque_constraint = lambda do |request|
    request.env['warden'].authenticate? and request.env['warden'].user.uber_admin?
  end
  
  constraints resque_constraint do
    mount Resque::Server.new, :at => "/resque"
  end

  unless Rails.application.config.consider_all_requests_local
    get '*not_found', to: 'errors#not_found'
  end
end
