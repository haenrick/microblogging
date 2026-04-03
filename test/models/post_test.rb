require "test_helper"

class PostTest < ActiveSupport::TestCase
  # ── Validations ───────────────────────────────────────────────────────────
  test "valid post saves" do
    post = users(:one).posts.build(content: "Hello", public_id: "abc", expires_at: 30.days.from_now)
    assert post.valid?
  end

  test "content is required" do
    post = users(:one).posts.build(content: "", public_id: "abc", expires_at: 30.days.from_now)
    assert post.invalid?
    assert_includes post.errors[:content], "can't be blank"
  end

  test "content over 280 chars is invalid" do
    post = users(:one).posts.build(content: "x" * 281, public_id: "abc", expires_at: 30.days.from_now)
    assert post.invalid?
  end

  # ── to_param ──────────────────────────────────────────────────────────────
  test "to_param returns public_id" do
    assert_equal "abc123de", posts(:one).to_param
  end

  # ── expiry_status ─────────────────────────────────────────────────────────
  test "expiry_status is :fresh when more than 7 days left" do
    post = posts(:one)
    post.expires_at = 10.days.from_now
    assert_equal :fresh, post.expiry_status
  end

  test "expiry_status is :aging between 2 and 7 days" do
    post = posts(:one)
    post.expires_at = 4.days.from_now
    assert_equal :aging, post.expiry_status
  end

  test "expiry_status is :critical under 2 days" do
    post = posts(:one)
    post.expires_at = 1.day.from_now
    assert_equal :critical, post.expiry_status
  end

  # ── scopes ────────────────────────────────────────────────────────────────
  test "top_level excludes replies" do
    assert_not Post.top_level.include?(posts(:reply_from_two))
    assert Post.top_level.include?(posts(:one))
  end

  test "active excludes expired posts" do
    assert_not Post.active.include?(posts(:expired))
    assert Post.active.include?(posts(:one))
  end

  # ── reply notification callback ───────────────────────────────────────────
  test "reply creates notification for parent post author" do
    author = users(:one)
    replier = users(:two)
    parent = posts(:one)

    assert_difference("Notification.count", 1) do
      replier.posts.create!(
        content: "a reply",
        parent: parent,
        public_id: SecureRandom.urlsafe_base64(8),
        expires_at: 30.days.from_now
      )
    end

    notif = author.notifications.order(:created_at).last
    assert_equal "reply", notif.notification_type
    assert_equal replier, notif.actor
  end

  test "reply does not notify when author replies to own post" do
    author = users(:one)
    parent = posts(:one)

    assert_no_difference("Notification.count") do
      author.posts.create!(
        content: "self reply",
        parent: parent,
        public_id: SecureRandom.urlsafe_base64(8),
        expires_at: 30.days.from_now
      )
    end
  end

  # ── mention notifications ─────────────────────────────────────────────────
  test "mention creates notification for mentioned user" do
    poster   = users(:one)
    mentioned = users(:two)

    assert_difference("Notification.count", 1) do
      poster.posts.create!(
        content: "hey @#{mentioned.username} check this out",
        public_id: SecureRandom.urlsafe_base64(8),
        expires_at: 30.days.from_now
      )
    end

    notif = mentioned.notifications.order(:created_at).last
    assert_equal "mention", notif.notification_type
    assert_equal poster, notif.actor
  end

  test "mention does not notify the poster themselves" do
    poster = users(:one)

    assert_no_difference("Notification.count") do
      poster.posts.create!(
        content: "talking to myself @#{poster.username}",
        public_id: SecureRandom.urlsafe_base64(8),
        expires_at: 30.days.from_now
      )
    end
  end

  test "mention does not notify unknown usernames" do
    poster = users(:one)

    assert_no_difference("Notification.count") do
      poster.posts.create!(
        content: "hey @doesnotexist",
        public_id: SecureRandom.urlsafe_base64(8),
        expires_at: 30.days.from_now
      )
    end
  end

  test "mention in reply does not double-notify parent author" do
    replier = users(:two)
    parent  = posts(:one)
    author  = users(:one)

    assert_difference("Notification.count", 1) do
      replier.posts.create!(
        content: "replying and mentioning @#{author.username}",
        parent: parent,
        public_id: SecureRandom.urlsafe_base64(8),
        expires_at: 30.days.from_now
      )
    end

    types = author.notifications.order(:created_at).last(2).map(&:notification_type)
    assert_includes types, "reply"
    assert_not_includes types, "mention"
  end

  # ── link_preview ──────────────────────────────────────────────────────────
  test "link_preview is nil by default" do
    post = posts(:one)
    assert_nil post.link_preview
  end
end
