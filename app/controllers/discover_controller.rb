class DiscoverController < ApplicationController
  before_action :require_authentication

  def index
    blocked_ids = Current.user.blocked_users.pluck(:id) + Current.user.blocked_by_users.pluck(:id)
    @users = User.where.not(id: [Current.user.id] + blocked_ids)
                 .order(created_at: :desc)
  end
end
