class Admin::DashboardController < Admin::BaseController
  def index
    @stats = {
      users:   User.count,
      posts:   Post.count,
      likes:   Like.count,
      follows: Follow.count,
      active_posts: Post.active.count,
      expired_posts: Post.where("expires_at <= ?", Time.current).count
    }
    @recent_users = User.order(created_at: :desc).limit(5)
    @recent_posts = Post.includes(:user).order(created_at: :desc).limit(5)
  end
end
