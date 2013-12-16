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

  post "/projects/:id", :to => "projects#update"
  get "/projects/:id/update_report", :to => "projects#update_report"
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
      get :new_user
      post :create_user
      get :reports
      get :checklists
      post :create_template
      get :new_project
      post :create_project
      get :billing
      get :editor
      get :item_editor
      delete :delete_checklist
    end
    member do
      get :edit_user
      post :update_billing
      post :update_user
      post :update_checklist
      delete :delete_user
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
      put :update_company
      post :update_user
    end
  end
  resources :projects do
    member do
      get :worklist
      get :new_worklist_item
      get :edit_worklist_item
      get :edit_checklist_item
      post :worklist_item
      get :checklist
      get :checklist_item
      get :category
      post :update_category
      post :create_checklist_item
      get :reports
      get :new_report
      get :show_report
      post :report
      get :photos
      get :new_photo
      post :photo
      delete :delete_report
      delete :delete_photo
      post :update_report
      post :update_worklist_item
      delete :delete_checklist
    end
    collection do
      delete :delete_worklist_item
    end
  end
  resources :companies
  resources :comments
  resources :checklists
  resources :checklist_items
  resources :photos
  resources :punchlists
  resources :reports

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
      resources :punchlists
      resources :punchlist_items do
        collection do
          post :photo
        end
      end
      resources :users
      resources :comments
      resources :reports
    end
  end

  mount Resque::Server.new, :at => "/resque"
end
