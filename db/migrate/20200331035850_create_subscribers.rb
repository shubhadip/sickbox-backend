class CreateSubscribers < ActiveRecord::Migration[6.0]
  def change
      create_table :subscribers, id: false do |t|
        t.column :id, BIGINT_PRIMARY_ID
        t.string :email, null: false, default: '', limit: 100
        t.column :device_type, UNSIGNED, limit: 1, index: true #"0"=>"Site","1"=>"Android","2"=>"IOS"
        t.timestamps
      end
      add_index :subscribers, :email, unique: true
  end
end
