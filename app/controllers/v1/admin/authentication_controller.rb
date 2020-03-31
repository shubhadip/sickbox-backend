class V1::Admin::AuthenticationController < V1::AdminController
  before_action :class_name
  skip_before_action :authenticate_user, only: %i[create]
  include AuthenticationModule

  private

  def class_name
    @user_class = @user_class || AdminUser
  end
end
