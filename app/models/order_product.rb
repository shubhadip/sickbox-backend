class OrderProduct < ApplicationRecord
    belongs_to :order
    belongs_to :product
    validates :product_id, :quantity, presence: true
    before_save :add_price

    private

    def add_price
        if self.price.blank? && self.id.blank?
            self.price = Product.find(self.product_id).price
        end
    end

end
  