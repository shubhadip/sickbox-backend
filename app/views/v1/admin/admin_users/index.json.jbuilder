json.array!(@admin_users) do |admin_user|
  # Map admin user values to json
  @fields.each do |key|
    json.(admin_user, key.to_sym)
  end
end