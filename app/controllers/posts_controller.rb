class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[show]
  before_action :require_authentication, except: %i[show]
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
    contents = params[:thread_contents].presence
    if contents.is_a?(Array) && contents.length > 1
      # Thread: create chain of posts
      first = nil
      parent = nil
      ActiveRecord::Base.transaction do
        contents.each_with_index do |text, i|
          p = Current.user.posts.create!(
            content: text.strip,
            parent:  parent,
            expires_at: Post::EXPIRY_DAYS.days.from_now
          )
          first ||= p
          parent = p
        end
      end
      redirect_to root_path, notice: "Thread gepostet."
    else
      @post = Current.user.posts.new(post_params)
      if @post.save
        redirect_to root_path, notice: "Post created."
      else
        @posts = Post.top_level.includes(:user, :likes, replies: :user).with_attached_media.recent
        render :index, status: :unprocessable_entity
      end
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

  def boost
    post = Post.find_by!(public_id: params[:id])
    existing = post.reposts.find_by(user: Current.user)
    if existing
      existing.destroy
    else
      post.reposts.create!(user: Current.user)
    end
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          ActionView::RecordIdentifier.dom_id(post, :actions),
          partial: "posts/post_actions",
          locals: { post: post.reload }
        )
      end
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def bookmark
    post = Post.find_by!(public_id: params[:id])
    existing = post.bookmarks.find_by(user: Current.user)
    if existing
      existing.destroy
    else
      post.bookmarks.create!(user: Current.user)
    end
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          ActionView::RecordIdentifier.dom_id(post, :actions),
          partial: "posts/post_actions",
          locals: { post: post.reload }
        )
      end
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def vote
    post   = Post.find_by!(public_id: params[:id])
    option = post.poll_options.find(params[:poll_option_id])
    existing_vote = post.user_vote(Current.user)
    if existing_vote
      existing_vote.destroy
      option.poll_votes.create!(user: Current.user) unless existing_vote.poll_option_id == option.id
    else
      option.poll_votes.create!(user: Current.user)
    end
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          ActionView::RecordIdentifier.dom_id(post, :poll),
          partial: "posts/poll",
          locals: { post: post.reload }
        )
      end
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def like
    post = Post.find_by!(public_id: params[:id])
    existing = post.likes.find_by(user: Current.user)
    begin
      if existing
        existing.destroy
      else
        post.likes.create(user: Current.user)
      end
    rescue ActiveRecord::RecordNotUnique
      # concurrent double-tap (e.g. Safari) — already liked, proceed gracefully
    end
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          ActionView::RecordIdentifier.dom_id(post, :actions),
          partial: "posts/post_actions",
          locals: { post: post.reload }
        )
      end
      format.html { redirect_back fallback_location: root_path }
    end
  end

  private

  def post_params
    params.require(:post).permit(:content, :media, poll_options_attributes: [:text, :position])
  end
end
