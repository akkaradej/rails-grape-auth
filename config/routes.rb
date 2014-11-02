Rails.application.routes.draw do
  devise_for :users
  mount ApplicationApi => '/api'
  root to: "application#index"
end
