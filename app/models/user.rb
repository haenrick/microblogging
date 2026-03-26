class User < ApplicationRecord
  has_secure_password validations: true
  has_many :sessions, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post
  has_one_attached :avatar

  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :following, through: :follows, source: :following
  has_many :reverse_follows, class_name: "Follow", foreign_key: :following_id, dependent: :destroy
  has_many :followers, through: :reverse_follows, source: :follower

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :username, presence: true, uniqueness: true,
                       format: { with: /\A[a-z0-9_]{3,30}\z/,
                                 message: "only lowercase letters, numbers and underscores (3-30 chars)" }
  validates :bio, length: { maximum: 160 }, allow_blank: true

  def following?(user)
    following.include?(user)
  end

  def avatar_thumbnail
    return unless avatar.attached?
    avatar.variant(resize_to_fill: [100, 100]).processed
  end

  def initials
    username.first(2).upcase
  end
end
