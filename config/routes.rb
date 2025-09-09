Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Health check endpoints for monitoring and orchestration
  get "up" => "rails/health#show", as: :rails_health_check
  get "health" => "health#show", as: :health_check
  get "health/detailed" => "health#detailed", as: :detailed_health_check
  get "ready" => "health#ready", as: :readiness_check
  get "live" => "health#live", as: :liveness_check

  get  "/suggestion", to:"suggestion#new"
  post  "/suggestion", to:"suggestion#create"
  get  "/dashboard", to:"dashboards#all"



  resources :applications do

  member do
    get  :trait
    patch :trait
    get  :overview
    post :generate_cl
    post :generate_video
    post :final_cl
    post :final_pitch

    get :video_page
    get  :new_video
    post :create_video
    get :generating
    get :status

    # Phase 3: LinkedIn Profile Analysis & ML Predictions
    get  :linkedin_analysis
    post :linkedin_analysis
    get  :ml_predictions
    post :ml_predictions
  end


    resources :pitches
    resources :cls
  end

end
