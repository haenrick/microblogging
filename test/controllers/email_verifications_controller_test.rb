require "test_helper"

class EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "valid token verifies email" do
    token = @user.generate_token_for(:email_verification)
    get verify_email_path(token)
    assert_redirected_to root_path
    assert_match "bestätigt", flash[:notice]
    assert @user.reload.email_verified?
  end

  test "invalid token redirects with alert" do
    get verify_email_path("invalid-token")
    assert_redirected_to root_path
    assert_match "ungültig", flash[:alert]
  end

  test "already-used token is invalid after verification" do
    token = @user.generate_token_for(:email_verification)
    @user.update!(email_verified_at: Time.current)
    get verify_email_path(token)
    assert_redirected_to root_path
    assert_match "ungültig", flash[:alert]
  end

  test "resend requires authentication" do
    post resend_email_verification_path
    assert_redirected_to new_session_path
  end

  test "resend sends mail and redirects" do
    sign_in_as(@user)
    assert_enqueued_email_with EmailVerificationMailer, :verify, args: [ @user ] do
      post resend_email_verification_path
    end
    assert_redirected_to root_path
  end
end
