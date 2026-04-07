module ApplicationHelper
  def render_post_content(content)
    escaped = h(content)
    linked  = escaped.gsub(/@(\w+)/) do
      username = $1
      link_to "@#{username}", profile_path(username), class: "mention-link"
    end
    linked = linked.gsub(/#([a-z0-9_äöüß]+)/i) do
      tag = $1.downcase
      link_to "##{$1}", hashtag_path(tag), class: "hashtag-link"
    end
    linked.html_safe
  end
end
