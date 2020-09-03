if @product.present?
  json.extract! @product, :id, :name, :url, :meta_title, :meta_description, :meta_keywords, :price, :status
    if @product.avatar.present?
    
      json.avatar do |json|
          json.extract! @product.avatar, :id, :key, :filename
          json.avatarimage @product.imageUrl
      end 
    end
    if @product.items.present?
      json.items do |json|
        json.array!(@product.items) do |item|
          json.extract! item, :id, :title, :description, :imageUrl
      end
    end
    
  end
end