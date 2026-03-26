class Block < ApplicationRecord
  belongs_to :blocker, class_name: "User"
  belongs_to :blocked, class_name: "User"

  validates :blocker_id, uniqueness: { scope: :blocked_id }
  validate :no_self_block

  private

  def no_self_block
    errors.add(:blocker, "can't block yourself") if blocker_id == blocked_id
  end
end
