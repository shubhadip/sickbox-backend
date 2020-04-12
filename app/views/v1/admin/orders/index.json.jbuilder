# json.total_count @total_result
json.orders do |json|
    json.array!(@orders) do |order|
      @fields.each do |key|
        json.(order, key.to_sym)
      end
      json.is_prepaid order.is_prepaid?
      if @additional_fields.include? "final_amount"
        json.final_amount order.final_amount
      end

      if order.payment_gateway.present? and  @fields.include? "payment_gateway"
        json.payment_gateway order.payment_gateway
      end
      if @additional_fields.include? "user" and order.user
        json.user do |json|
          json.extract! order.user, :id, :first_name, :last_name, :gender, :status, :wallet_amount, :email, :blacklist_user
          if @additional_fields.include? "user_fact"
            json.user_level (order.user.user_fact.present? ? order.user.user_fact.level : order.user.user_level)
            json.user_rating (order.user.user_fact.present? ? order.user.user_fact.score : order.user.user_rating)
          end
        end
      end
      if @additional_fields.include? "address" and order.address.present? 
        json.address do |json|
          json.extract! order.address, :id, :first_name, :last_name, :pincode, :landmark, :address, :mobile, :city, :state, :country, :alternate_mobile
        end
      end

      if @additional_fields.include? "order_products"
        json.order_products do |json|
          json.array!(order.order_products) do |order_product|
            json.extract! order_product, :id, :quantity, :price, :dispatched_at
                json.product do |json|
                    if @additional_fields.include? "product" and order_product.product.present?
                    json.extract! order_product.product, :id, :name, :mrp
                    end
                end
            end
        end
      end
    end
  end