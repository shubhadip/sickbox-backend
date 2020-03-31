class CreateAdminUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :admin_users, id: false do |t|
      t.column :id, INT_PRIMARY_ID
      t.string :first_name, limit: 50
      t.string :last_name, limit: 50
      t.string :email, limit: 50
      t.string :personal_email, limit: 50
      t.string :encrypted_password, null: false, default: '', limit: 70
      t.string :designation, limit: 50
      t.string :department, limit: 50
      t.boolean :enable, default: 1
      t.boolean :can_login, default: 0 ##check can this be merged with enable
      t.boolean :can_sales_login, default: 0
      # t.boolean :auth_type, default:0
      # t.boolean :auth_done, default:0
      t.column :login_attempt, UNSIGNED, default: 0
      t.string :mobile, limit: 15, default: ''
      t.string :mobile_other, limit: 15, default: ''
      ## Recoverable
      t.string :reset_password_token, limit: 10
      t.datetime :reset_password_sent_at
      ##Trackable
      t.integer :sign_in_count, default: 0, null: false, limit: 1
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip, limit: 20
      t.string :last_sign_in_ip, limit: 20
      t.timestamps null: false
    end
    add_index :admin_users, :email, unique: true
  end
end
