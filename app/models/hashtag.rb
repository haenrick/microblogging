class Hashtag < ApplicationRecord
  has_many :post_hashtags, dependent: :destroy
  has_many :posts, through: :post_hashtags

  validates :name, presence: true, uniqueness: { case_sensitive: false },
                   format: { with: /\A[a-z0-9_äöüß]+\z/i }

  before_save { self.name = name.downcase }
end
