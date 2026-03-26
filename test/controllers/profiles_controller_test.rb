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

  test "change password with correct current password" do
    sign_in_as(@user)
    patch change_password_path, params: {
      current_password: "password",
      password: "newpassword123",
      password_confirmation: "newpassword123"
    }
    assert_redirected_to edit_profile_path
    assert @user.reload.authenticate("newpassword123")
  end

  test "change password fails with wrong current password" do
    sign_in_as(@user)
    patch change_password_path, params: {
      current_password: "wrongpassword",
      password: "newpassword123",
      password_confirmation: "newpassword123"
    }
    assert_redirected_to edit_profile_path
    assert_nil flash[:notice]
  end

  test "delete account with correct password" do
    sign_in_as(@user)
    assert_difference("User.count", -1) do
      delete delete_account_path, params: { password: "password" }
    end
    assert_redirected_to new_session_path
  end

  test "delete account fails with wrong password" do
    sign_in_as(@user)
    assert_no_difference("User.count") do
      delete delete_account_path, params: { password: "wrongpassword" }
    end
    assert_redirected_to edit_profile_path
  end
end
