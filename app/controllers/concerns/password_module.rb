module PasswordModule
    extend ActiveSupport::Concern
    
    def new
      user = @user_class.find_by_email(params[:email])
      if user
        user.send_password_reset
        render json: {message: "An email will be sent to #{user.email} with a link to reset your password. Please check your email for further process."}, status: :ok 
      else
        render_api_error(41, 401)
      end
    end
  
    private
  
      def password_params
        params.require(:password).permit(:password, :new_password, :email, :reset_password_token)
      end
  end