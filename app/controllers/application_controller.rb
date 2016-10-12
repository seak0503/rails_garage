class ApplicationController < ActionController::Base

  include Garage::ControllerHelper

  protect_from_forgery with: :exception

  def current_resource_owner
    @current_resource_owner ||= User.find(resource_owner_id) if resource_owner_id
  end
end
