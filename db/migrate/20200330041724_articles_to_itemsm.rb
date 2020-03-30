class ArticlesToItemsm < ActiveRecord::Migration[6.0]
  def change
    rename_table :articles, :items
  end
end
