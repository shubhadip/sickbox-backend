class CreateAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses, id: false do |t|
      t.column :id, INT_PRIMARY_ID
      t.column :user_id, BIGINT_UNSIGNED
      t.string :first_name, limit: 100
      t.string :last_name, limit: 100
      t.string :pincode, limit: 15
      t.string :landmark
      t.text :address
      t.string :mobile, limit: 15
      t.integer :status,
                limit: 1,
                default: 1,
                comment: '0=>disabled 1=>enabled 2=>default'
      t.string :city
      t.string :state
      t.string :country
      t.timestamps null: false
    end
    add_index :addresses, :first_name, type: :fulltext
    add_index :addresses, :last_name, type: :fulltext
  end
end
