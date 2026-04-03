class AiController < ApplicationController
  before_action :require_authentication
  rate_limit to: 10, within: 1.minute,
             with: -> { render json: { error: "Rate limit reached" }, status: :too_many_requests }

  SYSTEM_PROMPT = <<~PROMPT.freeze
    Du bist ein Assistent auf fl4re, einer Terminal-Microblogging-Plattform.
    Verbessere den folgenden Beitrag: besserer Stil, klarere Sprache, gleiche Sprache wie das Original.
    Maximal 280 Zeichen. Gib nur den verbesserten Text zurück, ohne Anführungszeichen oder Erklärungen.
  PROMPT

  def suggest
    content = params[:content].to_s.strip
    return render json: { error: "No content" }, status: :bad_request if content.blank?

    client   = Anthropic::Client.new(access_token: ENV.fetch("ANTHROPIC_API_KEY"))
    response = client.messages(
      parameters: {
        model:      "claude-haiku-4-5-20251001",
        max_tokens: 300,
        system:     SYSTEM_PROMPT,
        messages:   [ { role: "user", content: content } ]
      }
    )

    suggestion = response.dig("content", 0, "text").to_s.strip
    render json: { suggestion: suggestion }
  rescue KeyError
    render json: { error: "ANTHROPIC_API_KEY not configured" }, status: :service_unavailable
  rescue => e
    Rails.logger.error "[AiController#suggest] #{e.class}: #{e.message}"
    render json: { error: "AI unavailable" }, status: :service_unavailable
  end
end
