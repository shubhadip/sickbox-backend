if @item.present?
  json.extract! @item, :id, :title, :description, :buttonText, :imageUrl, :description
end