# fl4re

A personal microblogging platform with a retro terminal aesthetic and ephemeral posts. Built with Ruby on Rails, self-hosted on a Raspberry Pi 5.

Part of the [DIVIDE](https://github.com/haenrick/divide) product family.

## Stack

- **Ruby on Rails 8.1** — backend & views
- **PostgreSQL 16** — database (via Docker on Pi)
- **Solid Queue** — background jobs (ephemeral post cleanup)
- **Solid Cable** — Action Cable without Redis
- **Solid Cache** — fragment caching in DB
- **ActiveStorage** — avatar & media uploads (libvips)
- **Propshaft** — asset pipeline
- **Hotwire** (Turbo + Stimulus) — reactive UI without a JS framework
- **Cloudflare Tunnel** — expose Pi to internet without port forwarding
- **Brevo** — transactional email (password reset)

## Features

- Posts with 280 character limit and 30-day ephemeral expiry with countdown
- Nested replies, likes, follow system
- User profiles with avatar, bio, terminal color theme (6 colors)
- Search (posts + users), user discovery page
- Image attachments on posts
- Block system, edit & delete own posts
- Unique permalink per post (random public ID)
- Admin console (dashboard, user management, post moderation)
- Registration with terminal boot aesthetic
- User preferences (Enter-to-post toggle, extensible via JSONB)
- Password reset via email
- Session expiry after 30 days
- In-app notifications (like, follow, reply) with real-time badge via Turbo Broadcast
- Push notifications (Web Push API, VAPID, opt-in browser permission)
- PWA: installable, service worker with offline cache
- Fragment caching with automatic cache invalidation

## Development Setup

### Prerequisites

- Ruby 3.3.6 (`rbenv` recommended)
- PostgreSQL running locally or via Docker

### Quick start

```bash
git clone https://github.com/haenrick/microblogging repo
cd repo
bundle install

# Start services
docker compose up -d

# Setup database
DB_HOST=localhost DB_USER=fl4re DB_PASSWORD=<your-password> bin/rails db:create db:migrate

# Start server
DB_HOST=localhost DB_USER=fl4re DB_PASSWORD=<your-password> bin/rails server
```

Open [http://localhost:3000](http://localhost:3000)

### Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DB_HOST` | yes | PostgreSQL host |
| `DB_USER` | yes | PostgreSQL user |
| `DB_PASSWORD` | yes | PostgreSQL password |
| `RAILS_MASTER_KEY` | production | Content of `config/master.key` |
| `SECRET_KEY_BASE` | production | Rails secret key base |
| `BREVO_SMTP_USER` | production | Brevo SMTP login (from Brevo dashboard → SMTP & API) |
| `BREVO_SMTP_KEY` | production | Brevo SMTP key |
| `VAPID_PUBLIC_KEY` | production | Web Push VAPID public key — generate once on the server: `bundle exec ruby -e "require 'web_push'; kp = WebPush::VapidKey.new.to_h; puts 'VAPID_PUBLIC_KEY=' + kp[:public_key]; puts 'VAPID_PRIVATE_KEY=' + kp[:private_key]"` |
| `VAPID_PRIVATE_KEY` | production | Web Push VAPID private key (see above) |

See `.env.example` for a full template.

### First admin user

```bash
bin/rails console
User.find_by(username: "your_username").update!(admin: true)
```

## Testing

```bash
DB_HOST=localhost DB_USER=microblog DB_PASSWORD=microblog_dev RAILS_ENV=test bin/rails test
```

102 tests, 252 assertions. See [docs/testing.md](docs/testing.md) for the full test strategy.

## Deployment (Raspberry Pi 5)

Deployments run automatically via GitHub Actions on every push to `main` (self-hosted runner on the Pi).

Manual deploy:

```bash
bin/deploy
```

The script loads `.env`, runs `git pull`, `bundle install`, `assets:precompile`, `db:migrate`, and restarts the systemd service.

Exposed via Cloudflare Tunnel — no open firewall ports required.

## Versioning & Changelog

See [CHANGELOG.md](CHANGELOG.md) for full version history.
Version is defined in `config/initializers/version.rb` and displayed in the sidebar footer.

## Roadmap

See [ROADMAP.md](ROADMAP.md) for planned and completed features.

## Style

Terminal aesthetic documented in [docs/styleguide.md](docs/styleguide.md), based on the [DIVIDE styleguide](https://github.com/haenrick/divide/blob/saas/docs/styleguide.md).
Font: JetBrains Mono · Primary color: `#00ff88` on `#000000`
