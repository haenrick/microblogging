class WelcomeJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    bot = User.find_by(username: "fl4re_bot")
    return unless bot

    content = "✦ willkommen bei fl4re, @#{user.username}!\n\n// deine posts leben 30 tage — dann verbrennen sie. viel spaß."
    Post.create!(user: bot, content: content)
  end
end
