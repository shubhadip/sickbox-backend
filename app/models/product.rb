class Product < ApplicationRecord
  attr_accessor :no_validate, :runtime_url_rank
  has_one_attached :avatar

  has_many :orders
  has_many :items

  enum status: [:disabled, :enabled, :discontinued, :"comming soon", :upcoming]
  validates_presence_of :name,
                        :url,
                        :status,
                        :price,
                        :mrp,
                        :weight,
                        unless: ->(product) { product.no_validate }
end
