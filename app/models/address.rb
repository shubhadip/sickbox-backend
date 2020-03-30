class Address < ApplicationRecord
    belongs_to :user
    has_many :orders
    #enums
    enum status: [:disabled, :enabled, :default]
    enum sub_type: {home: 1, office: 2, college: 3, other: 0}
    #scope
    scope :active, -> { where.not(status: [0]) }
    validates_presence_of :first_name, :last_name, :address, :pincode, :mobile, :city, :state
    validates :alternate_mobile, length: { is: 10 }, if: lambda { |address| address.alternate_mobile.present? and address.alternate_mobile_changed? }
    #callbacks
    after_update :update_status, if: lambda {|address| address.status_changed? and address.status == "default" }
    before_save :check_address
  
    def full_address
      "#{first_name} #{last_name} <br/> #{address} <br/> #{landmark} <br/> #{city}-#{pincode} <br/> #{state} <br/> #{country}"
    end
  
    def validate_mobile
      unless /^[1-9]{1}[0-9]{9}$/ === self.mobile
        error = "Incorrect Mobile Number in selected address"
      end
    end
  
    def validate_name
      first_name_length = first_name.try(:length).to_i
      last_name_length = last_name.try(:length).to_i
      invalid_full_name = (first_name + last_name).downcase =~/[^a-z\s]/
      if invalid_full_name.present?
        error = "Only letters (a-z, A-Z) allowed in name."
      elsif first_name_length + last_name_length > 70
        error = "Name is too long"
      end
    end

    def update_status
      Address.active.where(user_id: self.user_id).where.not(id: self.id).update_all({status: 1})
    end

    def full_name
      "#{first_name} #{last_name}"
    end
    def state_code
      STATIC_CONFIG['state_code_list'][state.downcase]
    end
    def check_address
      self.address = address.gsub("\"","")
      self.pincode = pincode.strip
    end

  end
