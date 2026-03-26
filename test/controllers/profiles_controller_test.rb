require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "show redirects when not logged in" do
    get profile_path(@user.username)
    assert_redirected_to new_session_path
  end

  test "show returns success when logged in" do
    sign_in_as(@user)
    get profile_path(@user.username)
    assert_response :success
  end

  test "edit redirects when not logged in" do
    get edit_profile_path
    assert_redirected_to new_session_path
  end

  test "edit returns success when logged in" do
    sign_in_as(@user)
    get edit_profile_path
    assert_response :success
  end

  test "update bio" do
    sign_in_as(@user)
    patch update_profile_path, params: { user: { bio: "My new bio" } }
    assert_redirected_to profile_path(@user.username)
    assert_equal "My new bio", @user.reload.bio
  end
end
