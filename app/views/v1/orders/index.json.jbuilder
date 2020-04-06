json.total_count @total_result
json.orders do |json|
  json.array!(@orders) do |order|
    @fields.each do |key|
      json.(order, key.to_sym)
    end

    if @additional_fields.include? "order_products" and order.order_products.present?
      json.order_products do |json|
        json.array!(order.order_products) do |order_product|
          json.extract! order_product, :id, :quantity, :price, :dispatched_at, :already_returned_quantity
        end
      end
    end
    if @additional_fields.include? "address" and order.address.present?
      json.address do |json|
        json.extract! order.address, :id, :first_name, :last_name, :pincode, :landmark, :address, :mobile, :city, :state, :country
      end
    end
  end
end