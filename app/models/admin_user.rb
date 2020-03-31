class AdminUser < ApplicationRecord
  include Password
  include Authentication
  validates_presence_of :first_name, :last_name, :email
  validates_numericality_of :mobile
  validates_uniqueness_of :email

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def is_super_user?
    APP_CONFIG['emails']['super_user'].include? self.email
  end

  def is_system_user?
    self.email == 'care@bewakoof.com'
  end

  def condition_can_login
    self.enable == true and self.can_login == true
  end
end
