class Post < ApplicationRecord
  EXPIRY_DAYS = 30

  belongs_to :user
  belongs_to :parent, class_name: "Post", optional: true, touch: true
  has_many :replies, class_name: "Post", foreign_key: :parent_id, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_by_users, through: :likes, source: :user
  has_one_attached :media

  ALLOWED_MEDIA_TYPES = %w[image/png image/jpeg image/gif image/webp image/jpg].freeze

  validates :content, presence: true, length: { maximum: 280 }
  validate :acceptable_media, if: -> { media.attached? }

  before_create :set_expiry, :set_public_id
  after_create_commit :notify_parent_author, if: -> { parent_id.present? }

  scope :top_level,   -> { where(parent_id: nil) }
  scope :recent,      -> { order(created_at: :desc) }
  scope :active,      -> { where("expires_at > ?", Time.current) }
  scope :visible_to,  ->(user) {
    blocked_ids = user.blocked_users.pluck(:id) + user.blocked_by_users.pluck(:id)
    blocked_ids.empty? ? all : where.not(user_id: blocked_ids)
  }

  def liked_by?(user)
    likes.exists?(user: user)
  end

  def expires_in_seconds
    return 0 unless expires_at
    [(expires_at - Time.current).to_i, 0].max
  end

  def expiry_status
    days = expires_in_seconds / 86400
    if days > 7
      :fresh     # green
    elsif days > 2
      :aging     # yellow/cyan
    else
      :critical  # red
    end
  end

  def expiry_label
    secs = expires_in_seconds
    return "expired" if secs == 0
    days  = secs / 86400
    hours = (secs % 86400) / 3600
    mins  = (secs % 3600) / 60
    if days > 0
      "#{days}d left"
    elsif hours > 0
      "#{hours}h left"
    else
      "#{mins}m left"
    end
  end

  def to_param
    public_id
  end

  private

  def notify_parent_author
    return if user_id == parent.user_id
    Notification.create!(
      recipient: parent.user,
      actor: user,
      notifiable: self,
      notification_type: "reply"
    )
  end

  def set_expiry
    self.expires_at ||= EXPIRY_DAYS.days.from_now
  end

  def set_public_id
    self.public_id ||= SecureRandom.urlsafe_base64(8)
  end

  def acceptable_media
    unless media.content_type.in?(ALLOWED_MEDIA_TYPES)
      errors.add(:media, "must be a PNG, JPEG, GIF or WebP image")
    end
    if media.byte_size > 10.megabytes
      errors.add(:media, "must be under 10 MB")
    end
  end
end
