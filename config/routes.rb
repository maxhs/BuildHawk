Buildhawk::Application.routes.draw do
  default_url_options :host => "buildhawk.com"
  devise_for :users, :path => '', :controllers => {:registrations => "registrations"}
  root :to => "home#index"

  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new", :as => :login
    get "login", :to => "devise/sessions#new"
    get "registrations/new", :to => "devise/sessions#new"
    get "logout", :to => "devise/sessions#destroy", :as => :logout
    get 'about', :to => "home#about", :as => :about
  end

  post "/projects/search", :to => "projects#search"
  post "/projects/:id", :to => "projects#update"
  get "/projects/:id/update_report", :to => "projects#update_report"
  post "/reports/:id", :to => "reports#create"
  get "/projects/:id/update_worklist_item", :to => "projects#update_worklist_item"
  post "/users/:id", :to => "users#update"
  post "/checklist_items/:id", :to => "checklist_items#update"

  resources :users
  resources :home do 
    collection do
      get :about
    end
  end
  resources :admin do
    collection do
      get :users
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
      get :editor
      delete :delete_checklist
    end
    member do
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
      get :core_checklist
      get :edit_company
      get :edit_user
      post :update_company
      post :update_user
      delete :destroy_company
      delete :destroy_user
      get :promo_codes
    end
  end
  resources :promo_codes do
    member do
      get :cancel_editing
    end
  end

  resources :projects do
    member do
      get :worklist
      get :new_item
      post :create_item
      get :new_subcategory
      post :create_subcategory
      get :new_category
      post :create_category
      get :edit_checklist_item
      post :export_worklist
      post :export_checklist
      post :search_items
      post :search_worklist
      get :checklist
      get :checklist_item
      get :reports
      post :search_reports
      get :new_report
      get :show_report
      post :report
      get :documents
      get :show_photo
      get :document_photos
      get :checklist_photos
      get :worklist_photos
      get :report_photos
      get :new_photo
      post :photo
      delete :delete_item
      delete :delete_report
      delete :delete_photo
      post :update_report
      delete :delete_checklist
      get :destroy_confirmation

    end
    collection do
      post :search
    end
  end
  resources :companies
  resources :comments
  resources :checklists do 
    member do
      get :new_checklist_item
      post :create_checklist_item 
      get :category
      get :subcategory
      get :load_items
      patch :update_category
      patch :update_subcategory
      delete :destroy_category
      delete :destroy_subcategory
    end
  end
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
  resources :photos
  resources :punchlists
  resources :reports do
    member do
      get :generate
    end
  end
  resources :folders
  resources :subs, :only => [:update]
  resources :charges do
    member do 
      patch :promo_code
    end
  end

  #mobile API
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

  resque_constraint = lambda do |request|
    request.env['warden'].authenticate? and request.env['warden'].user.uber_admin?
  end
  
  constraints resque_constraint do
    mount Resque::Server.new, :at => "/resque"
  end
end
