class Message < ApplicationRecord
  belongs_to :sender,    class_name: "User"
  belongs_to :recipient, class_name: "User"

  validates :content, presence: true, length: { maximum: 1000 }

  after_create_commit :broadcast_to_recipient
  after_create_commit :enqueue_link_preview, if: -> { content.match?(/https?:\/\//) }

  scope :conversation_between, ->(a, b) {
    where(sender: a, recipient: b).or(where(sender: b, recipient: a)).order(:created_at)
  }

  def read?
    read_at.present?
  end

  private

  def broadcast_to_recipient
    broadcast_append_to "messages_#{recipient_id}",
      target: "messages-list",
      partial: "messages/message",
      locals: { message: self, current_user: sender }
  end

  def enqueue_link_preview
    MessageLinkPreviewJob.perform_later(self)
  end
end
