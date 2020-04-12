class V1::Admin::OrdersController < V1::AdminController
before_action :set_order, only: [:show, :update, :destroy]
  before_action :set_fields, only: [:index]

  def index
    @orders = Order.includes(set_includes)
    order_filter if params[:order].present?
    @total_result = @orders.count
    @orders = @orders.order(order_by).limit(limit).offset(offset)
    if @additional_fields.include? "order_products"
       @product_quantity = {}
    end
    status_fields = APP_CONFIG["order_status"].map {|id, status| id if @additional_fields.include? status["status"]}.compact
    @order_status_counts = Order.order_status_count(@orders, status_fields) if status_fields.present?
  end

  # GET /v1/admin/orders/1
  # GET /v1/admin/orders/1.json
  def show
    @order.update_by_admin_user = current_user
  end

  # POST /v1/admin/orders.json
  def create
    @order = Order.new(order_params)
    @order.admin_user = current_user
    @order.update_by_admin_user = current_user.name
    if @order.save
      render json: :create, status: :created
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /v1/admin/orders/1
  # PATCH/PUT /v1/admin/orders/1.json
  def update
      @order.update_by_admin_user = current_user
      if @order.update(order_params)
        render :show, status: :ok
      else
        render_api_error(22,400,'server',@order.errors)
      end
    end

  def static_data
    data = {}
    data[:device_type]= Order.device_types.keys
    data[:status] = Order.statuses.keys
    data[:payment_gateway] = Order.payment_gateways.keys
    render json: data
  end

  private
    def order_filter
      @orders = @orders.where(order_filter_params)
      if params[:order][:user].present? and (order_user_filter_params[:email].present?  or  order_user_filter_params[:id].present?)
        @orders = @orders.where(user: filter_by_users)
      elsif order_name_params.present?
        @orders = @orders.where(filter_by_name)
      end
      @orders = @orders.where(address: filter_by_address) if params[:order][:address].present? and order_address_filter_params.present?
      @orders = @orders.where('orders.created_at >= ?', Time.zone.parse(params[:order][:created_at_from]).to_date) if params[:order][:created_at_from].present? and Date.is_date?(params[:order][:created_at_from])
      @orders = @orders.where('orders.created_at <= ?', Time.zone.parse(params[:order][:created_at_till]).to_date) if params[:order][:created_at_till].present? and Date.is_date?(params[:order][:created_at_till])
      @orders = @orders.joins(:order_products).merge(filter_by_order_products) if params[:order][:order_products].present?
    end

    def filter_by_users
     User.where(order_user_filter_params)
    end

    def filter_by_name
      condition = ""
      order_conditon = ""
      if order_name_params[:user].present?
        condition += "`orders`.`user_id` IN  (SELECT `users`.`id` FROM `users` WHERE "
        condition += " MATCH(users.first_name) AGAINST('#{order_name_params[:user][:first_name]}*' IN BOOLEAN MODE) " if order_name_params[:user][:first_name].present?
        condition += " AND "if order_name_params[:user][:first_name].present? and order_name_params[:user][:last_name].present?
        condition += " MATCH(users.last_name) AGAINST('#{order_name_params[:user][:last_name]}*' IN BOOLEAN MODE) " if order_name_params[:user][:last_name].present?
        condition += ")"
        order_conditon += condition
      end
      order_conditon += " OR " if order_name_params[:user].present? and order_name_params[:address].present?
      condition = ""
      if order_name_params[:address].present?
        condition += "`orders`.`address_id` IN  (SELECT `addresses`.`id` FROM `addresses` WHERE "
        condition += " MATCH(addresses.first_name) AGAINST('#{params[:order][:address][:first_name]}*' IN BOOLEAN MODE) " if order_name_params[:address][:first_name].present?
        condition += " AND "if order_name_params[:address][:first_name].present? and order_name_params[:address][:last_name].present?
        condition += " MATCH(addresses.last_name) AGAINST('#{params[:order][:address][:last_name]}*' IN BOOLEAN MODE)" if order_name_params[:address][:last_name].present?
        condition += ")"
        order_conditon += condition
      end
      order_conditon
    end

    def filter_by_address
      Address.where(order_address_filter_params)
    end

    def filter_by_order_process
      @order_processes = OrderProcess.where(order_process_filter_params)
      date_filters.each do |key, value|
        @order_processes = @order_processes.where("date(#{key}_date) >= ?", Time.zone.parse(value[:date_start]).to_date) if value[:date_start].present? and Date.is_date?(value[:date_start])
        @order_processes = @order_processes.where("date(#{key}_date) <= ?", Time.zone.parse(value[:date_end]).to_date) if value[:date_end].present? and Date.is_date?(value[:date_end])
        @order_processes  = @order_processes.order("date(#{key}_date) desc") if @additional_fields.include? "packed_orders"
      end
      @order_processes 
    end

    def filter_by_order_products
      @order_products = OrderProduct.where(order_products_filter_params)
    end

    def date_filters
      params.require(:order).require(:order_process).permit(shipping: [:date_end,:date_start], packing: [:date_end, :date_start], delivered: [:date_end, :date_start], rto: [:date_end, :date_start])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.includes({order_products: :product}).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      order_hash = params.require(:order).permit(:address_id, :user_id, :cod_money, :shipping_money, :due_date, :device_type, :retailer, :status, :is_confirm, :payment_gateway, :packing_note, :remark, :update_by_admin_user ,address_attributes: [:first_name, :last_name, :pincode, :landmark, :address, :mobile, :city, :state, :country])
      order_hash[:address_attributes][:user_id] = @order.user_id || order_hash[:user_id] if order_hash[:address_attributes].present?
      order_hash.merge! params.permit(:controller, :action)
      order_hash[:order_products_attributes] = []
      params.require(:order).require(:order_products_attributes).map { |order_product| order_hash[:order_products_attributes]<< order_product.permit(:product_id, :quantity, :status, :price, :dispatched_at, :_destroy, :id, :remove).merge!({update_by_admin_user: current_user}) } if params.require(:order)[:order_products_attributes].present?
      order_hash
    end

    def order_filter_params
      filter_params = params.require(:order).permit(:id,:name, :title, :parent_id, :enable, :model, :user_id, :device_type, :payment_gateway, :is_confirm, :sub_status, :retailer , id: [] ,device_type: [], payment_gateway: [], status: [])
      filter_params[:id] = filter_params[:id].uniq - [0]  if filter_params[:id].present? && filter_params[:id].kind_of?(Array)
      filter_params.delete_if {|key, value| value.blank?}
      attributes = filter_params.to_h || {}
      attributes = attributes.values
      attributes.map{ |key, value| filter_params[key] = nil if value.to_s.downcase == "null"}
      filter_params[:device_type] = filter_params[:device_type].inject([]){ |device_types, key| device_types << Order.device_types[key]} if filter_params[:device_type].present?
      filter_params[:payment_gateway] = filter_params[:payment_gateway].inject([]){ |payment_gateways, key| payment_gateways << Order.payment_gateways[key]} if filter_params[:payment_gateway].present?
      filter_params[:status] = filter_params[:status].inject([]){ |statuses, key| statuses << Order.statuses[key]} if  filter_params[:status].kind_of?(Array) if filter_params[:status].present?
      filter_params[:status] =  Order.statuses.values - filter_params[:status] if params[:order][:status_not].present?
      filter_params
    end

    def order_user_filter_params
      params.require(:order).require(:user).permit(:first_name, :last_name, :email,:id)
    end

    def order_address_filter_params
      order_address_filter_params = params.require(:order).require(:address).permit(:pincode, :landmark, :address, :mobile, country: [], city: [], state: [])
      order_address_filter_params.delete_if {|key, value| value.blank?}
      order_address_filter_params
    end

    def order_products_filter_params
      filter_params = params.require(:order).require(:order_products).permit(:product_id)
      filter_params.delete_if {|key, value| value.blank?}
      filter_params.map{ |key, value| filter_params[key] = nil if value.to_s.downcase == "null"}
      filter_params
    end

    def order_name_params
      params.require(:order).permit(user: [:first_name, :last_name], address: [:first_name, :last_name])
    end

    def set_includes
      include = []
      include << :address if @additional_fields.include? "address"
      include << :user if @additional_fields.include? "user"
      include << :products if @additional_fields.include? "products"
      include << :order_products if @fields.include? "amount"
      include << {order_products: :product}  if @additional_fields.include? "product"
      include
    end

    def set_fields
      all_fields = params["fields"].present? ? params["fields"].split(',').collect(&:strip) : []
      @fields = (all_fields & (Order.attribute_names+[])) | ["id", "created_at", "device_type"]
      @additional_fields = all_fields & Order.reflect_on_all_associations.map {|object| object.name.to_s}+["product"] | []
    end
end
