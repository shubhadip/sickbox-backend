class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: false do |t|
      t.column :id, BIGINT_PRIMARY_ID
      t.string :first_name, limit: 100
      t.string :last_name, limit: 100
      t.integer :gender, limit: 1
      t.integer :status, limit: 1, index: true
      t.integer :device_type, limit: 1, default: 0 #"0"=>"Site","1"=>"Android","2"=>"IOS"
      t.date :date_of_birth
      t.decimal :wallet_amount, precision: 12, scale: 3, default: 0
      ##authenticatable
      t.string :facebook_id
      t.string :google_id
      t.string :email, null: false, default: '', limit: 100
      t.string :encrypted_password, null: false, default: '', limit: 70
      ##Trackable
      t.integer :sign_in_count, default: 0, null: false, limit: 1
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip, limit: 20
      t.string :last_sign_in_ip, limit: 20
      t.string :mobile, limit: 15
      t.timestamps
    end
    add_index :users, :first_name, type: :fulltext
    add_index :users, :last_name, type: :fulltext
    add_index :users, :email, unique: true
  end
end
