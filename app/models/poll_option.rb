class PollOption < ApplicationRecord
  belongs_to :post
  has_many :poll_votes, dependent: :destroy

  validates :text, presence: true, length: { maximum: 80 }

  def votes_count
    poll_votes.count
  end

  def percentage(total)
    return 0 if total == 0
    (votes_count.to_f / total * 100).round
  end
end
