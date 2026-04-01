class FollowsController < ApplicationController
  before_action :require_authentication

  def create
    user = User.find_by!(username: params[:username])
    unless Current.user == user || Current.user.blocking?(user) || user.blocking?(Current.user)
      status = user.private_profile? ? "pending" : "accepted"
      Current.user.follows.create(following: user, status: status)
    end
    redirect_to profile_path(user.username)
  end

  def destroy
    user = User.find_by!(username: params[:username])
    Current.user.follows.find_by(following: user)&.destroy
    redirect_to profile_path(user.username)
  end

  def accept
    requester = User.find_by!(username: params[:username])
    follow = Current.user.pending_follow_requests.find_by!(follower: requester)
    follow.update!(status: "accepted")
    redirect_to profile_path(Current.user.username), notice: "@#{requester.username} is now following you."
  end

  def decline
    requester = User.find_by!(username: params[:username])
    follow = Current.user.pending_follow_requests.find_by!(follower: requester)
    follow.destroy
    redirect_to profile_path(Current.user.username)
  end
end
