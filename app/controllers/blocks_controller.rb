class BlocksController < ApplicationController
  before_action :require_authentication

  def create
    user = User.find_by!(username: params[:username])
    unless Current.user == user
      Current.user.blocks.create(blocked: user)
      # Remove any follow relations between the two users
      Current.user.follows.find_by(following: user)&.destroy
      user.follows.find_by(following: Current.user)&.destroy
    end
    redirect_to profile_path(user.username), notice: "@#{user.username} blocked."
  end

  def destroy
    user = User.find_by!(username: params[:username])
    Current.user.blocks.find_by(blocked: user)&.destroy
    redirect_to profile_path(user.username), notice: "@#{user.username} unblocked."
  end
end
