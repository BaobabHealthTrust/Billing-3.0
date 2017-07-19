Rails.application.routes.draw do
  root 'main#index'

  get "login" => "sessions#login"
  get "location" => "sessions#location"
  post "location" => "sessions#add_location"
  post "login" => "sessions#create_session"
  get "/logout" => "sessions#destroy"

  get "/main/report_select"
  post "/main/income_summary"
  post "/main/cashier_summary"
  post "/main/daily_cash_summary"
  get "/main/daily_cash_summary"

  resources :patients do
    collection do
      get 'search'
      get 'ajax_search'
      get 'given_names'
      get 'family_names'
      get 'district'
      get 'traditional_authority'
      get 'village'
      get 'nationality'
      get 'landmark'
      get 'country'
      post 'process_result'
      post 'process_confirmation'
      post 'ajax_process_result'
      post 'confirm_demographics'
      post 'ajax_process_data'
      get 'patient_not_found'
      get 'print_national_id'
      get 'patient_by_id(/:id)', action: :patient_by_id
    end
    resources :order_entries
  end

  resources :users
  resources :user_properties
  resources :service_types
  resources :medical_scheme
  resources :medical_scheme_providers
  resources :sessions
  resources :order_entries do
    collection do
      get 'void'
    end
  end
  resources :services do
    collection do
      get 'suggestions'
    end
    resources :service_prices
  end
  resources :order_payments do
    collection do
      get 'print_receipt'
      get 'void'
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
