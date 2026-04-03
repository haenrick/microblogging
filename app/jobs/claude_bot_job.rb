class ClaudeBotJob < ApplicationJob
  queue_as :default

  BOT_USERNAME = "claude"

  SYSTEM_PROMPT = <<~PROMPT.freeze
    Du bist @claude, ein KI-Assistent auf fl4re — einer minimalistischen Terminal-Microblogging-Plattform.
    Antworte präzise und hilfreich. Maximal 240 Zeichen.
    Gib nur deine Antwort zurück, ohne Präfixe oder Metakommentare.
  PROMPT

  def perform(post)
    bot_user = User.find_by(username: BOT_USERNAME)
    return unless bot_user
    return unless ENV["ANTHROPIC_API_KEY"].present?

    client   = Anthropic::Client.new(access_token: ENV.fetch("ANTHROPIC_API_KEY"))
    response = client.messages(
      parameters: {
        model:      "claude-haiku-4-5-20251001",
        max_tokens: 280,
        system:     SYSTEM_PROMPT,
        messages:   [ { role: "user", content: post.content } ]
      }
    )

    reply_text = response.dig("content", 0, "text").to_s.strip
    return if reply_text.blank?

    bot_user.posts.create!(
      content:    reply_text,
      parent:     post,
      public_id:  SecureRandom.urlsafe_base64(8),
      expires_at: 30.days.from_now
    )
  rescue => e
    Rails.logger.error "[ClaudeBotJob] post=#{post.id} #{e.class}: #{e.message}"
  end
end
