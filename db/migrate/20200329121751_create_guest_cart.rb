class CreateGuestCart < ActiveRecord::Migration[6.0]
  def change
    create_table :guest_carts, id: false do |t|
      t.column :id, INT_PRIMARY_ID
      t.string :token_id, index: true, limit: 100
      t.column :product_id, UNSIGNED, index: true
      t.column :quantity, UNSIGNED
      t.column :device_type, UNSIGNED, limit: 1, index: true
    end
  end
end
