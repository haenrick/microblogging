class ProfilesController < ApplicationController
  before_action :require_authentication

  def show
    @user = User.find_by!(username: params[:username])
    @blocked = Current.user.blocking?(@user)
    @posts = @blocked ? [] : @user.posts.top_level.active.includes(:likes, replies: :user).recent
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

  private

  def profile_params
    params.require(:user).permit(:bio, :avatar)
  end
end
