class CreateOrderProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :order_products, id: false do |t|
      t.column :id, BIGINT_PRIMARY_ID
      t.column :order_id, BIGINT_UNSIGNED, index: true
      t.column :product_id, UNSIGNED, index: true
      t.column :quantity, UNSIGNED
      t.float :price #price of one
      t.datetime :dispatched_at
      t.timestamps null: false
    end
  end
end
