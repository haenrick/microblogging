require "open-uri"

class LinkPreviewJob < ApplicationJob
  queue_as :default

  URL_PATTERN = /https?:\/\/[^\s<>"]+/

  def perform(post)
    url = post.content.match(URL_PATTERN)&.to_s
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

    return if preview.keys == [ :url ]

    post.update_columns(link_preview: preview, updated_at: Time.current)
  rescue => e
    Rails.logger.warn "[LinkPreviewJob] Failed for post #{post.id}: #{e.message}"
  end
end
