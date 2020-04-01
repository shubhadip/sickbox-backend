class Cart < ApplicationRecord
  has_many :products

  validates :user_id, :product_id, :quantity, presence: true
  validate :check_cart_product, on: :create

  class << self
    def get_cart_details(cart)
      cartMap = {}
      product_details = []
      product_ids= []
      cart.each do |item|
        product_ids.push(item[:product_id])
      end
      total_quantity = 0
      cart.each do |cart_product|
        cartMap[cart_product.product_id] = cart_product.quantity
        key = "p#{cart_product['product_id']}"
        cartMap[key] = cart_product.id
        total_quantity += cart_product.quantity
      end
      products = Product.where('id in (?)', product_ids)
      products.each do |p|
        key = "p#{p['id']}"
        temp = {}
        temp[:name] = p['name']
        temp[:meta_title] = p['meta_title']
        temp[:meta_description] = p['meta_description']
        temp[:price] = p['price']
        temp[:mrp] = p['mrp']
        temp[:url] = p['url']
        temp[:status] = p['status']
        temp[:weight] = p['weight']
        temp[:product_id] = p['id']
        temp[:selected_qty] = cartMap[p['id']]
        temp[:cart_id] = cartMap[key]
        product_details.push(temp)
      end
      return product_details, total_quantity
    end
  end

  private 

    def check_cart_product
      data = Cart.where('user_id in (?) and product_id in (?)', self.user_id, self.product_id)
      if data.present?
          errors.add(:product_id, 'Product Already In Cart')
      end
    end

end
