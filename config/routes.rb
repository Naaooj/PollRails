Poll::Application.routes.draw do
  resources :surveys

  get "home/index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  match "/home" => "home#index"
  match "/home/random" => "home#random"
  
  match "/auth/:provider/callback" => "authentication#create"
  
  match "/authentication/create" => "authentication#create"
  match "/authentication/new" => "authentication#new"
  match "/authentication/login" => "authentication#login"
  match "/authentication/validate" => "authentication#validate"
  
  match "/surveys/vote" => "surveys#vote"
  
  match "/signout" => "authentication#destroy", :as => :signout

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"
  
  # Une fois le fichier index.html du répertoire public supprimé, 
  # il faut définir la route principale de notre application
  # La route root par défaut est mappée sur notre controller home pour la méthode index
  root :to => "home#index"
  
  #resource :open_id do
  #  get :complete
  #end
  
  resource :session
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
