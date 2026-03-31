require "test_helper"

class LikeTest < ActiveSupport::TestCase
  # ── Validations ───────────────────────────────────────────────────────────
  test "cannot like same post twice" do
    # fixture two_likes_post_one already created this like
    duplicate = Like.new(user: users(:two), post: posts(:one))
    assert duplicate.invalid?
  end

  # ── Notification callback ─────────────────────────────────────────────────
  test "creates notification for post author when liked" do
    liker  = users(:three)   # three hasn't liked post one yet
    author = users(:one)
    post   = posts(:one)

    assert_difference("Notification.count", 1) do
      liker.likes.create!(post: post)
    end

    notif = author.notifications.order(:created_at).last
    assert_equal "like", notif.notification_type
    assert_equal liker, notif.actor
    assert_equal post, notif.notifiable
  end

  test "does not notify when liking own post" do
    assert_no_difference("Notification.count") do
      users(:one).likes.create!(post: posts(:one))
    end
  end
end
