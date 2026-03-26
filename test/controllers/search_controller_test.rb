require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "redirects when not logged in" do
    get search_path
    assert_redirected_to new_session_path
  end

  test "returns success when logged in" do
    sign_in_as(@user)
    get search_path
    assert_response :success
  end

  test "searches for users" do
    sign_in_as(@user)
    get search_path, params: { q: "usertwo" }
    assert_response :success
  end
end
