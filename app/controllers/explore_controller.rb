class ExploreController < ApplicationController
  allow_unauthenticated_access

  def index
    @posts = Post.joins(:user)
                 .where(users: { private_profile: false })
                 .where.not(users: { username: "fl4re_bot" })
                 .top_level
                 .active
                 .includes(:user, :likes)
                 .with_attached_media
                 .recent
                 .limit(30)
    @stats = {
      users: User.where.not(username: "fl4re_bot").count,
      posts: Post.count,
      expired: Post.where("expires_at <= ?", Time.current).count
    }
  end
end
