json.array!(@products) do |product|
  @fields.each do |key|
    json.(product, key.to_sym)
  end
end