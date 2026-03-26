class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :following, class_name: "User"

  validates :follower_id, uniqueness: { scope: :following_id }
  validate :no_self_follow

  private

  def no_self_follow
    errors.add(:follower, "can't follow yourself") if follower_id == following_id
  end
end
