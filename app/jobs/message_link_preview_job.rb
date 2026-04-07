require "open-uri"

class MessageLinkPreviewJob < ApplicationJob
  queue_as :default

  URL_PATTERN = /https?:\/\/[^\s<>"]+/

  def perform(message)
    url = message.content.match(URL_PATTERN)&.to_s
    return unless url

    uri = URI.parse(url)
    return unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    html = URI.open(url, "User-Agent" => "fl4re-bot/1.0", read_timeout: 5, open_timeout: 5).read
    doc  = Nokogiri::HTML(html)

    og = ->(prop) { doc.at("meta[property='#{prop}']")&.[]("content")&.strip.presence }

    preview = {
      url:         url,
      title:       og.("og:title") || doc.at("title")&.text&.strip.presence,
      description: og.("og:description"),
      image:       og.("og:image"),
      site_name:   og.("og:site_name") || uri.host
    }.compact

    return if preview.keys == [:url]

    message.update_columns(link_preview: preview)
    message.reload

    target = "message-preview-#{message.id}"

    # Broadcast to both participants — each has their own channel
    [message.sender_id, message.recipient_id].each do |user_id|
      Turbo::StreamsChannel.broadcast_replace_to(
        "messages_#{user_id}",
        target: target,
        partial: "messages/link_preview",
        locals: { message: message }
      )
    end
  rescue => e
    Rails.logger.warn "[MessageLinkPreviewJob] Failed for message #{message.id}: #{e.message}"
  end
end
