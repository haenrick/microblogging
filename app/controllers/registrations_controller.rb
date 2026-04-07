class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user   = User.new
    @invite = params[:invite].present? ? Invite.available.find_by(token: params[:invite].upcase) : nil
  end

  def create
    @invite = params[:invite_token].present? ? Invite.available.find_by(token: params[:invite_token].upcase) : nil

    @user = User.new(registration_params)
    if @user.save
      @invite&.redeem!(@user)
      Invite.grant_to(@user)
      EmailVerificationMailer.verify(@user).deliver_later
      WelcomeJob.perform_later(@user.id)
      session = @user.sessions.create!
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true }
      redirect_to root_path, notice: "Willkommen, @#{@user.username}! Bitte bestätige deine E-Mail-Adresse."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:username, :email_address, :password, :password_confirmation)
  end
end
