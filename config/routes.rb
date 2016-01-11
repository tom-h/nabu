Nabu::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :users

  root :to => 'page#home'

  get '/contact'   => 'page#contact'
  get '/dashboard' => 'page#dashboard'
  get '/glossary'  => 'page#glossary'
  get '/apidoc' => 'page#apidoc'

  post "versions/:id/revert" => "versions#revert", :as => "revert_version"

  resources :users do
    member do
      get 'merge'
      put 'merge' => 'users#merge'
    end
  end
  resources :countries, :only => [:index, :show]
  resources :languages, :only => [:index, :show]
  resources :data_categories, :only => [:index, :show]
  resources :collections do
    collection do
      get 'last_search' => 'collections#return_to_last_search'
      get 'search' => 'collections#search'
      get 'advanced_search' => 'collections#advanced_search'
      get 'bulk_update' => 'collections#bulk_edit'
      put 'bulk_update' => 'collections#bulk_update'
      get 'metadata' => 'collections#new_from_metadata'
      post 'exsite9' => 'collections#create_from_exsite9'
      post 'spreadsheet' => 'collections#create_from_spreadsheet'
    end
    resources :items do
      member do
        get :display
        put :inherit_details
      end
      resources :essences, :only => [:show, :download, :destroy] do
        member do
          get :download
          get :display
          get :show_terms
          get :agree_to_terms
        end
      end
    end
  end
  resources :items, :only => [] do
    collection do
      get 'last_search' => 'items#return_to_last_search'
      get 'search' => 'items#search'
      get 'advanced_search' => 'items#advanced_search'
      get 'bulk_update' => 'items#bulk_edit'
      put 'bulk_update' => 'items#bulk_update'
      get 'new_report' => 'items#new_report'
      post 'send_report' => 'items#send_report'
      get 'report_sent' => 'items#report_sent'
    end
  end

  get '/repository/:collection_identifier' => 'repository#collection', :as => 'repository_collection'
  get '/repository/:collection_identifier/:item_identifier' => 'repository#item', :as => 'repository_item'
  get '/repository/:collection_identifier/:item_identifier/:essence_filename' => 'repository#essence', :as => 'repository_essence', :constraints => { :essence_filename => /.*/ }

  get '/items/*full_identifier' => 'repository#item', :as => 'repository_collection_item'

  get '/essences/mimetypes' => 'essences#list_mimetypes', as: 'list_mimetypes'

  resources :comments, :shallow => true do
    match 'approve' => 'comments#approve', :on => :member, :via => :post
    match 'spam'    => 'comments#spam',    :on => :member, :via => :post
  end
  resources :universities, :only => :create

  scope '/oai' do
    get 'item' => 'oai#item'
    get 'collection' => 'oai#collection'
  end
end
