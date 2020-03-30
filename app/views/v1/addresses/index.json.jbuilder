json.addresses do |json|
  json.array!(@addresses) do |address|
    json.extract! address, :id, :user_id, :first_name, :last_name, :pincode, :landmark, :address, :mobile, :status, :city, :state, :country, :created_at, :updated_at, :sub_type, :alternate_mobile, :full_name
  end
end
