class V1::AuthenticationController < ApiController
  before_action :class_name
  before_action :authenticate_user, only: %i[destroy]
  after_action :transfer_cart, only: %i[create]
  after_action :update_user_device, only: %i[create] #:generate_otp
  #before_action :verify_duplicate_requests
  include AuthenticationModule

  def transfer_cart
    # Cart.get_guest_cart(@user, token) if @user.present?
  end

  def update_user_device
    if @user.present? and params[:device].present? and
         params[:device][:device_id].present?
      @device_data =
        Device.where("device_id": params[:device][:device_id]).first
      @device_data.update("user_id": @user.id) if @device_data.present?
    end
  end

  private

  def class_name
    @user_class = @user_class || User
  end
end
