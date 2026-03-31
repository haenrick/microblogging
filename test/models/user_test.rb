require "test_helper"

class UserTest < ActiveSupport::TestCase
  # ── Email normalization ───────────────────────────────────────────────────
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal "downcased@example.com", user.email_address
  end

  # ── Username validation ───────────────────────────────────────────────────
  test "username with uppercase is invalid" do
    user = users(:two).dup
    user.email_address = "x@example.com"
    user.username = "HasUppercase"
    assert user.invalid?
  end

  test "username shorter than 3 chars is invalid" do
    user = users(:two).dup
    user.email_address = "x@example.com"
    user.username = "ab"
    assert user.invalid?
  end

  test "duplicate username is invalid" do
    user = User.new(email_address: "x@example.com", username: users(:one).username, password: "secret")
    assert user.invalid?
    assert_includes user.errors[:username], "has already been taken"
  end

  test "valid username passes" do
    user = users(:two).dup
    user.email_address = "valid@example.com"
    user.username = "valid_u1"
    assert user.valid?
  end

  # ── admin? ────────────────────────────────────────────────────────────────
  test "admin? is true for admin" do
    assert users(:one).admin?
  end

  test "admin? is false for regular user" do
    assert_not users(:two).admin?
  end

  # ── following? ────────────────────────────────────────────────────────────
  test "following? returns true after follow" do
    users(:two).follows.create!(following: users(:one))
    assert users(:two).following?(users(:one))
  end

  test "following? returns false when not following" do
    assert_not users(:two).following?(users(:three))
  end

  # ── blocking? ─────────────────────────────────────────────────────────────
  test "blocking? returns true after block" do
    users(:one).blocks.create!(blocked: users(:two))
    assert users(:one).blocking?(users(:two))
  end

  test "blocking? returns false when not blocked" do
    assert_not users(:one).blocking?(users(:three))
  end

  # ── dependent destroy ─────────────────────────────────────────────────────
  test "destroying user removes their notifications" do
    user = users(:one)
    count = user.notifications.count
    assert count > 0
    assert_difference("Notification.count", -count) { user.destroy }
  end
end
