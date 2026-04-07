class EmailVerificationMailer < ApplicationMailer
  def verify(user)
    @user  = user
    @token = user.generate_token_for(:email_verification)
    mail subject: "Bestätige deine E-Mail-Adresse — fl4re", to: user.email_address
  end
end
