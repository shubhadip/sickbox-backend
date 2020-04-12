class AddGstToOrderProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :order_products, :igst_amount, :decimal, precision: 10, scale: 2, default: 0
    add_column :order_products, :igst_percentage, :decimal, precision: 10, scale: 2, default: 0
    add_column :order_products, :cgst_amount, :decimal, precision: 10, scale: 2, default: 0
    add_column :order_products, :cgst_percentage, :decimal, precision: 10, scale: 2, default: 0
    add_column :order_products, :sgst_amount, :decimal, precision: 10, scale: 2, default: 0
    add_column :order_products, :sgst_percentage, :decimal, precision: 10, scale: 2, default: 0
  end
end
