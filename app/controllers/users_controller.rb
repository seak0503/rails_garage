class UsersController < ApplicationController
  include Garage::RestfulActions

  def require_resources
    @resources = User.all
  end
end
