class EmailVerificationsController < ApplicationController
  allow_unauthenticated_access only: :show

  def show
    user = User.find_by_token_for!(:email_verification, params[:token])
    user.update!(email_verified_at: Time.current)
    redirect_to root_path, notice: "E-Mail-Adresse bestätigt. Willkommen, @#{user.username}!"
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to root_path, alert: "Der Bestätigungslink ist ungültig oder abgelaufen."
  end

  def create
    return redirect_to root_path if Current.user.email_verified?
    EmailVerificationMailer.verify(Current.user).deliver_later
    redirect_to root_path, notice: "Bestätigungs-Mail wurde erneut gesendet."
  end
end
