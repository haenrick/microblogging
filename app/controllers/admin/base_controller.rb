class Admin::BaseController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    redirect_to root_path, alert: "Access denied." unless Current.user&.admin?
  end

  def audit(action, target: nil, details: nil)
    AuditLog.record(admin: Current.user, action: action, target: target, details: details)
  end
end
