class Article < ApplicationRecord
    validates :imageUrl , presence: true
    validates :title , presence: true, length: {minimum: 6, maximum: 100}
    validates :description , presence: true, length: {minimum: 50, maximum: 200}
end