class Invite < ApplicationRecord
  INVITES_PER_USER = 5

  belongs_to :user
  belongs_to :used_by, class_name: "User", optional: true

  before_create :generate_token

  scope :available, -> { where(used_at: nil).where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :used,      -> { where.not(used_at: nil) }

  def used?
    used_at.present?
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def redeem!(user)
    return false if used? || expired?
    update!(used_by: user, used_at: Time.current)
    true
  end

  def self.grant_to(user, count: INVITES_PER_USER)
    count.times { user.invites.create!(expires_at: 90.days.from_now) }
  end

  private

  def generate_token
    self.token = SecureRandom.alphanumeric(12).upcase.scan(/.{4}/).join("-")
    generate_token if Invite.exists?(token: token)
  end
end
