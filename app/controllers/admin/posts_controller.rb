class Admin::PostsController < Admin::BaseController
  def index
    @posts = Post.includes(:user)
                 .order(created_at: :desc)
                 .limit(100)
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy
    redirect_to admin_posts_path, notice: "Post deleted."
  end
end
