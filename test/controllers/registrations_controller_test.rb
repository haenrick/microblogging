require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "shows registration page" do
    get new_register_path
    assert_response :success
  end

  test "creates new user" do
    assert_difference("User.count", 1) do
      post register_path, params: {
        user: {
          username: "newuser",
          email_address: "new@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to root_path
  end

  test "does not create user with duplicate username" do
    assert_no_difference("User.count") do
      post register_path, params: {
        user: {
          username: "userone",
          email_address: "other@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
  end
end
