class Subscriber < ApplicationRecord
    validates :email,
            presence: true,
            format: {
              with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
              message: APP_CONFIG['error'][50],
              on: :create
            }
    validates :device_type, presence: true
  end