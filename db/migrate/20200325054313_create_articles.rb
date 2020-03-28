class CreateArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :articles , :id=>false do |t|
      t.column :id, BIGINT_PRIMARY_ID
      t.string :title, null: false, limit: 150
      t.string :description
      t.string :imageUrl
      t.string :buttonText, limit: 50
      t.timestamps
    end
  end
end
