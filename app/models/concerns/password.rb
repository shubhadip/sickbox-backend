module Password
  extend ActiveSupport::Concern

  attr_accessor :password, :old_password, :action
  included do
    before_save :set_encrypted_password,
                if: ->(user) { user.password.present? || old_password.present? }
  end

  module ClassMethods
    def encrypt_password(password = nil)
      Digest::SHA256.hexdigest(
        Digest::MD5.hexdigest(password) +
          Rails.application.secrets.encrption_key
      )
    end
  end

  def send_password_reset
    authentication_params = { "status": true }
    data = self.authenticate(authentication_params)
    if data.present?
      reset_password_token =
        Base64.urlsafe_encode64("#{data[:token]}:#{data[:email]}")
    end
    if reset_password_token.present?
      ResetpwdMailer.reset_password(
        self.email,
        reset_password_token,
        self.class.name
      ).deliver
    end
  end

  def set_encrypted_password
    #will take user or admin_user class according to the object self is pointing to

    if self.old_password.present?
      encrpyt_old_password =
        Digest::SHA256.hexdigest(
          Digest::MD5.hexdigest(self.old_password) +
            Rails.application.secrets.encrption_key
        )

      if self.encrypted_password == encrpyt_old_password
        self.encrypted_password = classname.encrypt_password(self.password)
      else
        errors.add(:password, 'old password is incorrect')
        return false
      end
    elsif (self.password.present? and self.action == 'reset') or
          self.password.present?
      self.encrypted_password = classname.encrypt_password(self.password)
    end
  end

  private

  def classname
    Object.const_get(self.class.name)
  end
end
