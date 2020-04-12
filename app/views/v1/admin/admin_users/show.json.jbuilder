# Map admin user values to json
json.admin_user do |json|
	json.extract! @admin_user, :id, :first_name, :last_name, :email, :personal_email, :mobile, :mobile_other, :designation, :department, :enable, :can_login, :can_sales_login
end
