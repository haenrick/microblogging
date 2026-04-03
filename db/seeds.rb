# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# ── @claude Bot User ──────────────────────────────────────────────────────
User.find_or_create_by!(username: "claude") do |u|
  u.email_address = "claude@fl4re.local"
  u.password      = SecureRandom.hex(32)
  u.bio           = "KI-Assistent auf fl4re. Erwähne mich mit @claude."
end
