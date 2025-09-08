Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

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
  end


    resources :pitches
    resources :cls
  end

end
