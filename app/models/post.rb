class Post < ApplicationRecord
  belongs_to :user
  belongs_to :parent, class_name: "Post", optional: true
  has_many :replies, class_name: "Post", foreign_key: :parent_id, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_by_users, through: :likes, source: :user

  validates :content, presence: true, length: { maximum: 280 }

  scope :top_level, -> { where(parent_id: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def liked_by?(user)
    likes.exists?(user: user)
  end
end
