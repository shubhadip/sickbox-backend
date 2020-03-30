class AddAlternateMobileToAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :alternate_mobile, :string, limit: 15
  end
end
