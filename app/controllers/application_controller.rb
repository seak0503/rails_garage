class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  include Garage::ControllerHelper

  def current_resource_owner
    @current_resource_owner ||= User.find(resource_owner_id) if resource_owner_id
  end

  rescue_from WeakParameters::ValidationError do
    head 400
  end

  rescue_from ActiveRecord::RecordNotFound, with: :rescue404

  private
  def rescue404(e)
    render json: { status_code: 404, error: "Not Found" }, status: 404
  end
end
