Rails.application.routes.draw do
  root "home#index"

  resources :feeds, only: [ :create, :show, :update, :destroy ], param: :public_id do
    resources :entries, only: [ :show ], param: :public_id, controller: "feed_entries"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
