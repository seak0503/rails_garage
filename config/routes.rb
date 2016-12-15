Rails.application.routes.draw do
  use_doorkeeper
  root to: 'users#index'

  scope :v1 do
    resources :users, only: %i(index show create update destory) do
      resources :posts, only: %i(index)
    end

    resources :posts
  end
end
