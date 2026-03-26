class PostsController < ApplicationController
  before_action :require_authentication

  def index
    @tab = params[:tab] == "following" ? "following" : "all"
    base = if @tab == "following"
      Post.top_level.active.where(user: Current.user.following)
    else
      Post.top_level.active
    end
    @posts = base.includes(:user, :likes, replies: :user).recent
    @post = Post.new
  end

  def create
    @post = Current.user.posts.new(post_params)
    if @post.save
      redirect_to root_path, notice: "Post created."
    else
      @posts = Post.top_level.includes(:user, :likes, replies: :user).recent
      render :index, status: :unprocessable_entity
    end
  end

  def reply
    parent = Post.find(params[:id])
    @post = Current.user.posts.new(post_params.merge(parent: parent))
    if @post.save
      redirect_to root_path, notice: "Reply posted."
    else
      redirect_to root_path, alert: @post.errors.full_messages.to_sentence
    end
  end

  def destroy
    @post = Current.user.posts.find(params[:id])
    @post.destroy
    redirect_to root_path, notice: "Post deleted."
  end

  def like
    post = Post.find(params[:id])
    existing = post.likes.find_by(user: Current.user)
    if existing
      existing.destroy
    else
      post.likes.create(user: Current.user)
    end
    redirect_to root_path
  end

  private

  def post_params
    params.require(:post).permit(:content)
  end
end
