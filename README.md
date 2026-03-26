# Microblog

A personal microblogging platform with a retro terminal aesthetic. Built with Ruby on Rails, designed to be self-hosted on a Raspberry Pi 5.

## Stack

- **Ruby on Rails 8.1** — backend & views
- **PostgreSQL 16** — database (via Docker on Pi)
- **Redis 7** — cache & Action Cable
- **Solid Queue** — background jobs (ephemeral post cleanup)
- **ActiveStorage** — avatar & media uploads (libvips)
- **Propshaft** — asset pipeline
- **Cloudflare Tunnel** — expose Pi to internet without port forwarding

## Features

- Posts with 280 character limit and 30-day ephemeral expiry
- Nested replies, likes, follow system
- User profiles with avatar, bio, terminal color theme
- Search (posts + users), user discovery page
- Image attachments on posts
- Block system, edit & delete own posts
- Unique permalink per post (random public ID)
- Registration with terminal boot aesthetic

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

# Setup database
DB_HOST=localhost DB_USER=microblog DB_PASSWORD=microblog_dev bin/rails db:create db:migrate

# Start server
DB_HOST=localhost DB_USER=microblog DB_PASSWORD=microblog_dev bin/rails server
```

Open [http://localhost:3000](http://localhost:3000)

### Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | `localhost` | PostgreSQL host |
| `DB_USER` | `microblog` | PostgreSQL user |
| `DB_PASSWORD` | *(none)* | PostgreSQL password |

## Deployment (Raspberry Pi 5)

```bash
# Pull latest and migrate
git pull
DB_HOST=localhost DB_USER=microblog DB_PASSWORD=microblog_dev bin/rails db:migrate

# Start server on port 4000
DB_HOST=localhost DB_USER=microblog DB_PASSWORD=microblog_dev bin/rails server -p 4000 -b 0.0.0.0
```

Exposed via Cloudflare Tunnel — no open firewall ports required.

## Versioning

Version is defined in `config/initializers/version.rb` and displayed in the sidebar footer.

| Version | Notes |
|---------|-------|
| `v0.1.0` | Initial release |

## Roadmap

See [ROADMAP.md](ROADMAP.md) for planned and completed features.

## Style

Terminal aesthetic based on the [DIVIDE styleguide](https://github.com/haenrick/divide/blob/saas/docs/styleguide.md).
Font: JetBrains Mono · Primary color: `#00ff88` on `#000000`
