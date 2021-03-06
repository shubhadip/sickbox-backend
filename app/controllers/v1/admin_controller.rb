class V1::AdminController < ApiController
  before_action :authenticate_user

  def authenticate_user
    access_token =
      if request.headers['HTTP_ACCESS_TOKEN'].present?
        request.headers['HTTP_ACCESS_TOKEN']
      else
        params[:t]
      end
    if access_token.present?
      token, email = Base64.decode64(access_token).split(/:/, 2)
    end
    state_name = request.headers['HTTP_STATE_NAME']
    request_type = request.headers['REQUEST_METHOD']
    @admin_user = AdminUser.check_redis_token(email, token, @device)
    if @admin_user.blank?
      render_api_error(10, 401)
    else

    end
  end

  def current_user
    @admin_user = @admin_user || get_user
  end

  def state_name
    request.headers['HTTP_STATE_NAME']
  end

  def get_user
    if request.headers['HTTP_ACCESS_TOKEN'].present?
      token, email =
        Base64.decode64(request.headers['HTTP_ACCESS_TOKEN']).split(/:/, 2)
    end
    if @admin_user = AdminUser.check_redis_token(email, token, @device)
      @admin_user
    end
  end
end
