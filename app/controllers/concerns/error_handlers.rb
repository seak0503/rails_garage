module ErrorHandlers
  extend ActiveSupport::Concern
  included do
    rescue_from Exception, with: :rescue500
    rescue_from ActionController::ParameterMissing, with: :rescue400
    rescue_from ApplicationController::Forbidden, with: :rescue403
    rescue_from ActionController::RoutingError, with: :rescue404
    rescue_from ActiveRecord::RecordNotFound, with: :rescue404
    rescue_from ActiveRecord::RecordInvalid, with: :rescue400

  end

  private
  def rescue400(e)
    @exception = e
    case @exception
    when ActiveRecord::RecordInvalid
      errors = []
      @exception.record.errors.messages.each do |k,v|
        v.each do |m|
          errors.push({message: "#{k} #{m}", type: @exception.class.to_s.split('::').last, more_info:""})
        end
      end
      render json: { errors: errors }, status: 400
    else
      render json: { error: "Bad Request", error_description: "不正な要求です。" }, status: 400
    end
  end
  def rescue404(e)
    @exception = e
    render json: { error: "Not Found", error_description: "リンクが不正か、ご指定のページが見つかりません。" }, status: 404
  end
  def rescue403(e)
    @exception = e
    render json: { error: "Forbidden", error_description: "ご指定のページを閲覧する権限がありません。" }, status: 403
  end
  def rescue500(e)
    @exception = e
    render json: { error: "Internal Server Error", error_description: "システムエラーが発生しました。" }, status: 500
  end
end