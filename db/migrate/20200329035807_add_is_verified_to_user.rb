class AddIsVerifiedToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_verified, :integer, limit: 1, default: 0
  end
end
