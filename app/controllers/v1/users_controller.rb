class V1::UsersController < ApiController
  before_action :authenticate_user, except: %i[create verify_user registered?]
  before_action :set_user, only: %i[show update]

  def show; end

  def registered?
    @user =
      if (params[:emobile] =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/).present?
        User.find_by_mobile(params[:emobile])
      else
        User.find_by_email(params[:emobile])
      end
    if @user.present?
      render json: { message: true }, status: :ok
    else
      render_api_error(51, 404)
    end
  end

  def create
    external_api =
      User.external(user_params, request.headers['HTTP_APP_VERSION'].to_i)
    @user = external_api[:user]
    @access_type = external_api[:access_type]
    if @user['nologin'].present?
      render_api_error(22, 400, 'error', @user)
      return
    end

    # clevertap_data = generate_clevertap_object('login', @user, data: { channel: external_api[:channel], access_type:  external_api[:access_type]})

    # transfer_cart()
    if @user.errors.blank?
      render json: @user.user_show, status: :created

      if params[:device].present? and params[:device][:device_id].present?
        @device_data =
          Device.where("device_id": params[:device][:device_id]).first
        @device_data.update("user_id": @user.id) if @device_data.present?
      end
    else
      render_api_error(11, 401, 'error', @user.try(:errors))
    end
  end

  # PATCH/PUT /v1/users/1
  # PATCH/PUT /v1/users/1.json
  def update
    @user.token = @token
    @user.no_validate = true
    if @user.update(user_params)
      render json: @user, status: :ok
    else
      @user.errors.messages[:message] = {}
      return render json: { error: @user.errors }, status: :unprocessable_entity
    end
  end

  def verify_user
    if params[:user][:verify_token].present? and params[:user][:from].present?
      token = Base64.decode64(params[:user][:verify_token])
      email = token.split(':')
      if $redis.get("verify_info:#{email[1]}") == '1'
        @user = User.find_by_email(email[1])
        if params[:user][:from] == 'register' and @user.present?
          @user.update(status: 2)
          $redis.del("verify_info:#{email[1]}")
          render json: { message: 'Email is verified' }, status: :ok
        elsif params[:user][:from] == 'subscribe' and !@user.present?
          @lead_data = Lead.where(email: email[1]).first
          if @lead_data.details.present?
            details = [eval(@lead_data.details), { 'verified' => 1 }]
          else
            details = { 'verified' => 1 }
          end
          details_data = Hash[*details.map(&:to_a).flatten]
          @lead_data.update_attributes(details: details_data)
          $redis.del("verify_info:#{email[1]}")
          render json: { message: 'Email is verified' }, status: :ok
        else
          render json: { message: 'Email is already verified' },
                 status: :unprocessable_entity
        end
      else
        render json: { message: 'Email is already verified' },
               status: :unprocessable_entity
      end
    else
      render json: { message: APP_CONFIG['error'][27] },
             status: :unprocessable_entity
    end
  end

  private

  def transfer_cart
    Cart.get_guest_cart(@user, token)
  end

  def set_user
    @user = current_user.reload
  end

  def user_params
    user_hash =
      params.require(:user).permit(
        :password,
        :new_password,
        :first_name,
        :last_name,
        :gender,
        :mobile,
        :facebook_id,
        :google_id,
        :email,
        :old_password,
        :action
      )
    user_hash[:device_type] = @device
    if !user_hash[:password].present? and user_hash[:new_password].present?
      user_hash[:password] = user_hash[:new_password]
      user_hash = user_hash.except(:new_password)
    end
    user_hash
  end
end
