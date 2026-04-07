class HashtagsController < ApplicationController
  def show
    @tag  = params[:tag].downcase
    @hashtag = Hashtag.find_by!(name: @tag)
    @posts = @hashtag.posts
                     .top_level
                     .active
                     .visible_to(Current.user)
                     .includes(:user, :likes, :poll_options, replies: :user)
                     .with_attached_media
                     .recent
  end
end
