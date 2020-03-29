class User < ApplicationRecord
    include Password
    include Authentication
    has_many :addresses
    has_many :orders
    has_one :admin_user, foreign_key: :email, primary_key: :email
    #validation
    validates_presence_of :first_name, :last_name, :email, if: lambda {|user| !user.no_validate}, on: :create
    validates_presence_of :mobile, if: lambda {|user| (user.facebook_id.blank? && user.google_id.blank?)}, on: :create
    validates_uniqueness_of :email, if: lambda{ |user| user.email_changed?}
    validates_uniqueness_of :mobile, if: lambda{ |user| user.mobile_changed?} , :message => APP_CONFIG["error"][45]
    validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: APP_CONFIG["error"][50], on: :create }
    validate :freeze_email, on: :update
    before_save :strip_whitespace
    before_validation { |user| user.email.downcase! }
    before_validation :set_status,  on: :create, if: lambda {|user| user.status.blank? }
    after_save :update_redis_token, if: lambda {|user| user.token.present? }
    before_validation :set_is_verified, if: lambda {|user| user.mobile_changed?}

    has_many :order_products,through: :orders, source: :order_products
    #enum
    enum status: [:inactive, :active, :verified, :affiliate, :marketing]
    enum gender: [:female, :male]
    enum device_type: [:desktop, :mobile_site, :android, :ios]
    enum blacklist_user: [:disabled, :enabled]

    attr_accessor :token

    def update_redis_token
        expire_time = APP_CONFIG['session_expiry']["desktop"]
        set_redis_session(token, expire_time)
      end
  
      def freeze_email
        errors.add(:email, "cannot be Modifed") if self.email_changed? and (self.email_was.casecmp(self.email).zero? )
      end
      def name
        "#{self.first_name} #{self.last_name}"
      end
  
      def mobile_10digit
        "#{self.mobile.last(10)}" rescue ""
      end
  
      def set_status
      self.status = 1
      end
  
      def condition_can_login
        !self.inactive?
      end
  
      def set_is_verified
        self.is_verified = 0
      end

      def strip_whitespace
        self.first_name = self.first_name.strip unless self.first_name.nil?
        self.last_name = self.last_name.strip unless self.last_name.nil?
        self.email = self.email.strip unless self.email.nil?
      end

      def self.get_user(email, mobile)
        email = email.downcase
        user = User.find_by(email: email.downcase)
        if !user.present? and mobile.present?
          user = User.find_by(mobile: mobile)
        end
        user
      end
  
      def self.external(params, version=0)
        byebug
        response = {}
        access_type = ""
        channel = (params["mobile"].present? && 'mobile') || 'email'
        byebug
        if params[:facebook_id].present?
          response = ExternalApi::Authentication::Facebook.new(params[:facebook_id]).get_response
          channel = 'facebook'
        end
        byebug
        if params[:google_id].present?
          response = ExternalApi::Authentication::Google.new(params[:google_id]).get_response
          channel = 'gmail'
        end
        byebug
        email = response["email"] || params["email"]
        status = response["email"].present? ? true : false
        mobile = params["mobile"]
        byebug
        if !email.present? and params[:facebook_id].present?
          user = User.find_by(facebook_id: response["facebook_id"])
          if user.present?
            status = true
            email = user.email
          else
            response["facebook_id"] = params["facebook_id"]
            return {"user": response.merge!({"nologin":"No Email Id linked to your Facebook Account!"}), "access_type": access_type}
          end
        elsif params[:facebook_id].present? and params[:email].present?
          user = User.find_by(facebook_id: response["facebook_id"])
          status = true
        end
        byebug
        user = User.get_user(email, mobile) unless params[:facebook_id].present? && params[:email].present?
        response.delete("gender") if response.present? && response["gender"].present? && User.genders.keys.exclude?(response["gender"].downcase)
        byebug
        if user.present?
          if (!response.present?)
            user.errors.add(:email, APP_CONFIG["error"][43]) if user.email === email
            user.errors.add(:mobile, APP_CONFIG["error"][52]) if user.mobile === mobile
            return {"user": user, "access_type": access_type}
          end
          byebug
          response.delete("gender") if !user.gender.nil?
          user.update(response)
          access_type = "login"
        else
            byebug
          params.merge!(response)
          user = User.create(params)
          access_type = "signup"
          byebug
        #   begin
        #     byebug
        #     
        #     byebug
        #   rescue Exception => e
        #     if e.is_a? ActiveRecord::RecordNotUnique
        #       user = User.get_user(email, mobile)
        #     end
        #   end
        end
        byebug
        user.authenticate(params.merge!({status: status, device:params[:device_type]}))
        final_hash = {"user": user, "access_type": access_type, 'channel': channel }
      end
end