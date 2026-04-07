class AuditLog < ApplicationRecord
  belongs_to :admin, class_name: "User"

  ACTIONS = {
    "user.deleted"       => "User gelöscht",
    "user.admin_granted" => "Admin-Rechte vergeben",
    "user.admin_revoked" => "Admin-Rechte entzogen",
    "post.deleted"       => "Post gelöscht"
  }.freeze

  def self.record(admin:, action:, target: nil, details: nil)
    create!(
      admin:        admin,
      action:       action,
      target_type:  target&.class&.name,
      target_id:    target&.id,
      target_label: label_for(target),
      details:      details
    )
  rescue => e
    Rails.logger.error "[AuditLog] Fehler beim Loggen: #{e.message}"
  end

  def action_label
    ACTIONS[action] || action
  end

  private

  def self.label_for(target)
    case target
    when User then "@#{target.username}"
    when Post then target.content.truncate(60)
    else target&.to_s
    end
  end
end
