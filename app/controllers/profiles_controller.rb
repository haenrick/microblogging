class ProfilesController < ApplicationController
  before_action :require_authentication

  def show
    @user = User.find_by!(username: params[:username])
    @blocked = Current.user.blocking?(@user)
    @posts = @blocked ? [] : @user.posts.top_level.active.includes(:likes, replies: :user).with_attached_media.recent
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    if @user.update(profile_params)
      redirect_to profile_path(@user.username), notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def change_password
    @user = Current.user
    if !@user.authenticate(params[:current_password])
      redirect_to edit_profile_path, alert: "Current password is incorrect."
    elsif params[:password] != params[:password_confirmation]
      redirect_to edit_profile_path, alert: "New passwords don't match."
    elsif params[:password].length < 8
      redirect_to edit_profile_path, alert: "New password must be at least 8 characters."
    else
      @user.update!(password: params[:password])
      redirect_to edit_profile_path, notice: "Password changed."
    end
  end

  def destroy
    @user = Current.user
    if @user.authenticate(params[:password])
      @user.destroy
      redirect_to new_session_path, notice: "Account deleted."
    else
      redirect_to edit_profile_path, alert: "Wrong password — account not deleted."
    end
  end

  private

  def profile_params
    params.require(:user).permit(:bio, :avatar, :theme, :enter_to_post)
  end
end
