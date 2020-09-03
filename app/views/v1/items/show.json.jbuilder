if @product.present?
  json.extract! @item, :id, :name, :title, :description, :buttonText
end