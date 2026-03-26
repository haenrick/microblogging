class PostsController < ApplicationController
  before_action :require_authentication
  rate_limit to: 20, within: 1.minute, only: %i[create reply],
             with: -> { redirect_to root_path, alert: "[!] Rate limit reached. Wait a moment." }

  def index
    @tab = params[:tab] == "following" ? "following" : "all"
    base = if @tab == "following"
      Post.top_level.active.visible_to(Current.user).where(user: Current.user.following)
    else
      Post.top_level.active.visible_to(Current.user)
    end
    @posts = base.includes(:user, :likes, replies: :user).with_attached_media.recent
    @post = Post.new
  end

  def show
    @post = Post.active.includes(:user, :likes, replies: { user: [] }).with_attached_media.find_by!(public_id: params[:id])
  end

  def create
    @post = Current.user.posts.new(post_params)
    if @post.save
      redirect_to root_path, notice: "Post created."
    else
      @posts = Post.top_level.includes(:user, :likes, replies: :user).with_attached_media.recent
      render :index, status: :unprocessable_entity
    end
  end

  def reply
    parent = Post.find_by!(public_id: params[:id])
    @post = Current.user.posts.new(post_params.merge(parent: parent))
    if @post.save
      redirect_to root_path, notice: "Reply posted."
    else
      redirect_to root_path, alert: @post.errors.full_messages.to_sentence
    end
  end

  def update
    @post = Current.user.posts.find_by!(public_id: params[:id])
    if @post.update(post_params.merge(edited_at: Time.current))
      redirect_to root_path, notice: "Post updated."
    else
      redirect_to root_path, alert: @post.errors.full_messages.to_sentence
    end
  end

  def destroy
    @post = Current.user.posts.find_by!(public_id: params[:id])
    @post.destroy
    redirect_to root_path, notice: "Post deleted."
  end

  def like
    post = Post.find_by!(public_id: params[:id])
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
    params.require(:post).permit(:content, :media)
  end
end
