require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  # ── unread? ───────────────────────────────────────────────────────────────
  test "unread? is true when read_at is nil" do
    assert notifications(:like_unread).unread?
  end

  test "unread? is false when read_at is set" do
    assert_not notifications(:like_read).unread?
  end

  # ── mark_read! ────────────────────────────────────────────────────────────
  test "mark_read! sets read_at" do
    notif = notifications(:like_unread)
    assert_nil notif.read_at
    notif.mark_read!
    assert_not_nil notif.reload.read_at
  end

  test "mark_read! is idempotent" do
    notif = notifications(:like_read)
    original_read_at = notif.read_at
    notif.mark_read!
    assert_equal original_read_at, notif.reload.read_at
  end

  # ── scopes ────────────────────────────────────────────────────────────────
  test "unread scope excludes read notifications" do
    user = users(:one)
    assert_includes user.notifications.unread, notifications(:like_unread)
    assert_not_includes user.notifications.unread, notifications(:like_read)
  end

  # ── message ───────────────────────────────────────────────────────────────
  test "message for like" do
    notif = notifications(:like_unread)
    assert_equal "@#{notif.actor.username} liked your post", notif.message
  end

  test "message for follow" do
    notif = notifications(:follow_unread)
    assert_equal "@#{notif.actor.username} followed you", notif.message
  end

  test "message for reply" do
    author  = users(:one)
    replier = users(:two)
    post    = posts(:one)
    notif = Notification.create!(
      recipient: author, actor: replier,
      notifiable: post, notification_type: "reply"
    )
    assert_equal "@#{replier.username} replied to your post", notif.message
  end

  # ── path ──────────────────────────────────────────────────────────────────
  test "path for like points to post" do
    notif = notifications(:like_unread)
    assert_match %r{/posts/}, notif.path
  end

  test "path for follow points to actor profile" do
    notif = notifications(:follow_unread)
    assert_match notif.actor.username, notif.path
  end

  # ── mention ───────────────────────────────────────────────────────────────
  test "message for mention" do
    actor = users(:two)
    recipient = users(:one)
    notif = Notification.create!(
      recipient: recipient, actor: actor,
      notifiable: posts(:one), notification_type: "mention"
    )
    assert_equal "@#{actor.username} mentioned you", notif.message
  end

  test "path for mention points to post" do
    actor = users(:two)
    recipient = users(:one)
    notif = Notification.create!(
      recipient: recipient, actor: actor,
      notifiable: posts(:one), notification_type: "mention"
    )
    assert_match %r{/posts/}, notif.path
  end
end
