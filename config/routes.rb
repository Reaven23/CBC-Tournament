Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]

  root to: "pages#home"

  # Admin routes
  namespace :admin do
    root to: "dashboard#index"
    resources :tournaments do
      member do
        patch :generate_quarters
        delete :delete_quarters
        patch :generate_semis
        delete :delete_semis
        patch :generate_finals
        delete :delete_finals
        post :create_pools
        patch :generate_pool_games
        patch :change_status
      end
      resources :teams, only: [:create, :edit, :update, :destroy] do
        member do
          patch :assign_team_to_pool
          patch :remove_team_from_pool
          delete :remove_photo
        end
      end
      resources :referees, only: [:index, :new, :create, :edit, :update, :destroy]
      resources :games, only: [:edit, :update]
    end
    resources :users, only: [:index, :new, :create]
    resources :notifications, only: [:index, :show, :destroy]
  end

  # Public tournament routes
  resources :tournaments, only: [:index, :show] do
    resources :games, only: [:show]
    resources :teams, only: [:show]
  end

  # Contact form
  post 'contact', to: 'notifications#create'

  # Sitemap
  get 'sitemap.xml', to: 'sitemap#index', defaults: { format: 'xml' }

  # Robots.txt
  get 'robots.txt', to: 'robots#index', defaults: { format: 'text' }

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
