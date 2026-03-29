# fl4re — Roadmap

> Stand: März 2026 · Stack: Ruby on Rails 8.1 · PostgreSQL 16 · Pi 5 + Cloudflare Tunnel

---

## Abgeschlossen ✅

| # | Feature |
|---|---------|
| N2 | Rails-Migration (von PocketBase + Vanilla JS) |
| N0 | Benutzerprofil — Avatar, Bio, Profilseite |
| N1 | Follow-System — Follow/Unfollow, Following-Feed-Tab |
| N3 | Blockieren — Block/Unblock, Feed-Filter, Follow-Guard |
| S1 | Suche — Posts und User (ILIKE) |
| S2 | User-Discover — User-Grid mit Follow-Button |
| U1 | Registrierung — Terminal Boot-Aesthetic Signup |
| X1 | Medien — Bilder in Posts (ActiveStorage) |
| Q1 | Enter zum Posten |
| EP | Ephemeral Posts — 30-Tage-Ablauf, Countdown-Badge, Auto-Purge |
| TH | Terminal-Themes — 6 Farbthemen in Settings wählbar |
| ED | Post bearbeiten — Edit-Button, "edited" Kennzeichnung |
| PL | Post-Permalink — zufällige public_id in URL |
| CC | Zeichenzähler beim Verfassen |
| U2 | Admin-Konsole — Dashboard, User- und Post-Verwaltung |
| SE | Sicherheit (Basis) — Rate Limiting, Datei-Validierung, CSP, Rack::Attack |
| UX | UX-Polish — Turbo Streams (Like), Stimulus Toggle (Reply/Edit), btn-danger |
| D1 | Production-Mode — RAILS_ENV=production, assume_ssl, .env-Setup |
| D2 | systemd-Service — Template `config/fl4re.service`, Auto-Restart + Boot |
| D4 | Backup — `bin/backup` mit pg_dump + 30-Tage-Rotation |
| T1 | Redis eliminiert — solid_cable aktiv, Redis aus docker-compose entfernt |
| T2 | delete_all — PurgeExpiredPostsJob direkte DB-Deletion statt N+1 |
| T4 | Inline-JS → Stimulus — PostForm-Controller (Charcount, File-Label, Enter-to-Post) |
| T7 | Admin-Hierarchie — Admins können andere Admins nicht löschen/degradieren |
| S5 | Session-Ablauf — Sessions nach 30 Tagen serverseitig invalidieren |
| M6 | PWA-Basis — manifest.webmanifest, PwaController, apple-touch-icon |
| T5 | Fragment Caching — `cache [post, user.id]` in Feed-Posts |
| S1 | Account-Lockout — Rack::Attack throttle 20 Login-Versuche/h pro IP |
| D3 | GitHub Actions Deploy-Job — self-hosted Runner auf Pi, `bin/deploy` |
| T3 | E-Mail via Brevo — Passwort-Reset, fl4re-Mail-Template, Absender `noreply@fl4re.datenkistchen.de` |

---

## In Arbeit 🔧

| # | Feature | Branch |
|---|---------|--------|
| — | Code-Cleanup (tote Dateien, Gem-Bereinigung) | feature/code-cleanup |

---

## Geplant 📋

### Infrastruktur & CI/CD (priorisiert für 24/7-Betrieb)

| # | Feature | Aufwand | Beschreibung |
|---|---------|---------|--------------|
| D1 | Production-Mode auf Pi | ~2h | RAILS_ENV=production, Secret-Setup, Asset-Precompile |
| D2 | systemd-Service | ~1h | Auto-Restart bei Crash, Start beim Pi-Boot |
| D3 | CD via GitHub Actions | ~2h | Push to main → Pi automatisch updated via SSH |
| D4 | pg_dump Backup-Cronjob | ~1h | Tägliches DB-Backup lokal + optional remote |
| D5 | Kamal Deployment | ~1 Tag | Zero-Downtime-Deploys, Docker-basiert, Rails 8 nativ |
| D6 | Hetzner-Migration | ~1 Tag | CX22 (~5€/Monat) für öffentlichen Launch, Kamal-Deploy |

### D1 — Production-Mode

**Problem:** Pi läuft aktuell im `development`-Modus — langsam, Debug-Info sichtbar, Assets nicht optimiert.

