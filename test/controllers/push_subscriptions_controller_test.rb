require "test_helper"

class PushSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:two) }

  test "create redirects when not logged in" do
    post push_subscriptions_path, params: { endpoint: "https://x.com/p", p256dh: "k", auth: "a" }
    assert_redirected_to new_session_path
  end

  test "create saves new subscription" do
    sign_in_as(@user)
    assert_difference("PushSubscription.count", 1) do
      post push_subscriptions_path,
        params: { endpoint: "https://push.example.com/new", p256dh: "pubkey", auth: "authkey" }
    end
    assert_response :created
  end

  test "create updates existing subscription with same endpoint" do
    sign_in_as(@user)
    endpoint = "https://push.example.com/existing"
    @user.push_subscriptions.create!(endpoint: endpoint, p256dh_key: "old", auth_key: "old")

    assert_no_difference("PushSubscription.count") do
      post push_subscriptions_path,
        params: { endpoint: endpoint, p256dh: "new_key", auth: "new_auth" }
    end
    assert_equal "new_key", @user.push_subscriptions.find_by(endpoint: endpoint).p256dh_key
  end

  test "destroy removes subscription by id" do
    sign_in_as(@user)
    sub = @user.push_subscriptions.create!(
      endpoint: "https://push.example.com/to-delete",
      p256dh_key: "k", auth_key: "a"
    )
    assert_difference("PushSubscription.count", -1) do
      delete push_subscription_path(sub.id)
    end
    assert_response :no_content
  end
end
