json.array!(@items) do |item|
  @fields.each do |key|
    json.(item, key.to_sym)
    binding.pry
    json.images do |images|
      json.array!(item.images) do |image|
        json.extract! image, :id 
      end
    end
  end
end