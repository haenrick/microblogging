class NotificationsController < ApplicationController
  def index
    @notifications = Current.user.notifications.recent.includes(:actor, :notifiable)
    Current.user.notifications.unread.update_all(read_at: Time.current)
  end

  def destroy_all
    Current.user.notifications.destroy_all
    redirect_to notifications_path, notice: "all notifications cleared"
  end
end
