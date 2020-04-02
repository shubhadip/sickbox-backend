class GuestCart < ApplicationRecord
  validates :token_id, :product_id, :quantity, presence: true
  validate :check_cart_product, on: :create

  attr_accessor :current_user, :action

  private 

  def check_cart_product
    data = GuestCart.where('token_id in (?) and product_id in (?)', self.token_id, self.product_id)
    if data.present?
        errors.add(:product_id, 'Product Already In Cart')
    end
  end
end
