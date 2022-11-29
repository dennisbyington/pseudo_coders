Rails.application.routes.draw do
  namespace :api do 
    namespace :v0 do

      get "/companies/bbox/:company_id/:blob_id", to: "companies#bbox"
      get "/companies/random/:company_id", to: "companies#random"
    
      resources :companies
    end
  end
end
