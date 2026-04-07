require "test_helper"

class EmailVerificationMailerTest < ActionMailer::TestCase
  test "verify sends correct mail" do
    user = users(:one)
    mail = EmailVerificationMailer.verify(user)

    assert_equal "Bestätige deine E-Mail-Adresse — fl4re", mail.subject
    assert_equal [ user.email_address ], mail.to
    assert_equal [ "noreply@fl4re.datenkistchen.de" ], mail.from
    assert_match user.username, mail.body.encoded
    assert_match "verify-email", mail.body.encoded
  end
end
