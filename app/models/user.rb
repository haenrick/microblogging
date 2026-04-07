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
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 100, 100 ], preprocessed: true
  end

  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :following, -> { where(follows: { status: "accepted" }) }, through: :follows, source: :following
  has_many :reverse_follows, class_name: "Follow", foreign_key: :following_id, dependent: :destroy
  has_many :followers, -> { where(follows: { status: "accepted" }) }, through: :reverse_follows, source: :follower
  has_many :pending_follow_requests, -> { where(status: "pending") },
           class_name: "Follow", foreign_key: :following_id, dependent: :destroy

  has_many :blocks, foreign_key: :blocker_id, dependent: :destroy
  has_many :blocked_users, through: :blocks, source: :blocked
  has_many :reverse_blocks, class_name: "Block", foreign_key: :blocked_id, dependent: :destroy
  has_many :blocked_by_users, through: :reverse_blocks, source: :blocker

  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_many :push_subscriptions, dependent: :destroy
  has_many :sent_messages,     class_name: "Message", foreign_key: :sender_id,    dependent: :destroy
  has_many :received_messages, class_name: "Message", foreign_key: :recipient_id, dependent: :destroy

  generates_token_for :email_verification, expires_in: 24.hours do
    email_verified_at
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :username, presence: true, uniqueness: true,
                       format: { with: /\A[a-z0-9_]{3,30}\z/,
                                 message: "only lowercase letters, numbers and underscores (3-30 chars)" }
  validates :bio, length: { maximum: 160 }, allow_blank: true

  def following?(user)
    follows.exists?(following: user, status: "accepted")
  end

  def pending_follow_request?(user)
    follows.exists?(following: user, status: "pending")
  end

  def blocking?(user)
    blocked_users.include?(user)
  end

  def blocked_by?(user)
    blocked_by_users.include?(user)
  end

  def avatar_thumbnail
    return unless avatar.attached?
    avatar.variant(:thumb).processed
  end

  def initials
    username.first(2).upcase
  end

  def theme_colors
    THEMES[theme] || THEMES["green"]
  end

  def email_verified?
    email_verified_at.present?
  end

  # Messaging permission — centralised so the rule can be changed without touching controllers/views.
  # Current rule: target must follow self (they initiated contact), and neither side blocks the other.
  def can_message?(target)
    return false if target == self
    return false if blocking?(target) || blocked_by?(target)
    target.following?(self)
  end

  def unread_messages_count
    received_messages.where(read_at: nil).count
  end

  def admin?
    admin == true
  end

  store_accessor :preferences, :enter_to_post

  def enter_to_post
    val = preferences["enter_to_post"]
    val.nil? ? true : val
  end

  def enter_to_post=(val)
    preferences["enter_to_post"] = ActiveModel::Type::Boolean.new.cast(val)
  end
end
