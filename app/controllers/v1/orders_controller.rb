class V1::OrdersController < ApiController
    before_action :authenticate_user
    before_action :set_order, only: [:show, :update, :destroy]
    before_action :set_fields, only: [:index, :show]
    before_action :check_cart, only: [:create]
    
    # GET /v1/orders
    # GET /v1/orders.json
    def index
      @orders = Order.placed.includes(set_includes).limit(limit).offset(offset).all.order("orders.id desc")
      order_filter
      @total_result = @orders.count
    end
  
    def show
      @order.version = version
    end
    # POST /v1/orders
    # POST /v1/orders.json
    def create
      key = "order:#{current_user.id}"
      return render_api_error(22,400,'error', "order in progress") if $redis.get(key).present?
      $redis.set(key, "active")
      $redis.expire(key, 5)
      @order = Order.new(order_params)
      if @order.save
        # $redis.del("wallet_user:#{current_user.id}")
        render json: @order, status: :created
      else
        $redis.del(key) unless @device == "android"
        error = @order.errors
        error = @order.errors.messages[:"order_products.product"].first if @device == "android"
        render_api_error(22,400,'error',error)
      end
    end
  
    # PATCH/PUT /v1/orders/1
    # PATCH/PUT /v1/orders/1.json
    def update
        @order.update_by_user = current_user
        if @order.update(order_params)
        render :update, status: :ok
        else
        render_api_error(22,400,'error',@order.errors)
        end
    end

    def destroy
      @order.destroy
      head :no_content
    end

    private
      # Use callbacks to share common setup or constraints between actions.

      def check_cart
        render_api_error(22,400,'error',{"order_products.product": ["Bag is Empty"]}) if (params[:order][:order_products_attributes].blank? || Cart.where(user_id: current_user.id).count == 0)
      end

      def set_order
        @order = Order.placed.where(user: current_user).includes({order_products: :product}).find(params[:id])
      end

      def order_filter
        @orders = @orders.where(user: current_user)
        @orders = @orders.where('id = (?)', params[:order_id]) if params[:order_id].present? 
      end

      def set_includes
        include = []
        include << :address if @additional_fields.include? "address"
        if @additional_fields.include? ("order_products")
          include << [:order_products]
        #   include << {:products} if @additional_fields.include? ("products")
        #  include << {product_sizes: [product: [:images, {child_categories: :category}, :color]]}  if @additional_fields.include? ("product_sizes")
        end
        if (@fields & ["discount","final_amount", "cashback", "payable_amount"]).present?
          include << {order_products: :order_deductions}
        elsif @fields.include? "amount"
          include << :order_products
        end
        include
      end
  
      def set_fields
        all_fields = params["fields"].present? ? params["fields"].split(',').collect(&:strip) : []
        @fields = (all_fields & (Order.attribute_names+["is_prepaid", "amount","discount","final_amount", "view_status", "payable_amount"])) | ["id", "created_at", "device_type"]
        @additional_fields = all_fields & Order.reflect_on_all_associations.map {|object| object.name.to_s}+["product_sizes"] | []
      end
      # Never trust parameters from the scary internet, only allow the white list through.
      def order_params
        order_hash = params.require(:order).permit(:address_id, :payment_gateway, :user_id, :due_date, :device, :retailer, :packing_note, :remark, :update_by_user, :wallet_applied).merge!({device_type: @device,version: version})
        order_hash.merge! params.permit(:controller, :actions)
          order_hash.merge! params.require(:order).permit(:status) if params["order"]["status"] == "cancelled"
        if params.require(:order)[:order_products_attributes].present?
          order_hash[:order_products_attributes]=[]
          params.require(:order).require(:order_products_attributes).map { |order_product| order_hash[:order_products_attributes]<< order_product.permit(:product_id, :quantity, :price, :dispatched_at) }
        end
        order_hash[:user_id] = current_user.id
        order_hash
      end
  end
  