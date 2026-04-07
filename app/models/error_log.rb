class ErrorLog < ApplicationRecord
  belongs_to :user, optional: true

  IGNORED_CLASSES = %w[
    ActionController::RoutingError
    ActionController::UnknownFormat
    ActionController::InvalidAuthenticityToken
    ActiveRecord::RecordNotFound
  ].freeze

  def self.log(exception, request: nil, user: nil, job: nil)
    return if IGNORED_CLASSES.include?(exception.class.name)

    fingerprint = Digest::MD5.hexdigest("#{exception.class.name}:#{exception.message.to_s.first(200)}")

    attrs = {
      error_class: exception.class.name,
      message:     exception.message.to_s.truncate(1000),
      backtrace:   exception.backtrace&.first(20)&.join("\n"),
      fingerprint: fingerprint,
      user_id:     user&.id
    }

    if request
      attrs.merge!(
        controller:  request.params[:controller],
        action:      request.params[:action],
        path:        request.path,
        http_method: request.method,
        params_json: filtered_params(request).to_json
      )
    end

    if job
      attrs.merge!(
        controller: job.class.name,
        action:     "perform"
      )
    end

    create!(attrs)
  rescue => e
    Rails.logger.error "[ErrorLog] Fehler beim Loggen: #{e.message}"
  end

  def self.grouped
    select("fingerprint, error_class, MIN(message) as message, COUNT(*) as occurrences, MAX(created_at) as last_seen, MIN(created_at) as first_seen")
      .group(:fingerprint, :error_class)
      .order("MAX(created_at) DESC")
  end

  private

  def self.filtered_params(request)
    request.filtered_parameters.except("controller", "action", "authenticity_token")
  rescue
    {}
  end
end
