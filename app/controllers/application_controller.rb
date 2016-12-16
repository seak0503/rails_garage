class ApplicationController < ActionController::Base

  protect_from_forgery with: :null_session

  class Forbidden < ActionController::ActionControllerError; end

  include Garage::ControllerHelper
  include ErrorHandlers

  def current_resource_owner
    @current_resource_owner ||= User.find(resource_owner_id) if resource_owner_id
  end

  def doorkeeper_unauthorized_render_options(error: nil)
    status_code = case error.status
                  when :unauthorized
                    401
                  when :forbidden
                    403
                  end

    { json: { error: error.status, error_description: error.description }, status: status_code }
  end

  rescue_from WeakParameters::ValidationError do
    head 400
  end
end
