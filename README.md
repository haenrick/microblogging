# fl4re

A personal microblogging platform with a retro terminal aesthetic and ephemeral posts. Built with Ruby on Rails, self-hosted on a Raspberry Pi 5.

Part of the [DIVIDE](https://github.com/haenrick/divide) product family.

## Stack

- **Ruby on Rails 8.1** — backend & views
- **PostgreSQL 16** — database (via Docker on Pi)
- **Redis 7** — cache & Action Cable
- **Solid Queue** — background jobs (ephemeral post cleanup)
- **ActiveStorage** — avatar & media uploads (libvips)
- **Propshaft** — asset pipeline
- **Cloudflare Tunnel** — expose Pi to internet without port forwarding

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

## Development Setup

### Prerequisites

- Ruby 3.3.6 (`rbenv` recommended)
- PostgreSQL running locally or via Docker
- Redis running locally or via Docker

### Quick start

```bash
git clone https://github.com/haenrick/microblogging repo
cd repo
bundle install

# Start services
docker compose up -d

# Setup database (DB_USER matches docker-compose.yml)
DB_HOST=localhost DB_USER=fl4re DB_PASSWORD=<your-password> bin/rails db:create db:migrate

# Start server
DB_HOST=localhost DB_USER=fl4re DB_PASSWORD=<your-password> bin/rails server
```

Open [http://localhost:3000](http://localhost:3000)

> **Pi note:** The existing Pi setup overrides `DB_USER` and `DB_PASSWORD` via `.env` — these ENV vars are set on the server and keep working as-is.

### Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | `localhost` | PostgreSQL host |
| `DB_USER` | `fl4re` | PostgreSQL user |
| `DB_PASSWORD` | *(required)* | PostgreSQL password |

### First admin user

```bash
bin/rails console
User.find_by(username: "your_username").update!(admin: true)
```

## Deployment (Raspberry Pi 5)

```bash
# Pull latest and migrate
git pull
bin/rails db:migrate

# Start server on port 4000
bin/start
```

Exposed via Cloudflare Tunnel — no open firewall ports required.

## Versioning & Changelog

See [CHANGELOG.md](CHANGELOG.md) for full version history.
Version is defined in `config/initializers/version.rb` and displayed in the sidebar footer.

## Roadmap

See [ROADMAP.md](ROADMAP.md) for planned and completed features.

## Style

Terminal aesthetic documented in [docs/styleguide.md](docs/styleguide.md), based on the [DIVIDE styleguide](https://github.com/haenrick/divide/blob/saas/docs/styleguide.md).
Font: JetBrains Mono · Primary color: `#00ff88` on `#000000`
