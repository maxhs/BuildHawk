Buildhawk::Application.routes.draw do
  default_url_options :host => "buildhawk.com"
  devise_for :users, :path => ''
  root :to => "home#index"

  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new", :as => :login
    get "login", :to => "devise/sessions#new"
    get "registrations/new", :to => "devise/sessions#new"
    get "logout", :to => "devise/sessions#destroy", :as => :logout
  end

  post "/projects/:id", :to => "projects#update"

  resources :users
  resources :admin do
    collection do
      get :users
      get :edit_user
      get :new_user
      post :create_user
      get :reports
      get :checklists
      get :new_project
      post :create_project
      get :billing
      get :editor
      get :item_editor
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
      put :update_company
    end
  end
  resources :projects do
    member do
      get :punchlists
      get :new_punchlist_item
      get :edit_punchlist_item
      get :edit_checklist_item
      post :punchlist_item
      get :checklist
      post :create_checklist_item
      get :checklist_item
      get :reports
      get :new_report
      get :show_report
      post :report
      get :photos
      get :new_photo
      post :photo
      delete :delete_report
      delete :delete_photo
    end
    collection do
      put :update_checklist_item
      put :update_punchlist_item
      put :update_report
      delete :delete_punchlist_item
    end
  end
  resources :companies
  resources :checklists
  resources :photos
  resources :punchlists
  resources :reports

  #mobile API
  namespace :api do
    namespace :v1 do
      resources :photos
      resources :companies 
      resources :projects
      resources :users
      resources :comments
    end
  end

end
