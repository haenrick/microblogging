class Admin::AuditLogsController < Admin::BaseController
  def index
    @audit_logs = AuditLog.includes(:admin).order(created_at: :desc).limit(200)
  end
end
