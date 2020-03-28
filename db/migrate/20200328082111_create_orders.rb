class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders, :id=>false do |t|
      t.column :id, BIGINT_PRIMARY_ID
      t.column :parent_id, BIGINT_UNSIGNED, index: true
      t.column :address_id, UNSIGNED_NULL, index: true
      t.column :user_id, BIGINT_UNSIGNED, index: true
      t.float :cod_money, default:0, null:false
      t.float :shipping_money, default:0, null:false
      t.date :due_date
      t.column :device_type, UNSIGNED,  limit:1, index: true
      t.boolean :retailer , index: true
      t.column :status, UNSIGNED_NULL, index: true
      t.boolean :is_confirm, limit:1, default: 0, index: true
      t.datetime :confirm_date
      t.integer :payment_gateway
      t.text :packing_note
      t.column :admin_user_id, UNSIGNED # note_added_by
      t.datetime :note_last_updated
      t.column :invoice_no, UNSIGNED_NULL
      t.date :invoice_date      
      t.timestamps null: false
    end
    add_index :orders, [:retailer, :status, :created_at]
  end
end
