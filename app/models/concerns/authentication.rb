module Authentication
  extend ActiveSupport::Concern
  attr_accessor :ip, :sign_in_at, :no_validate
  included do
    before_save :ip_update, if: ->(user) { user.ip.present? }
    before_save :sign_in_time_update, if: ->(user) { user.sign_in_at.present? }
  end

  module ClassMethods
    def check_inactive(user)
      if self.name.underscore == 'user'
        is_inactive = (user.status == 'inactive')
      end
      if self.name.underscore == 'admin_user'
        is_inactive = (!user.condition_can_login)
      end
      is_inactive
    end

    def generate_access_token
      token = SecureRandom.uuid.tr('-', '')
    end

    def check_redis_token(email, token, device)
      is_valid_user = false
      if email.present?
        key = "#{self.name.underscore}:#{token}"
        redis_data = $redis.hget(key, 'email')
        if redis_data.present? and email.casecmp(redis_data).zero?
          is_valid_user = true
        end
      end

      if is_valid_user
        expire_time =
          APP_CONFIG['session_expiry'][device] ||
            APP_CONFIG['session_expiry']['default']
        $redis.expire(key, expire_time) if expire_time > 0
        user_object = self.find_by(email: email)
        return false if check_inactive(user_object)
        return user_object
      else
        return false
      end
    end
  end

  def set_redis_session(token, expire_time = 0, set_on_live = false)
    key = "#{class_name_underscore}:#{token}"
    $redis.hset(key, class_name_underscore, self.id)
    $redis.hset(key, 'email', self.email)
    $redis.expire(key, expire_time) if expire_time > 0

    if set_on_live
      $redis_live.hset(key, class_name_underscore, self.id)
      $redis_live.hset(key, 'email', self.email)
      $redis_live.expire(key, expire_time) if expire_time > 0
    end
    return user_show(token)
  end

  def authenticate(authentication_params = nil)
    password = authentication_params[:password] || ''

    condition = authentication_params[:status] == true
    condition ||=
      (
        self.encrypted_password == class_object.encrypt_password(password) ||
          self.encrypted_password ==
            class_object.encrypt_password(
              Rails.application.secrets.encrption_key + password
            )
      )
    condition ||=
      (
        authentication_params[:otp_code].present? and
          verify_otp(authentication_params)
      )
    if condition and condition_can_login
      if (!authentication_params[:status])
        user_update = {
          ip: authentication_params[:ip].try(:slice),
          sign_in_at: Time.current,
          no_validate: true
        }
        self.update(user_update)
      end
      expire_time =
        APP_CONFIG['session_expiry'][authentication_params[:device]] ||
          APP_CONFIG['session_expiry']['default']

      token = class_object.generate_access_token
      session_status =
        set_redis_session(
          token,
          expire_time,
          authentication_params[:set_on_live]
        )
      return session_status
    else
      return false
    end
  end

  def user_show(token = nil)
    return @user_show if @user_show.present?
    @user_show =
      self.attributes.symbolize_keys.slice(
        :id,
        :first_name,
        :last_name,
        :gender,
        :date_of_birth,
        :email,
        :can_sales_login,
        :mobile,
        :non_promotional_wallet_amount,
        :is_verified
      )
    @user_show[:gender] =
      if @user_show[:gender].present?
        class_object.genders.invert[@user_show[:gender].to_i]
      else
        nil
      end
    @user_show[:token] = token
    @user_show
  end

  def destroy_session(token, device)
    key = "#{class_name_underscore}:#{token}"
    if $redis.del(key)
      return true
    else
      return false
    end
  end

  def ip_update
    self.current_sign_in_ip, self.last_sign_in_ip =
      self.ip, self.current_sign_in_ip_was
  end

  def sign_in_time_update
    self.current_sign_in_at, self.last_sign_in_at =
      self.sign_in_at, self.current_sign_in_at_was
  end

  def check_user_exists(params)
    if (self.mobile == params['mobile'].to_s) ||
         (!User.exists?(mobile: params['mobile']))
      return true
    else
      self.errors.add(:mobile, APP_CONFIG['error'][45])
      return false
    end
  end

  def generate_otp(params)
    key = "#{class_name_underscore}:#{params['mobile']}"
    trials = $redis.hget(key, 'tries').to_i
    if trials > 2
      self.errors.add(:OTP, APP_CONFIG['error'][46])
      return false
    else
      if (APP_CONFIG['sms']['no_otp_verification'].exclude? params['mobile'])
        resend_value = $redis.hincrby(key, 'resend', 1)
        $redis.hset(key, 'tries', 0) unless resend_value > 3
        if resend_value > 3
          self.errors.add(:OTP, APP_CONFIG['error'][46])
          return false
        elsif resend_value == 1
          otp = rand(9999).to_s.center(4, rand(9).to_s)
          $redis.hset(key, 'otp', otp)
          $redis.expire(key, 3600)
          Sidekiq::Client.push(
            'class' => QueueSendSms,
            'queue' => 'otp',
            'args' => ['otp', { 'otp' => otp }, params['mobile']]
          )
          return true
        else
          otp = $redis.hget(key, 'otp')
          Sidekiq::Client.push(
            'class' => QueueSendSms,
            'queue' => 'otp',
            'args' => ['otp', { 'otp' => otp }, params['mobile']]
          )
          return true
        end
      end
      Sidekiq::Client.push(
        'class' => QueueSendSms,
        'queue' => 'otp',
        'args' => ['otp', { 'otp' => otp }, params['mobile']]
      )
      return true
    end
  end

  def verify_otp(params)
    key = "#{class_name_underscore}:#{params['mobile']}"
    trials = $redis.hget(key, 'tries').to_i

    if trials > 2
      self.errors.add(:OTP, APP_CONFIG['error'][46])
      return false
    else
      $redis.hincrby(key, 'tries', 1)
      redis_data = $redis.hget(key, 'otp')

      if redis_data.present? and redis_data == params[:otp_code]
        self.update({ mobile: params['mobile'] })
        self.update({ is_verified: 1 }) if self.is_verified == 0
        $redis.del("#{class_name_underscore}:#{params['mobile']}")
        return true
      else
        self.errors.add(:OTP, APP_CONFIG['error'][47])
        return false
      end
    end
  end

  def check_login_attempts(login_condition)
    key = "login_#{class_name_underscore}:#{self.id}"
    login_attempt = $redis.get(key).to_i
    threshold_attempts = (class_name_underscore == 'admin_user') ? 9 : 4

    if login_attempt > threshold_attempts
      self.errors.add(:LOGIN, APP_CONFIG['error'][46])
    else
      if login_condition
        $redis.del(key) if login_attempt != 0
      else
        $redis.incr(key)
        $redis.expire(key, 14_400) if login_attempt == 0
        self.errors.add(:LOGIN, APP_CONFIG['error'][49])
      end
    end
  end

  private

  def class_object
    Object.const_get(self.class.name)
  end

  def class_name_underscore
    @class_name = @class_name || self.class.name.underscore
  end
end
