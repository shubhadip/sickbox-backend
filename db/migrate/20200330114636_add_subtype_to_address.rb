class AddSubtypeToAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :sub_type, :integer, limit: 1, :default => 0
  end
end
