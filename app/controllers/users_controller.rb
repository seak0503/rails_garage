class UsersController < ApplicationController
  include Garage::RestfulActions

  def require_resources
    @resources = User.all
  end

  def require_resource
    @resource = User.find(params[:id])
  end

  def create_resource
    @resources.create!(user_params)
  end

  def update_resource
    @resource.update_attributes!(user_params)
  end

  def destroy_resource
    @resource.destroy!
  end

  def user_params
    params.permit(:name, :email)
  end
end
