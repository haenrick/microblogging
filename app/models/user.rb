class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :username, presence: true, uniqueness: true,
                       format: { with: /\A[a-z0-9_]{3,30}\z/,
                                 message: "only lowercase letters, numbers and underscores (3-30 chars)" }
end
