class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true, touch: true

  validates :user_id, uniqueness: { scope: :post_id }

  after_create_commit :notify_post_author

  private

  def notify_post_author
    return if user_id == post.user_id
    Notification.create!(
      recipient: post.user,
      actor: user,
      notifiable: post,
      notification_type: "like"
    )
  end
end
