class V1::CartsController < ApiController
    before_action :set_objects
    before_action :set_cart, only: [:show, :update, :destroy]
    before_action :set_cart_details, only: [:index]

    def index
    end

    def show
    end

    def create
        @cart = @cart_object.new(cart_params)
        if @cart.save
            render json: @cart, status: :created
        else
            render_api_error(0, 422, 'error', {"email":"Invalid cart details"})
        end
    end
  
    def update
        @cart  = @cart_object.update(cart_params)
        if @cart
            render json: @cart, status: :created
        else
            render_api_error(0, 422, 'error', {"email":"Invalid cart details"})
        end
    end

    def destroy
      if @cart.present?
      @cart.action=params[:action]
      @cart.current_user=current_user
      @cart.value=@value
      @cart.destroy
      end
    end

    private

      def validate_email(email)
        if email.blank?
            return nil
        elsif (email =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i).blank?
            return nil
        else
            return 1
        end
      end

      def set_cart_details
        @carts = @cart_object.where(@id => @value)
        @product_details = Cart.get_cart_details(@carts)
      end

      def set_objects
        if current_user.present?
          @cart_object =  Cart
          @id =  :user_id
          @value =  current_user.id
          @from_email=current_user.email
        else
          @cart_object =  GuestCart
          @id =  :token_id
          @value = token
          @from_email= nil
        end
      end
  
      def set_cart
        @cart = @cart_object.where(@id => @value, :product_id => params[:id]).limit(1).first
      end
      
      def cart_params
        cart_params = params.require(:cart).permit(:product_id, :quantity)
        cart_params[@id] = @value   if params[:action] == "create" || cart_params[:product_id].present?
        cart_params[:device_type] = APP_CONFIG["device"][@device] if @device.present?
        cart_params
      end

      def cart_filter_params
        filter_params = params.require(:cart).permit(:user_id)
        filter_params.map{ |key, value| filter_params[key] = nil if value.to_s.downcase == "null"}
        filter_params
      end


  end
