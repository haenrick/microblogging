require "test_helper"

class FollowTest < ActiveSupport::TestCase
  # ── Validations ───────────────────────────────────────────────────────────
  test "cannot follow yourself" do
    user = users(:one)
    follow = Follow.new(follower: user, following: user)
    assert follow.invalid?
    assert_includes follow.errors[:follower], "can't follow yourself"
  end

  test "cannot follow same user twice" do
    follower = users(:two)
    target   = users(:one)
    follower.follows.create!(following: target)
    duplicate = Follow.new(follower: follower, following: target)
    assert duplicate.invalid?
  end

  # ── Notification callback ─────────────────────────────────────────────────
  test "creates notification for the followed user" do
    follower = users(:two)
    target   = users(:one)

    assert_difference("Notification.count", 1) do
      follower.follows.create!(following: target)
    end

    notif = target.notifications.order(:created_at).last
    assert_equal "follow", notif.notification_type
    assert_equal follower, notif.actor
    assert_equal follower, notif.notifiable
  end
end