**Maßnahmen:**
- `RAILS_ENV=production` in `bin/start` setzen
- `RAILS_MASTER_KEY` als Env-Variable oder Datei setzen
- `SECRET_KEY_BASE` generieren und setzen
- `bin/rails assets:precompile` einmalig ausführen
- `bin/rails db:migrate RAILS_ENV=production`

**Aufwand:** ~2h

---

### D2 — systemd-Service

**Problem:** App läuft in einer screen-Session. Beim Crash oder Pi-Neustart bleibt die App unten.

**Lösung:** systemd-Unit `/etc/systemd/system/fl4re.service`

```ini
[Unit]
Description=fl4re Rails App
After=network.target docker.service

[Service]
Type=simple
User=henrik
WorkingDirectory=/home/henrik/microblog
EnvironmentFile=/home/henrik/microblog/.env
ExecStart=/home/henrik/microblog/bin/start
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Credentials in `/home/henrik/microblog/.env` (nicht in Git):
```
DB_HOST=localhost
DB_USER=microblog
DB_PASSWORD=microblog_dev
RAILS_ENV=production
PORT=4000
```

Steuerbefehle: `sudo systemctl start|stop|restart|status fl4re`

**Aufwand:** ~1h · **Abhängigkeit:** D1

---

### D3 — CD via GitHub Actions (Self-hosted Runner)

**Problem:** Deploys sind manuell — SSH → git pull → bundle install → restart.

**Lösung:** Self-hosted GitHub Actions Runner direkt auf dem Pi. Kein SSH-Schlüssel in GitHub Secrets nötig — der Runner-Daemon läuft als systemd-Service und führt Jobs lokal aus.

**Setup Pi (~10 min):**
1. GitHub → Settings → Actions → Runners → „New self-hosted runner" → Token kopieren
2. Runner-Binary herunterladen, Token eingeben, als systemd-Service registrieren

**Workflow `.github/workflows/deploy.yml`:**

```yaml
deploy:
  needs: [scan_ruby, lint, test]
  runs-on: self-hosted
  if: github.ref == 'refs/heads/main'
  steps:
    - name: Deploy
      run: |
        cd ~/microblog
        git pull
        bundle install --without development test
        bin/rails assets:precompile RAILS_ENV=production
        bin/rails db:migrate RAILS_ENV=production
        sudo systemctl restart fl4re
