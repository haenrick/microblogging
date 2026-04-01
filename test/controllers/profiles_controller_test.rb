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

  test "followers page returns success" do
    sign_in_as(@user)
    get profile_followers_path(@user.username)
    assert_response :success
  end

  test "following page returns success" do
    sign_in_as(@user)
    get profile_following_path(@user.username)
    assert_response :success
  end

  test "followers page redirects when not logged in" do
    get profile_followers_path(@user.username)
    assert_redirected_to new_session_path
  end

  test "following page redirects when not logged in" do
    get profile_following_path(@user.username)
    assert_redirected_to new_session_path
  end

  # ── U3: Private Profile ────────────────────────────────────────────────────
  test "private profile hides posts from non-followers" do
    private_user = users(:two)
    private_user.update!(private_profile: true)
    sign_in_as(@user)
    get profile_path(private_user.username)
    assert_response :success
    assert_match "private", response.body
    assert_no_match "posts-feed", response.body
  end

  test "private profile shows posts to accepted followers" do
    private_user = users(:two)
    private_user.update!(private_profile: true)
    @user.follows.create!(following: private_user, status: "accepted")
    sign_in_as(@user)
    get profile_path(private_user.username)
    assert_response :success
    assert_match "posts-feed", response.body
  end

  test "owner sees their own private profile posts" do
    @user.update!(private_profile: true)
    sign_in_as(@user)
    get profile_path(@user.username)
    assert_response :success
    assert_match "posts-feed", response.body
  end

  test "private profile toggle saves via settings" do
    sign_in_as(@user)
    patch update_profile_path, params: { user: { private_profile: "1" } }
    assert @user.reload.private_profile?
  end
end
