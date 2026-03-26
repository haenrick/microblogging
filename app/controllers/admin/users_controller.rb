class Admin::UsersController < Admin::BaseController
  def index
    @users = User.order(created_at: :desc)
                 .select("users.*, " \
                         "(SELECT COUNT(*) FROM posts WHERE posts.user_id = users.id) AS posts_count, " \
                         "(SELECT COUNT(*) FROM follows WHERE follows.follower_id = users.id) AS following_count, " \
                         "(SELECT COUNT(*) FROM follows WHERE follows.following_id = users.id) AS followers_count")
  end

  def destroy
    user = User.find(params[:id])
    if user == Current.user
      redirect_to admin_users_path, alert: "You cannot delete your own account here."
    else
      user.destroy
      redirect_to admin_users_path, notice: "@#{user.username} deleted."
    end
  end

  def toggle_admin
    user = User.find(params[:id])
    user.update!(admin: !user.admin?)
    redirect_to admin_users_path, notice: "@#{user.username} admin status updated."
  end
end
