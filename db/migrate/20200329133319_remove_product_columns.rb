class RemoveProductColumns < ActiveRecord::Migration[6.0]
  def change
    remove_column :products, :base_inventory
    remove_column :products, :color_id
    remove_column :products, :designer_id
  end
end
