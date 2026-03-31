require "test_helper"
require "ostruct"

class SendPushNotificationJobTest < ActiveJob::TestCase
  setup do
    @notification = notifications(:like_unread)
    @recipient    = @notification.recipient
    @subscription = push_subscriptions(:one_sub)
  end

  test "sends push to all recipient subscriptions" do
    calls = 0
    stub_method(WebPush, :payload_send, ->(*_a, **_k) { calls += 1 }) do
      SendPushNotificationJob.perform_now(@notification.id)
    end
    assert_equal 1, calls
  end

  test "skips send when recipient has no subscriptions" do
    @recipient.push_subscriptions.delete_all
    calls = 0
    stub_method(WebPush, :payload_send, ->(*_a, **_k) { calls += 1 }) do
      SendPushNotificationJob.perform_now(@notification.id)
    end
    assert_equal 0, calls
  end

  test "does nothing when notification does not exist" do
    calls = 0
    stub_method(WebPush, :payload_send, ->(*_a, **_k) { calls += 1 }) do
      SendPushNotificationJob.perform_now(-1)
    end
    assert_equal 0, calls
  end

  test "removes expired subscription and continues without raising" do
    expired_stub = ->(*_a, **_k) {
      raise WebPush::ExpiredSubscription.new(
        OpenStruct.new(code: "410", message: "Gone"), "Gone"
      )
    }
    stub_method(WebPush, :payload_send, expired_stub) do
      assert_difference("PushSubscription.count", -1) do
        SendPushNotificationJob.perform_now(@notification.id)
      end
    end
  end
end
