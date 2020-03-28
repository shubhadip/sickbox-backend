class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products, :id=>false do |t|
      t.column :id, INT_PRIMARY_ID
      t.string :name
      t.text :description
      t.string :url, limit:100
      t.string :meta_title
      t.text :meta_description
      t.text :meta_keywords
      t.column :designer_id, UNSIGNED_NULL
      t.float :price # Price we are offering to user
      t.float :mrp
      t.float :weight
      t.integer :rank, limit:2 
      t.integer :status, limit:1 , default:0, index: true, comment: "0=>disabled,1=>enabled,2=>Discontinued, 3=>Comming soon"
      t.integer :base_inventory, limit:1, default:0, null:false , comment: "0=>unlimited,1=>color,2=>inventory"
      t.column :color_id, UNSIGNED, index: true
      t.timestamps null: false
  end
  add_index :products, [:url], unique: true
  end
end
