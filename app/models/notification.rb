class Notification < ApplicationRecord
  TYPES = %w[like follow reply mention].freeze

  belongs_to :recipient, class_name: "User"
  belongs_to :actor,     class_name: "User"
  belongs_to :notifiable, polymorphic: true

  validates :notification_type, inclusion: { in: TYPES }

  scope :unread,  -> { where(read_at: nil) }
  scope :recent,  -> { order(created_at: :desc) }

  after_create_commit :broadcast_badge
  after_create_commit :enqueue_push

  def unread?
    read_at.nil?
  end

  def mark_read!
    update!(read_at: Time.current) if unread?
  end

  def message
    case notification_type
    when "like"    then "@#{actor.username} liked your post"
    when "follow"  then "@#{actor.username} followed you"
    when "reply"   then "@#{actor.username} replied to your post"
    when "mention" then "@#{actor.username} mentioned you"
    end
  end

  def path
    case notification_type
    when "like", "reply", "mention" then Rails.application.routes.url_helpers.post_path(notifiable)
    when "follow"                   then Rails.application.routes.url_helpers.profile_path(actor.username)
    end
  end

  private

  def enqueue_push
    SendPushNotificationJob.perform_later(id)
  end

  def broadcast_badge
    broadcast_replace_to(
      "notifications_#{recipient_id}",
      target: "notification_badge",
      partial: "notifications/badge",
      locals: { unread_count: recipient.notifications.unread.count }
    )
  end
end
