class SearchController < ApplicationController
  before_action :require_authentication

  def index
    @query = params[:q].to_s.strip
    if @query.length >= 2
      blocked_ids = Current.user.blocked_users.pluck(:id) + Current.user.blocked_by_users.pluck(:id)
      @users = User.where(
                     "to_tsvector('simple', coalesce(username, '') || ' ' || coalesce(bio, '')) @@ websearch_to_tsquery('simple', ?)",
                     @query
                   ).where.not(id: [Current.user.id] + blocked_ids)
                   .limit(10)
      @posts = Post.active.visible_to(Current.user)
                   .where(
                     "to_tsvector('simple', coalesce(content, '')) @@ websearch_to_tsquery('simple', ?)",
                     @query
                   ).includes(:user, :likes)
                   .with_attached_media
                   .order(created_at: :desc)
                   .limit(30)
    else
      @users = []
      @posts = []
    end
  end
end
