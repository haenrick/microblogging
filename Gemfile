source "https://rubygems.org"

gem "rails", "~> 8.1.3"
# Asset pipeline
gem "propshaft"
# Database
gem "pg", "~> 1.1"
# Web server
gem "puma", ">= 5.0"
# Hotwire
gem "turbo-rails"
gem "stimulus-rails"
# Authentication
gem "bcrypt", "~> 3.1.7"
# Image variants (avatars, media)
gem "image_processing", "~> 1.2"

# Windows timezone support
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Database-backed adapters for Rails.cache and Active Job
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Boot time caching
gem "bootsnap", require: false

# Deployment
gem "kamal", require: false
gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end
