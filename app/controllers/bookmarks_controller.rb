class BookmarksController < ApplicationController
  def index
    @posts = Current.user.bookmarked_posts
                    .active
                    .includes(:user, :likes, :poll_options, replies: :user)
                    .with_attached_media
                    .order("bookmarks.created_at DESC")
  end
end
