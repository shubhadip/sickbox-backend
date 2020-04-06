json.extract! @order, :id, :parent_id, :address_id, :user_id, :cod_money, :shipping_money, :due_date, :device_type, :status, :is_confirm, :confirm_date, :payment_gateway, :packing_note, :admin_user_id, :invoice_no, :invoice_date, :created_at, :updated_at

if @order.address.present?
  json.address do |json|
    json.extract! @order.address, :id, :first_name, :last_name, :pincode, :landmark, :address, :mobile, :city, :state, :country
  end
end


total_order_products = 0
json.order_products do |json|
  json.array!(@order.order_products) do |order_product|
    json.extract! order_product, :id, :quantity, :price, :dispatched_at
        total_order_products += order_product.quantity
    end
  end

json.products_count total_order_products