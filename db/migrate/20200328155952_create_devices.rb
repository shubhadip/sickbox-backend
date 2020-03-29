class CreateDevices < ActiveRecord::Migration[6.0]
  def change
    create_table :devices,  :id=>false do |t|
      t.column :id, INT_PRIMARY_ID
      t.string :device_id, limit: 20, null:false, index:true
      t.column :user_id, BIGINT_UNSIGNED_NULL,index: true
      t.datetime :sign_in_at
      t.string :registration_id, limit:500
      t.string :operators, limit:500, null:true
      t.string :model, limit:50
      t.string :manufacturer,  limit:50
      t.column :version , UNSIGNED, limit:4
      t.boolean :status, index: true #"1"=>"Active","0"=>"Uninstall"
      t.integer :device_type,  limit:1, index: true #"1"=>"Android","2"=>"IOS"
      t.timestamps null: false
    end
  end
end
