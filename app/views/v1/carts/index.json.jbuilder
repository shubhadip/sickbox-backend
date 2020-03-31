json.carts do |json|
    json.products do |json| 
      json.array!(@product_details) do |product|
        json.extract! product, :product_id, :name, :status, :meta_title, :meta_description, :price, :mrp, :weight, :selected_qty, :cart_id
      end
    end
    json.total_quantity @total_quantity
end