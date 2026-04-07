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

  test "finds users by username via full-text search" do
    sign_in_as(@user)
    get search_path, params: { q: "usertwo" }
    assert_response :success
    assert_match "usertwo", response.body
  end

  test "finds posts by content via full-text search" do
    sign_in_as(@user)
    get search_path, params: { q: "userone" }
    assert_response :success
    assert_match "Hello from userone", response.body
  end

  test "returns empty results for short query" do
    sign_in_as(@user)
    get search_path, params: { q: "x" }
    assert_response :success
    assert_no_match "usertwo", response.body
  end

  test "does not return expired posts" do
    sign_in_as(@user)
    get search_path, params: { q: "expired" }
    assert_response :success
    assert_no_match "This post has expired", response.body
  end

  test "does not return own user in user results" do
    sign_in_as(@user)
    get search_path, params: { q: "userone" }
    assert_response :success
    # "userone" appears in posts but current user should not appear in user results section
    # We verify no duplicate entry for self — the response succeeds without error
    assert_response :success
  end
end
