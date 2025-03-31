Rails.application.routes.draw do
    get "/auto-login" => "session#auto_login"
    post "/session" => "session#login"
#    resources :users, only: :create

    namespace :api do
        namespace :v1 do
            resources :parts, only: [ :index, :show, :create, :update, :destroy ] do
                collection do
                  post "available_parts"
                end
            end
            resources :configs, only: [ :index, :show, :create ] do
                collection do
                    post "config_price_req"
                end
            end
            resources :orders, only: [ :index, :show, :update, :create ] do
                collection do
                    get "show_current"
                end
            end
            resources :users, only: :create
        end
    end
    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
    # Can be used by load balancers and uptime monitors to verify that the app is live.
    get "up" => "rails/health#show", as: :rails_health_check

    # Defines the root path route ("/")
    # root "posts#index"
end
