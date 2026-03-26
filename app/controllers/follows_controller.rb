class FollowsController < ApplicationController
  before_action :require_authentication

  def create
    user = User.find_by!(username: params[:username])
    Current.user.follows.create(following: user) unless Current.user == user
    redirect_to profile_path(user.username)
  end

  def destroy
    user = User.find_by!(username: params[:username])
    Current.user.follows.find_by(following: user)&.destroy
    redirect_to profile_path(user.username)
  end
end
