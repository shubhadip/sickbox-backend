class Cart < ApplicationRecord
  validates :user_id, :product_id, :quantity, presence: true
  has_many :products

  class << self
    def get_cart_details(cart)
      cartMap = {}
      product_details = []
      product_ids= []
      cart.each do |item|
        product_ids.push(item[:product_id])
      end
      byebug
      total_quantity = 0
      cart.each do |cart_product|
        cartMap[cart_product.product_id] = cart_product.quantity
        key = "p#{cart_product['product_id']}"
        cartMap[key] = cart_product.id
        total_quantity += cart_product.quantity
      end
      byebug
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
end
