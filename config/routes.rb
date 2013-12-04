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
  resources :admin
  resources :uber_admin do
    collection do
      post :upload_template
    end
  end
  resources :projects do
    member do
      get :punchlists
      get :new_punchlist_item
      get :edit_checklist_item
      post :punchlist_item
      put :update_punchlist_item
      get :checklist
      post :checklist_item
      put :update_checklist_item
      get :reports
      get :photos
      get :new_photo
      post :photo
    end

  end
  resources :checklists
  resources :photos
  resources :punchlists
  resources :reports
end
