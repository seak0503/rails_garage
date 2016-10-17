class PostsController < ApplicationController

  validates :create do
    string :title, required: true, description: 'You can not specify title as emtpry string.'
  end

  include Garage::RestfulActions

  def require_resources
    if params[:user_id]
      @resources = User.find(params[:user_id]).posts
    else
      @resources = Post.all
    end
  end

  def create_resource
    @resources.create(post_params.merge(user_id: resource_owner_id))
  end

  def require_resource
    @resource = Post.find(params[:id])
  end

  def update_resource
    @resource.update_attributes!(post_params)
  end

  def destroy_resource
    @resource.destroy!
  end

  def post_params
    params.permit(:title, :body, :published_at)
  end
end