```

**Vorteile gegenüber SSH-Ansatz:**
- Kein PI_SSH_KEY Secret nötig
- Deploy-Log direkt in GitHub Actions UI sichtbar
- Läuft in der echten Pi-Umgebung mit echtem `.env`

**Aufwand:** ~20–30 min · **Abhängigkeiten:** D1 ✅, D2 ✅

---

### D4 — Datenbank-Backup

**Problem:** Postgres-Daten liegen nur im Docker-Volume — kein Backup.

**Lösung:** Cronjob mit `pg_dump`:

```bash
# crontab -e
0 3 * * * docker exec microblog_db pg_dump -U microblog fl4re_development > ~/backups/fl4re_$(date +\%Y\%m\%d).sql
# Backups älter als 30 Tage löschen
0 4 * * * find ~/backups -name "fl4re_*.sql" -mtime +30 -delete
```

Optional: Backup via `rclone` zu Cloudflare R2 oder einem anderen S3-kompatiblen Dienst.

**Aufwand:** ~1h

---

### D5 — Kamal Deployment

**Ziel:** Zero-Downtime-Deploys mit Docker, ohne manuelles SSH.

- `config/deploy.yml` konfigurieren (Server-IP, Image, Env-Vars)
- Docker-Image auf Pi oder GitHub Container Registry bauen
- `kamal deploy` rollt neues Image aus ohne Downtime

**Hinweis:** Pi 5 ist ARM64 — Multi-Platform-Build oder direkt auf Pi bauen nötig.

**Aufwand:** ~1 Tag · **Sinnvoll ab D6 (Hetzner)**

---

### D6 — Hetzner-Migration

**Wann:** Bei öffentlichem Launch oder wenn Pi-Risiken (Stromausfall, SD-Karte) nicht mehr akzeptabel sind.

| Aspekt | Pi 5 | Hetzner CX22 |
|--------|------|--------------|
| Kosten | €0 | ~€5/Monat |
| RAM | 4–8 GB | 4 GB |
| Redundanz | Keine | Rechenzentrum |
| Backup | Manuell | Snapshot-Option |
| Uptime | ~99% | ~99.9% |

**Empfehlung:** Pi für Entwicklung/Beta, Hetzner für Launch.

---

### Tech-Optimierungen (aus Code-Audit)

#### 🔴 Hoch

| # | Maßnahme | Aufwand | Beschreibung |
|---|----------|---------|--------------|
| ~~T3~~ | ~~E-Mail via Brevo~~ | ✅ | Brevo SMTP konfiguriert, Absender `noreply@fl4re.datenkistchen.de`, Passwort-Reset aktiv |

#### 🟡 Mittel

| # | Maßnahme | Aufwand | Beschreibung |
|---|----------|---------|--------------|
| T6 | PostgreSQL Full-Text Search | ~2h | `tsvector`/`tsquery` statt ILIKE — kein Extra-Gem, indexierbar, relevanter |

#### 🟢 Niedrig

| # | Maßnahme | Aufwand | Beschreibung |
|---|----------|---------|--------------|
| T8 | Live-Feed via Turbo Streams | ~1 Tag | Neue Posts erscheinen ohne Reload (Turbo Broadcast) |
| T9 | Fehler-Tracking | ~1h | Sentry o.ä. für Production-Errors — aktuell keine Sichtbarkeit bei Crashes |
| T10 | Avatar Variant Caching | ~1h | Thumbnails werden on-demand generiert, kein Caching |

---

### Nächste Feature-Schritte (priorisiert)

| # | Feature | Aufwand | Beschreibung |
|---|---------|---------|--------------|
| U3 | Privates Profil | ~1–2 Tage | Profil auf privat stellen, Follower-Anfragen mit pending-Status |
| N5 | In-App Benachrichtigungen | ~1.5 Tage | Glocken-Icon + Badge, Notification-Feed; Events: neuer Follower, Like, Reply; real-time via Turbo Broadcast (solid_cable ✅) |
| N6 | Push Notifications | ~1 Tag | Browser/OS-Benachrichtigungen auch wenn App geschlossen; Web Push API + Service Worker; baut auf N5 + M6 auf |
| M6 | PWA — Service Worker | ~0.5 Tag | Offline-Cache, Voraussetzung für N6 (Basis-Manifest ✅) |
| X2 | KI-Integration | ~1–3 Tage | Post-Assistent via Claude API (X2a), Smart Search (X2c) |
| N4 | E2E-DMs | ~3–5 Tage | Ende-zu-Ende-verschlüsselte Direktnachrichten (X25519 + AES-GCM) |
| I1 | iOS App | Später | Erst PWA, dann SwiftUI wenn Nutzerbasis es rechtfertigt |

### Sicherheit (ausstehend)

| # | Risiko | Aufwand | Maßnahme |
|---|--------|---------|----------|
| S2 | Kein Admin-Audit-Log | ~2h | Admin-Aktionen in DB loggen |
| S3 | Kein 2FA | ~1 Tag | TOTP via `rotp` Gem |
| S4 | Keine E-Mail-Verifikation | ~1 Tag | Token-basierte Verifikation bei Registrierung |

> Vollständige Dokumentation: [docs/security.md](docs/security.md)

---

### U3 — Privates Profil

**Ziel:** User können ihr Profil auf privat stellen. Posts sind nur für Follower sichtbar.

- `private_profile: boolean` auf `User`
- Follow-Anfragen statt direktem Follow (`pending` Status auf `Follow`)
- Anfragen annehmen / ablehnen auf Profilseite
- Nicht-Follower sehen nur Avatar + Bio, keine Posts

**Aufwand:** ~1–2 Tage · **Abhängigkeiten:** N1 (Follow-System ✅)

---

### M6 — PWA / Service Worker

**Ziel:** App auf dem iPhone Home-Screen installierbar, Vollbild ohne Browser-Chrome.

- `manifest.json` mit Icon, Theme-Color, Display-Mode
- Service Worker für Offline-Cache der letzten Posts
- `apple-touch-icon` für iOS

**Aufwand:** ~1 Tag · Kein Backend-Umbau nötig

---

### X2 — KI-Integration

**Mögliche Features:**

| # | Feature | Beschreibung | Aufwand |
|---|---------|--------------|---------|
| X2a | Post-Assistent | KI verbessert Entwurf auf Knopfdruck | ~1 Tag |
| X2b | Thread-Zusammenfassung | Lange Threads auf Permalink-Seite zusammenfassen | ~1 Tag |
| X2c | Smart Search | Semantische Suche statt ILIKE | ~2 Tage |
| X2d | Content-Moderation | Automatisches Flaggen toxischer Posts | ~2 Tage |

**Technischer Ansatz:** Claude API (Anthropic) · `anthropic-rb` Gem · Stimulus-Controller → `/ai/suggest`

---

### N5 — In-App Benachrichtigungen

**Events:** neuer Follower, Like auf eigenen Post, Reply auf eigenen Post

**Datenbankschema:**
```
notifications: id, recipient_id, actor_id, notifiable_type, notifiable_id, type, read_at, created_at
```

**Ausbaustufen:**
1. `notifications`-Tabelle + Glocken-Icon mit Badge in der Sidebar (ungelesene Anzahl)
2. Notification-Feed (eigene Seite oder Dropdown)
3. Real-time Badge-Update via Turbo Broadcast — solid_cable ist bereits konfiguriert ✅
4. E-Mail-Benachrichtigung optional pro Event in den Settings (setzt T3 voraus)

**Aufwand:** ~1.5 Tage · **Abhängigkeiten:** T3 für E-Mail-Notifications (optional)

---

### N6 — Push Notifications

**Ziel:** Browser/OS-Benachrichtigungen auch wenn fl4re geschlossen ist.

**Technischer Ansatz:** Web Push API
- Service Worker empfängt Push-Events vom Server
- Server sendet Push via `web-push` Gem an gespeicherte Subscriptions
- Nutzer muss Berechtigung erteilen (Browser-Dialog)

**Datenbankschema:**
```
push_subscriptions: id, user_id, endpoint, p256dh_key, auth_key, created_at
```

**Aufwand:** ~1 Tag · **Abhängigkeiten:** N5 ✅ (Notification-System), M6 (Service Worker)

---

### N4 — E2E-verschlüsselte Direktnachrichten

**Kryptographie:** X25519 + AES-GCM via Web Crypto API

- Server speichert nur Ciphertext + IV + Public Keys
- Private Keys verlassen nie den Browser
- Kein Key-Recovery ohne Export-Flow (Nutzer-Warnung nötig)

**Datenbankschema:**
```
messages:  id, sender_id, recipient_id, ciphertext, iv, created_at
user_keys: user_id, public_key
```

**Aufwand:** ~3–5 Tage · **Abhängigkeiten:** N3 (Block-Check ✅)

---

### I1 — iOS App

**Empfohlene Reihenfolge:**
1. Erst **M6 PWA** — für die meisten Nutzer ausreichend, kein App Store nötig
2. Dann SwiftUI-App die die bestehende Rails-API konsumiert

**Voraussetzungen:** Apple Developer Account (99 $/Jahr), HTTPS (via Cloudflare ✅)

---

## Deployment

```
fl4re.datenkistchen.de
        │
  Cloudflare Tunnel (HTTPS automatisch)
        │
  Raspberry Pi 5
  ┌──────────────────────────┐
  │  Rails (Puma)  :4000     │
  │  PostgreSQL    :5432     │
  │  (Docker Compose)        │
  └──────────────────────────┘
