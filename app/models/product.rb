class Product < ApplicationRecord
  include Rails.application.routes.url_helpers
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


    def imageUrl
      if Rails.env.development?
        return rails_blob_path(self.avatar, only_path: true)
      end
    end
end
