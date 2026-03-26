require "test_helper"

class DiscoverControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "redirects when not logged in" do
    get discover_path
    assert_redirected_to new_session_path
  end

  test "returns success when logged in" do
    sign_in_as(@user)
    get discover_path
    assert_response :success
  end
end
