class GuestCart < ApplicationRecord
  validates :token_id, :product_id, :quantity, presence: true
end
