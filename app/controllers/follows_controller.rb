class FollowsController < ApplicationController
  before_action :require_authentication

  def create
    user = User.find_by!(username: params[:username])
    unless Current.user == user || Current.user.blocking?(user) || user.blocking?(Current.user)
      Current.user.follows.create(following: user)
    end
    redirect_to profile_path(user.username)
  end

  def destroy
    user = User.find_by!(username: params[:username])
    Current.user.follows.find_by(following: user)&.destroy
    redirect_to profile_path(user.username)
  end
end
