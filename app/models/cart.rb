class Cart < ApplicationRecord
    validates :user_id, :product_id, :quantity , presence: true
end