```

Kosten: **€0/Monat** (Pi und Cloudflare bereits vorhanden)

Für öffentlichen Launch: Hetzner CX22 (~5 €/Monat) + Kamal (bereits im Gemfile)

---

## Versionierung

| Version | Inhalt |
|---------|--------|
| `v0.1.0` | Basis-Features: Posts, Replies, Likes, Follow, Search, Discover, Profile, Themes, Ephemeral Posts, Edit, Permalink, Admin |
| `v0.2.0` | Admin-Konsole, fl4re-Rename, Bugfixes, CI-Stabilisierung |
| `v0.3.x` | Sicherheit (Rack::Attack, CSP, Rate Limiting), UX (Turbo Streams, Stimulus), Deployment-Fixes |
| `v0.4.0` | Production-Mode, systemd-Service, Backup-Script, Redis eliminiert |
| `v0.5.0` | User Preferences, Enter-to-post, CSP-Fix Inline-Script |
| `v0.5.1` | Theme-Auswahl-Fix (CSP Nonce + Swatches), Passwörter aus README entfernt |
| `v0.6.0` | Stimulus PostForm-Controller, Admin-Hierarchie, Session-Ablauf, PWA-Basis |
| `v0.7.0` | Bugfixes (Post-Edit, Theme-Preview), Fragment Caching, Account-Lockout, CD via GitHub Actions |
