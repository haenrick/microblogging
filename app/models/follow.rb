class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :following, class_name: "User"

  attribute :status, :string, default: "accepted"

  validates :follower_id, uniqueness: { scope: :following_id }
  validate :no_self_follow

  scope :accepted, -> { where(status: "accepted") }
  scope :pending,  -> { where(status: "pending") }

  after_create_commit { notify_followed_user if accepted? }
  after_update_commit { notify_followed_user if saved_change_to_status?(from: "pending", to: "accepted") }

  def accepted?
    status == "accepted"
  end

  def pending?
    status == "pending"
  end

  private

  def no_self_follow
    errors.add(:follower, "can't follow yourself") if follower_id == following_id
  end

  def notify_followed_user
    Notification.create!(
      recipient: following,
      actor: follower,
      notifiable: follower,
      notification_type: "follow"
    )
  end
end
