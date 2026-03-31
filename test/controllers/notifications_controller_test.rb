require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "redirects when not logged in" do
    get notifications_path
    assert_redirected_to new_session_path
  end

  test "index returns success when logged in" do
    sign_in_as(@user)
    get notifications_path
    assert_response :success
  end

  test "index marks all unread notifications as read" do
    sign_in_as(@user)
    assert @user.notifications.unread.any?
    get notifications_path
    assert_equal 0, @user.notifications.reload.unread.count
  end

  test "destroy_all redirects when not logged in" do
    delete destroy_all_notifications_path
    assert_redirected_to new_session_path
  end

  test "destroy_all removes all notifications" do
    sign_in_as(@user)
    assert @user.notifications.any?
    assert_difference("Notification.count", -@user.notifications.count) do
      delete destroy_all_notifications_path
    end
    assert_redirected_to notifications_path
  end
end
