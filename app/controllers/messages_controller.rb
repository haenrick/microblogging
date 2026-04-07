class MessagesController < ApplicationController
  before_action :require_authentication
  before_action :set_partner, only: %i[show create]

  def index
    # Latest message per conversation partner, ordered by most recent
    @conversations = conversations_for(Current.user)
  end

  def show
    unless Current.user.can_message?(@partner) || @partner.can_message?(Current.user)
      redirect_to messages_path, alert: "Du kannst diese Person nicht anschreiben."
      return
    end

    @messages = Message.conversation_between(Current.user, @partner)
    @messages.where(recipient: Current.user, read_at: nil).update_all(read_at: Time.current)
    @new_message = Message.new
  end

  def create
    unless Current.user.can_message?(@partner)
      redirect_to messages_path, alert: "Du kannst diese Person nicht anschreiben."
      return
    end

    @new_message = Current.user.sent_messages.build(
      recipient: @partner,
      content:   params[:message][:content].to_s.strip
    )

    if @new_message.save
      redirect_to message_path(@partner.username)
    else
      @messages = Message.conversation_between(Current.user, @partner)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_partner
    @partner = User.find_by!(username: params[:username])
  rescue ActiveRecord::RecordNotFound
    redirect_to messages_path, alert: "User nicht gefunden."
  end

  def conversations_for(user)
    # All messages involving this user, deduplicated to one entry per partner,
    # showing the latest message. Raw SQL for efficiency.
    Message.find_by_sql([ <<~SQL, user.id, user.id ])
      SELECT DISTINCT ON (partner_id) partner_id, messages.*
      FROM (
        SELECT recipient_id AS partner_id, messages.*
        FROM messages WHERE sender_id = ?
        UNION ALL
        SELECT sender_id AS partner_id, messages.*
        FROM messages WHERE recipient_id = ?
      ) messages
      ORDER BY partner_id, created_at DESC
    SQL
      .map do |msg|
        partner = User.find(msg.partner_id)
        { partner: partner, last_message: msg,
          unread: Message.where(sender: partner, recipient: user, read_at: nil).exists? }
      end
      .sort_by { |c| -c[:last_message].created_at.to_i }
  end
end
