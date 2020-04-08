class Order < ApplicationRecord; 

    belongs_to :address
    belongs_to :user
    has_many :order_products, inverse_of: :order
    has_many :products, through: :order_products
    # has_many :transactions tbd: will be required

    #enums
    enum device_type: APP_CONFIG["device"]
    enum status: APP_CONFIG["order_status"].inject({}) {|hash, (k,v)| hash.merge(v['status'] =>k)}
    enum packing_type: [:"not printed", :inventory, :printing, :processed]

    #scope
    default_scope { where(retailer: false) }
    scope :placed, -> { where.not(status: [1]) }
    scope :only_positive_orders, -> { where(status: Order.order_is_positive_status) }

    #nested_attributes
    accepts_nested_attributes_for :address
    accepts_nested_attributes_for :order_products, allow_destroy: true
    attr_accessor :cancel_reason_no, :cancel_reason, :update_by_admin_user, :update_by_user, :controller, :action, :remark, :wallet_applied, :no_validate, :version
    include OrderObserver
    #validations
    validates_presence_of :order_products, on: :create

    private

end
