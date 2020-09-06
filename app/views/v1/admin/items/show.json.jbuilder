if @item.present?
  json.extract! @item, :id, :title, :description, :buttonText
    if @item.images.present?
    json.images do 
      json.array!(@item.images) do |image|
        json.extract! image, :key, :filename
      end
    end
  end
end