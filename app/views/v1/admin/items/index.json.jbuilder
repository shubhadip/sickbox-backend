json.array!(@items) do |item|
  @fields.each do |key|
    json.(item, key.to_sym)
  end
end