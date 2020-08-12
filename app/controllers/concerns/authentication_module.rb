module AuthenticationModule
  extend ActiveSupport::Concern

  def create
    params[:authentication][:device] = @device
    @user =
      current_user ||
        @user_class.find_by(authentication_params.slice(:email, :mobile))
    return_data = @user.authenticate(authentication_params) if @user.present?
    login_condition = (@user.present? and return_data.present?)
    # @user.check_login_attempts(login_condition) if @user.present?
    if login_condition and @user.try(:errors).blank?
      return_data = return_data if @user.is_a?(User)
      render json: return_data, status: :created
    else
      if @user.try(:errors).blank?
        render_api_error(49, 400)
      else
        if (@user.try(:errors).present? and @user.try(:errors)['OTP'].present?)
          render_api_error(11, 400, 'error', @user.try(:errors))
        else
          if (@user.try(:errors)['LOGIN'].present?)
            render_api_error(
              49,
              400,
              'error',
              @user.try(:errors).messages[:LOGIN].first
            )
          else
            render_api_error(49, 401)
          end
        end
      end
    end
  end

  def verify_duplicate_requests
    # if (!ip_val.nil? ? (ip_val > 1000 ? true : false) : false)
    #   render json: {message: 'Your IP is blocked because of too many attempts'}
    #   return false
    # end

    if authentication_params[:otp_code].present?
      ip_val = ($redis.get("ip:#{request.remote_ip}")).to_i

      ip_val =
        if ip_val.present?
          $redis.incr("ip:#{request.remote_ip}")
        else
          $redis.set("ip:#{request.remote_ip}", 1)
        end
      if $redis.ttl("ip:#{request.remote_ip}") === -1
        $redis.expire("ip:#{request.remote_ip}", 604_800)
      end
      mobile_key =
        "mobile_otp_key:#{authentication_params[:mobile]}:#{
          authentication_params[:otp_code]
        }"
      all_keys =
        $redis.keys("mobile_otp_key:#{authentication_params[:mobile]}*")
      if all_keys.count > 3
        render json: {
                 message: 'Your IP is blocked because of too many attempts'
               }
        return false
      end
      $redis.set(mobile_key, 'mobile_otp_key')
      $redis.expire(mobile_key, 3600)
    end
  end

  def update; end

  def generate_otp
    @user =
      current_user ||
        @user_class.find_by(mobile: authentication_params[:mobile])
    if @user.present?
      user_exists = @user.check_user_exists(authentication_params)
    end
    if @user.present? and user_exists
      otp = @user.generate_otp(authentication_params)
    end
    if @user.present? and @user.errors.blank? and otp
      if $redis.exists("user:#{authentication_params[:mobile]}") and
           $redis.hget("user:#{authentication_params[:mobile]}", 'resend')
             .to_i >
             1
        msg = 'OTP Resent'
      else
        msg = 'OTP Sent'
      end
      render json: { message: msg }, status: :ok
    else
      if @user.present?
        render_api_error(10, 400, 'error', @user.try(:errors))
      else
        render_api_error(48, 401)
      end
    end
  end

  def destroy
    if current_user.destroy_session(@token, @device)
      render json: { message: 'Sign Out successful' }, status: :ok
    else
      render_api_error(15, 500, 'error', 'Sign Out Failed')
    end
  end

  private

  def authentication_params
    params.require(:authentication).permit(
      :password,
      :email,
      :device,
      :ip,
      :facebook_id,
      :google_id,
      :mobile,
      :otp_code
    )
  end
end
