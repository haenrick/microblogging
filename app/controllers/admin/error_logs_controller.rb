class Admin::ErrorLogsController < Admin::BaseController
  def index
    @error_groups = ErrorLog.grouped
    @total        = ErrorLog.count
  end

  def show
    @fingerprint  = params[:fingerprint]
    @sample       = ErrorLog.where(fingerprint: @fingerprint).order(created_at: :desc).first
    @occurrences  = ErrorLog.where(fingerprint: @fingerprint).order(created_at: :desc).limit(25)
    redirect_to admin_error_logs_path, alert: "Nicht gefunden." unless @sample
  end

  def destroy
    ErrorLog.where(fingerprint: params[:fingerprint]).delete_all
    redirect_to admin_error_logs_path, notice: "Fehlergruppe gelöscht."
  end

  def destroy_all
    ErrorLog.delete_all
    redirect_to admin_error_logs_path, notice: "Alle Fehler gelöscht."
  end
end
