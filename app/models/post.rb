class Post < ApplicationRecord
  EXPIRY_DAYS = 30

  belongs_to :user
  belongs_to :parent, class_name: "Post", optional: true
  has_many :replies, class_name: "Post", foreign_key: :parent_id, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_by_users, through: :likes, source: :user

  validates :content, presence: true, length: { maximum: 280 }

  before_create :set_expiry

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

  private

  def set_expiry
    self.expires_at ||= EXPIRY_DAYS.days.from_now
  end
end
