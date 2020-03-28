class CreateUsers < ActiveRecord::Migration[6.0]
  create_table :addresses, :id=>false do |t|
    t.column :id, INT_PRIMARY_ID
    t.column :user_id, BIGINT_UNSIGNED, index: true
    t.string :first_name, limit: 100
    t.string :last_name, limit: 100
    t.string :pincode, limit: 15,index: true
    t.string :landmark
    t.text :address
    t.string :mobile, limit:15
    t.integer :status, limit:1, default: 1, comment: "0=>disabled 1=>enabled 2=>default"
    t.string :city, index: true
    t.string :state, index: true
    t.string :country, index: true
    t.timestamps null: false
  end
  add_index :addresses, :first_name, type: :fulltext
  add_index :addresses, :last_name, type: :fulltext
end
