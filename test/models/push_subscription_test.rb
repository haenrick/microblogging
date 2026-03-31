require "test_helper"

class PushSubscriptionTest < ActiveSupport::TestCase
  # ── Validations ───────────────────────────────────────────────────────────
  test "valid subscription saves" do
    sub = users(:two).push_subscriptions.build(
      endpoint: "https://push.example.com/unique",
      p256dh_key: "testkey",
      auth_key: "testauth"
    )
    assert sub.valid?
  end

  test "endpoint must be present" do
    sub = users(:one).push_subscriptions.build(endpoint: "", p256dh_key: "k", auth_key: "a")
    assert sub.invalid?
    assert_includes sub.errors[:endpoint], "can't be blank"
  end

  test "endpoint must be unique" do
    existing = push_subscriptions(:one_sub)
    dup = users(:two).push_subscriptions.build(
      endpoint: existing.endpoint, p256dh_key: "k", auth_key: "a"
    )
    assert dup.invalid?
    assert_includes dup.errors[:endpoint], "has already been taken"
  end

  # ── to_webpush_subscription ───────────────────────────────────────────────
  test "to_webpush_subscription returns correct hash structure" do
    sub = push_subscriptions(:one_sub)
    result = sub.to_webpush_subscription
    assert_equal sub.endpoint, result[:endpoint]
    assert_equal sub.p256dh_key, result[:keys][:p256dh]
    assert_equal sub.auth_key, result[:keys][:auth]
  end
end
