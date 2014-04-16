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

  get 'about', :to => "home#about", :as => :about
  post "/projects/search", :to => "projects#search"
  post "/projects/:id", :to => "projects#update"
  get "/projects/:id/update_report", :to => "projects#update_report"
  post "/reports/:id", :to => "reports#create"
  get "/projects/:id/update_worklist_item", :to => "projects#update_worklist_item"
  post "/users/:id", :to => "users#update"
  post "/checklist_items/:id", :to => "checklist_items#update"
  post "/admin/billing", :to => "admin#update_billing"

  resources :users
  resources :home do 
    collection do
      get :about
    end
  end
  resources :admin do
    collection do
      get :users
      get :safety_topics
      get :edit_user
      get :edit_sub
      get :new_user
      post :create_user
      get :new_sub
      post :create_sub
      get :reports
      get :checklists
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
      patch :update_sub
      patch :update_checklist
      delete :delete_user
      delete :delete_sub
    end
  end
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
      post :export_checklist
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
  resources :checklists do 
    collection do 
      post :order_categories
      post :order_subcategories
      post :order_items
    end
    member do
      post :search_items
      get :new_checklist_item
      post :create_checklist_item 
      get :subcategory
      get :load_items
      patch :update_subcategory
      delete :destroy_category
      delete :destroy_subcategory
    end
  end
  resources :categories
  resources :subcategories
  resources :safety_topics
  resources :checklist_items do
    member do
      get :generate
    end
  end
  resources :punchlist_items do
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
  resources :punchlists do
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

  #mobile API v1
  namespace :api do
    namespace :v1 do
      resources :photos
      resources :sessions, :only => [:create, :forgot_password] do
        collection do 
          post :forgot_password
        end 
      end
      resources :companies 
      resources :projects do
        collection do
          get :dash
        end
      end
      resources :checklists
      resources :checklist_items do
        collection do
          post :photo
        end
      end
      resources :punchlists, :only => [:show]
      resources :punchlist_items do
        collection do
          post :photo
        end
      end
      resources :comments
      resources :reports do
        member do
          get :review_report
        end
        collection do
          post :photo
          delete :remove_personnel
        end
      end
    end
  end

  #mobile API v2
  namespace :api do
    namespace :v2 do
      resources :photos
      resources :sessions, :only => [:create, :forgot_password] do
        collection do 
          post :forgot_password
        end 
      end
      resources :companies 
      resources :projects do
        collection do
          get :dash
          get :archived
          get :groups
          get :demo
        end
        member do
          post :archive
          post :unarchive
        end
      end
      resources :checklists
      resources :checklist_items do
        collection do
          post :photo
        end
      end
      resources :punchlists, :only => [:show]
      resources :punchlist_items do
        collection do
          post :photo
        end
      end
      resources :comments
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
end
