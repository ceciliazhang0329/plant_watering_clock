Rails.application.routes.draw do
  # Routes for the Plant resource:

  # CREATE
  post("/insert_plant", { :controller => "plants", :action => "create" })
          
  # READ
  get("/plants", { :controller => "plants", :action => "index" })
  
  get("/plants/:path_id", { :controller => "plants", :action => "show" })
  
  # UPDATE
  
  post("/modify_plant/:path_id", { :controller => "plants", :action => "update" })
  
  # DELETE
  get("/delete_plant/:path_id", { :controller => "plants", :action => "destroy" })

  #------------------------------

  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
