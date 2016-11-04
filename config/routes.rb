Rails.application.routes.draw do
  root 'donations#index'

  resources :donations
end
