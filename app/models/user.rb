class User < ApplicationRecord
  THEMES = {
    "green"  => { primary: "#00ff88", dim: "#00cc6a", glow: "rgba(0,255,136,0.15)" },
    "amber"  => { primary: "#ffaa00", dim: "#cc8800", glow: "rgba(255,170,0,0.15)" },
    "purple" => { primary: "#bf5fff", dim: "#9933cc", glow: "rgba(191,95,255,0.15)" },
    "pink"   => { primary: "#ff44aa", dim: "#cc2288", glow: "rgba(255,68,170,0.15)" },
    "cyan"   => { primary: "#00e5ff", dim: "#00b8cc", glow: "rgba(0,229,255,0.15)" },
    "white"  => { primary: "#e0e0e0", dim: "#aaaaaa", glow: "rgba(224,224,224,0.15)" }
  }.freeze

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

  has_many :blocks, foreign_key: :blocker_id, dependent: :destroy
  has_many :blocked_users, through: :blocks, source: :blocked
  has_many :reverse_blocks, class_name: "Block", foreign_key: :blocked_id, dependent: :destroy
  has_many :blocked_by_users, through: :reverse_blocks, source: :blocker

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :username, presence: true, uniqueness: true,
                       format: { with: /\A[a-z0-9_]{3,30}\z/,
                                 message: "only lowercase letters, numbers and underscores (3-30 chars)" }
  validates :bio, length: { maximum: 160 }, allow_blank: true

  def following?(user)
    following.include?(user)
  end

  def blocking?(user)
    blocked_users.include?(user)
  end

  def blocked_by?(user)
    blocked_by_users.include?(user)
  end

  def avatar_thumbnail
    return unless avatar.attached?
    avatar.variant(resize_to_fill: [100, 100]).processed
  end

  def initials
    username.first(2).upcase
  end

  def theme_colors
    THEMES[theme] || THEMES["green"]
  end
end
