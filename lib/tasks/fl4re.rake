namespace :fl4re do
  desc "Post release announcement as fl4re_bot (idempotent — skips if version already announced)"
  task announce_version: :environment do
    version = FL4RE_VERSION

    bot = User.find_or_create_by!(username: "fl4re_bot") do |u|
      u.email_address    = "bot@fl4re.datenkistchen.de"
      u.password         = SecureRandom.hex(32)
      u.email_verified_at = Time.current
    end

    if Post.where(user: bot).where("content LIKE ?", "%v#{version}%").exists?
      puts "[fl4re:announce_version] v#{version} bereits angekündigt — übersprungen."
      next
    end

    news = extract_changelog_news(version)
    content = "✦ fl4re v#{version} ist live\n\n#{news}".strip.truncate(280)

    Post.create!(user: bot, content: content)
    puts "[fl4re:announce_version] Post als @fl4re_bot veröffentlicht."
  end

  def extract_changelog_news(version)
    changelog = Rails.root.join("CHANGELOG.md").read
    # Alles zwischen dem ersten ## [version]-Header und dem nächsten ---
    section = changelog[/## \[#{Regexp.escape(version)}\][^\n]*\n(.*?)^---/m, 1].to_s
    # Nur ### Neu und ### Fixes — erste 3 Bullet-Points
    lines = section.lines.select { |l| l.match?(/^- /) }.first(3)
    lines.map { |l| l.gsub(/\*\*(.+?)\*\*/, '\1').strip }.join("\n")
  end
end
