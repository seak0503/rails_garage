Rails.application.routes.draw do
  use_doorkeeper

  scope :v1 do
    resources :users, only: %i(index show create update destroy) do
      resources :posts, only: %i(index)
    end

    resources :posts
  end

  root 'errors#not_found'
  get '*anything' => 'errors#not_found'
end
