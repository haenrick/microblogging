class SearchController < ApplicationController
  before_action :require_authentication

  def index
    @query = params[:q].to_s.strip
    if @query.length >= 2
      @users = User.where("username ILIKE ?", "%#{@query}%").limit(10)
      @posts = Post.where("content ILIKE ?", "%#{@query}%")
                   .includes(:user, :likes)
                   .order(created_at: :desc)
                   .limit(30)
    else
      @users = []
      @posts = []
    end
  end
end
