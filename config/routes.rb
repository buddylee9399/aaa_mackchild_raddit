Rails.application.routes.draw do
  post '/webhooks/:source', to: 'webhooks#create'
  resources :paintings
  
  # resources :comments

  devise_for :users
  resources :links do
    member do
      put "like", to:    "links#upvote"
      put "dislike", to: "links#downvote"
    end
    resources :comments
  end
  root "links#index"

end
