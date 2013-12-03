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
  
  resources :users
  resources :admin
  resources :projects
  resources :checklists
  resources :photos
  resources :punchlists
  resources :reports
end
