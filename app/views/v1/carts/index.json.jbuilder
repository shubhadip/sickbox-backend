json.carts do |json|
    json.products do |json| 
      json.array!(@product_details) do |product|
        json.extract! product, :product_id, :name, :status, :meta_title, :meta_description, :price, :mrp, :weight
      end
    end
end