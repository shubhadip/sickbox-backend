class AddProductToArticle < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :product_id,  UNSIGNED, index: true
  end
end
