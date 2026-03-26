class ApplicationController < ActionController::Base
  include Authentication
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :user_signed_in?

  def user_signed_in?
    Current.user.present?
  end
end
