json.extract! @order, :id, :address_id, :user_id, :cod_money, :shipping_money, :due_date, :device_type, :retailer, :status, :is_confirm, :confirm_date, :payment_gateway, :packing_note, :admin_user_id, :note_last_updated, :invoice_no, :invoice_date, :created_at, :updated_at

if @order.user.present?
  json.user do |json|
    json.extract! @order.user, :id, :first_name, :last_name, :gender, :status, :device_type, :date_of_birth, :wallet_amount, :email, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :mobile
  end
end

if @order.address.present?
  json.address do |json|
    json.extract! @order.address, :id, :first_name, :last_name,  :landmark, :address, :pincode, :mobile, :city, :state, :country, :status, :alternate_mobile, :sub_type, :state_code
  end
end

json.order_products do |json|
  json.array!(@order.order_products) do |order_product|
    json.extract! order_product, :id, :quantity, :price, :tax, :dispatched_at, :rate, :discount , :amount_exclusive_of_tax, :igst_amount, :cgst_amount, :sgst_amount, :igst_percentage, :cgst_percentage, :sgst_percentage, :gst_product_net_amount, :gst_cod_net_amount, :gst_shipping_net_amount
    json.product do |json|
        if order_product.product.present?
        json.extract! order_product.product, :id, :name, :mrp
        end
    end
  end
end