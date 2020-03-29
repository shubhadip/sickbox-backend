class CreateCarts < ActiveRecord::Migration[6.0]
  def change
    create_table :carts, :id=>false do |t|
      t.column :id, INT_PRIMARY_ID
      t.column :user_id, BIGINT_UNSIGNED, index: true
      t.column :product_id, UNSIGNED, index: true
      t.column :quantity, UNSIGNED
      t.column :device_type, UNSIGNED,  limit:1, index: true
    end
  end
end
