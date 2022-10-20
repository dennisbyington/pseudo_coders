Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :api do 
    namespace :v0 do
      resources :documents
      resources :companies
    end
  end
end
