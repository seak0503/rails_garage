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
    @type = @exception.class.to_s.split('::').last
    @errors = []
    case @exception
    when ActiveRecord::RecordInvalid
      @exception.record.errors.messages.each do |k,v|
        v.each do |m|
          @errors.push({message: "#{k} #{m}", type: @type, more_info:""})
        end
      end
    else
      @errors.push({message: "不正な要求です。", type: @type, more_info: ""})
    end
    render json: { errors: @errors }, status: 400
  end
  def rescue404(e)
    @exception = e
    @type = @exception.class.to_s.split('::').last
    @message = "リンクが不正か、ご指定のページが見つかりません。"
    @more_info = ""
    render json: { errors: [ message: @message, type: @type, more_info: @more_info ] }, status: 404
  end
  def rescue403(e)
    @exception = e
    @type = @exception.class.to_s.split('::').last
    @message = "ご指定のページを閲覧する権限がありません。"
    @more_info = ""
    render json: { errors: [ message: @message, type: @type, more_info: @more_info ] }, status: 403
  end
  def rescue500(e)
    @exception = e
    @type = @exception.class.to_s.split('::').last
    @message = "システムエラーが発生しました。"
    @more_info = ""
    render json: { errors: [ message: @message, type: @type, more_info: @more_info ] }, status: 500
  end
end