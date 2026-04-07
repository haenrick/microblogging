# fl4re — Roadmap

> Stand: April 2026 · v0.9.6 · Stack: Ruby on Rails 8.1 · PostgreSQL 16 · Pi 5 + Cloudflare Tunnel

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
| M6 | PWA — Service Worker, Offline-Cache, Push-Grundlage (manifest.webmanifest, PwaController, apple-touch-icon) |
| T5 | Fragment Caching — `cache [post, user.id]` in Feed-Posts |
| S1 | Account-Lockout — Rack::Attack throttle 20 Login-Versuche/h pro IP |
| D3 | GitHub Actions Deploy-Job — self-hosted Runner auf Pi, `bin/deploy` |
| T3 | E-Mail via Brevo — Passwort-Reset, fl4re-Mail-Template, Absender `noreply@fl4re.datenkistchen.de` |
| N5 | In-App Benachrichtigungen — Like, Follow, Reply; Badge in Sidebar; Real-time via Turbo Broadcast |
| N6 | Push Notifications — Web Push API, VAPID, `web-push` Gem, Service Worker Push-Handler |
| QA | Teststrategie — 102 Tests, 252 Assertions; Models, Controller, Jobs; `docs/testing.md` |
| BF | Like 500-Bugfix — Race-Condition (Safari Doppel-Tap) behoben; Follower-/Following-Listen (`/:username/followers`, `/:username/following`) |
| U3 | Privates Profil — `private_profile` Flag, Follow-Requests (pending/accepted), Accept/Decline auf Profilseite, Notification bei Annahme |
| T8 | Live-Feed — Neue Posts erscheinen sofort im "All"-Tab via Turbo Broadcast (nur public, nur top-level) |
| MB | Mobile Layout — Einspaltig auf kleinen Screens, sticky Header mit Avatar-Button, Slide-in-Nav (Stimulus) |
| MF | Mobile Fix — Overlay-Schrift lesbar, Backdrop klickbar (close on click) |
| LP | Link Previews — OpenGraph-Card unter Posts mit URLs (async via LinkPreviewJob) |
| AT | @Mentions — `@username` wird verlinkt, Mention-Notification an erwähnte User |
| X2a | Post-Assistent — ✦ improve-Button verbessert Draft per Claude API (Haiku); rate-limited 10 req/min |
| X2b | @claude Bot — antwortet auf @claude-Mentions via ClaudeBotJob + Anthropic API (Haiku) |
| AT2 | @Mentions + Link Previews — @username verlinkt, Mention-Notification, OpenGraph-Card async via LinkPreviewJob |

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
| D5 | Kamal Deployment | ~1 Tag | Zero-Downtime-Deploys, Docker-basiert, Rails 8 nativ |
| D6 | Hetzner-Migration | ~1 Tag | CX22 (~5€/Monat) für öffentlichen Launch, Kamal-Deploy |

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
| ~~T6~~ | ~~PostgreSQL Full-Text Search~~ | ✅ | `tsvector`/`websearch_to_tsquery` + GIN-Indexes auf posts und users |

#### 🟢 Niedrig

| # | Maßnahme | Aufwand | Beschreibung |
|---|----------|---------|--------------|
| ~~T8~~ | ~~Live-Feed via Turbo Streams~~ | ✅ | Neue Posts erscheinen in Echtzeit im "All"-Tab via `broadcast_prepend_to "feed"` |
| ~~T9~~ | ~~Fehler-Tracking~~ | ✅ | Eingebaut im Admin-Dashboard — gruppierte Fehler, Stack Trace, Request-Kontext, resolve |
| ~~T10~~ | ~~Avatar Variant Caching~~ | ✅ | Named Variant `:thumb` mit `preprocessed: true` — Thumbnail wird nach Upload vorberechnet |

---

### Nächste Feature-Schritte (priorisiert)

| # | Feature | Aufwand | Beschreibung |
|---|---------|---------|--------------|
| ~~U3~~ | ~~Privates Profil~~ | ✅ | Follow-Requests, Accept/Decline, Notification bei Annahme |
| ~~X2a~~ | ~~Post-Assistent~~ | ✅ | ✦ improve-Button verbessert Draft per Claude API (Haiku) |
| ~~X2b~~ | ~~@claude Bot~~ | ✅ | antwortet auf @claude-Mentions via ClaudeBotJob |
| X2 | KI-Ausbau (offen) | Laufend | ✦ improve nur im Compose, nicht in Replies; @claude-Bot, Thread-Zusammenfassung, Smart Search, Content-Moderation — aktueller Stand nicht final |
| X2b | Thread-Zusammenfassung | ~1 Tag | Lange Threads auf Permalink-Seite zusammenfassen |
| X2c | Smart Search | ~2 Tage | Semantische Suche statt ILIKE via Embeddings |
| X2d | Content-Moderation | ~2 Tage | Automatisches Flaggen toxischer Posts via Claude API |
| ~~N4a~~ | ~~Basis-DMs~~ | ✅ | Inbox, Konversation, Real-time Turbo, Unread-Badge, `can_message?`-Permission |
| N4b | E2E-Verschlüsselung | Später | X25519 + AES-GCM, nur wenn Datenschutz-Anforderungen es rechtfertigen |
| ~~LP2~~ | ~~Link-Vorschau live nachladen~~ | ✅ | Turbo Stream broadcast nach LinkPreviewJob — kein Reload mehr nötig |
| I1 | iOS App | Später | Erst PWA, dann SwiftUI wenn Nutzerbasis es rechtfertigt |

### Interaktion & Content

| # | Feature | Aufwand | Beschreibung |
|---|---------|---------|--------------|
| ~~IC1~~ | ~~Repost/Boost~~ | ✅ | ⇄-Button; boost/unboost; Turbo Stream Live-Update |
| ~~IC2~~ | ~~Lesezeichen~~ | ✅ | ✦-Button; `/bookmarks`-Seite; Sidebar-Link |
| ~~IC3~~ | ~~Polls/Umfragen~~ | ✅ | 2–4 Optionen im Compose; Live-Balken per Turbo Stream |
| ~~IC4~~ | ~~Threads~~ | ✅ | "+ thread"-Button; verkettete Posts (reply-chain) |

### Entdecken

| # | Feature | Aufwand | Beschreibung |
|---|---------|---------|--------------|
| ~~DI1~~ | ~~Hashtags~~ | ✅ | `#thema` klickbar; `/tags/:tag`-Feed; after_save Extraktion |
| DI2 | Trending | ~2h | Meistgelikte/meistkommentierte Posts der letzten 24h; eigener Tab oder Widget |
| DI3 | Empfehlungen | ~1 Tag | "Leute die du kennen könntest" auf Basis gemeinsamer Follower |

### Profil

| # | Feature | Aufwand | Beschreibung |
|---|---------|---------|--------------|
| PR1 | Profil-Banner | ~2h | Hintergrundbild auf der Profilseite (ActiveStorage, ähnlich wie Avatar) |
| PR2 | Pinned Post | ~2h | Einen eigenen Post oben auf dem Profil fixieren; Pin/Unpin im Post-Menü |

### Moderation

| # | Feature | Aufwand | Beschreibung |
|---|---------|---------|--------------|
| MD1 | Melden | ~1 Tag | Posts und User melden; Meldungen im Admin unter eigenem Tab sichtbar; Status (offen/erledigt) |
| MD2 | Wort-Filter | ~2h | Bestimmte Begriffe aus dem eigenen Feed ausblenden (clientseitig, Settings) |

### Plattform & API

| # | Feature | Aufwand | Beschreibung |
|---|---------|---------|--------------|
| PA1 | RSS-Feed | ~2h | Öffentliche Posts per `/:username/feed.rss` abonnierbar |
| PA2 | REST-API | ~2 Tage | Öffentliche JSON-API für Posts, Profile, Feed — Grundlage für externe Clients |
| PA3 | ActivityPub | Später | Föderierung mit Mastodon & Co. — sehr aufwändig, erst bei Bedarf |

### Community & Wachstum

| # | Feature | Aufwand | Beschreibung |
|---|---------|---------|--------------|
| ~~GR1~~ | ~~Öffentlicher Feed~~ | ✅ | `/explore` — Posts ohne Login lesbar, Terminal-Stil, Stats + Register-CTA |
| ~~GR2~~ | ~~Open Graph / Link Preview~~ | ✅ | OG-Tags auf Post-Permalinks; Permalinks ohne Login erreichbar |
| ~~GR3~~ | ~~Invite-System~~ | ✅ | 5 Codes pro User (90 Tage), in Settings sichtbar, optionales Feld bei Registrierung |
| ~~GR4~~ | ~~Welcome-Bot~~ | ✅ | `@fl4re_bot` postet @mention nach jeder Registrierung |
| GR5 | Puma-Tuning | ~1h | Threads auf 8, `WEB_CONCURRENCY: 2` — verdoppelt parallele Request-Kapazität auf ~80 gleichzeitige User |
| GR6 | Push Notifications (geschlossene App) | ~2h | Service-Worker-Template-Bug fixen (`service-worker.js` → `service_worker.js`); Push-Handler liefert dann echte Notifications auch wenn fl4re komplett geschlossen ist (iOS 16.4+ PWA, Android) |

### Sicherheit (ausstehend)

#### Bekannte Findings aus Security Audit (April 2026)

**🔴 Critical — sofort beheben**

| # | Risiko | Aufwand | Datei | Maßnahme |
|---|--------|---------|-------|----------|
| SA-C1 | SSRF in LinkPreviewJob | ~2h | `app/jobs/link_preview_job.rb:8` | Interne IPs/Localhost blocken (`169.254.x`, `127.x`, `10.x`, `192.168.x`) vor `URI.open` |
| SA-C2 | Session-Cookie ohne `same_site` | ~30min | `app/controllers/registrations_controller.rb:19` | `same_site: :lax, secure: true` zum Cookie hinzufügen |
| SA-C3 | Reset-Token in Redirect-URL | ~30min | `app/controllers/passwords_controller.rb:25` | Bei Fehler `render :edit` statt `redirect_to` mit Token in URL |

**🟠 High — vor nächstem Release**

| # | Risiko | Aufwand | Datei | Maßnahme |
|---|--------|---------|-------|----------|
| SA-H1 | Stored XSS via Link-Preview OG-Tags | ~2h | `app/jobs/link_preview_job.rb` | OG-Werte durch `Rails::Html::SafeListSanitizer` filtern, Image-URL auf http/https prüfen |
| SA-H2 | Admin-Operationen ohne Passwort-Bestätigung | ~1 Tag | `app/controllers/admin/users_controller.rb` | Re-Auth für `toggle_admin` und `destroy` |
| SA-H3 | Reply auf private/geblockte Posts möglich | ~1h | `app/controllers/posts_controller.rb` | `visible_to?(Current.user)` vor Reply-Erstellung prüfen |
| SA-H4 | Kein Budget-Cap für Claude API | ~1h | `app/controllers/ai_controller.rb` | Globales Rate-Limit zusätzlich zum Per-User-Limit |

**🟡 Medium**

| # | Risiko | Aufwand | Datei | Maßnahme |
|---|--------|---------|-------|----------|
| SA-M1 | CSP-Nonce an Session-ID gebunden | ~15min | `config/initializers/content_security_policy.rb` | `SecureRandom.base64(16)` statt `session.id` |
| SA-M2 | Fehlende E-Mail-Format-Validierung | ~15min | `app/models/user.rb` | `validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }` |
| SA-M3 | Kein Rate-Limit auf Full-Text-Search | ~30min | `app/controllers/search_controller.rb` | `rate_limit to: 30, within: 1.minute` |
| SA-M4 | ActionCable Connection ohne User-Auth-Check | ~1h | `app/channels/application_cable/connection.rb` | `reject_unauthorized_connection` wenn kein gültiger User |
| SA-M5 | Login-Throttle ohne persistentes Blocken | ~1h | `config/initializers/rack_attack.rb` | Nach N Verstößen IP für 24h blocken |

**🟢 Low**

| # | Risiko | Aufwand | Datei | Maßnahme |
|---|--------|---------|-------|----------|
| SA-L1 | Invite-Token-Generator rekursiv | ~10min | `app/models/invite.rb` | `loop do ... break unless exists? end` statt Rekursion |
| SA-L2 | Poll-Option-Limit nur im Form, nicht im Model | ~15min | `app/models/post.rb` | `validate :poll_options_count` (max 4) |
| SA-L3 | Kein Login-Logging | ~30min | `app/controllers/concerns/authentication.rb` | IP + User-Agent bei Login loggen |
| SA-L4 | Kein Upload-Frequenz-Limit | ~30min | `app/models/post.rb` | Rate-Limit auf Create-Aktion mit Media |

**ℹ️ Info / Best Practices**

| # | Thema | Maßnahme |
|---|-------|----------|
| SA-I1 | Password-Mindestlänge (aktuell: 6) | Auf 12 Zeichen erhöhen |
| SA-I2 | `brakeman` + `bundler-audit` nur in dev | Auch im CD-Job (GitHub Actions) laufen lassen |
| SA-I3 | Keine Secrets-Rotation-Policy | VAPID, Anthropic, Brevo Keys quartalsweise rotieren |
| SA-I4 | Keine Dependency-Update-Routine | Regelmäßige `bundle update` mit `bundle audit check` |

---

**Bestehende Sicherheits-Features**

| # | Risiko | Aufwand | Maßnahme |
|---|--------|---------|----------|
| ~~S2~~ | ~~Admin-Audit-Log~~ | ✅ | Chronologisches Protokoll aller Admin-Aktionen im `> audit`-Tab |
| S3 | Kein 2FA | ~1 Tag | TOTP via `rotp` Gem |
| ~~S4~~ | ~~E-Mail-Verifikation~~ | ✅ | Token 24h, Banner + Resend, Token wird nach Verifikation ungültig |
| S5 | Passkey-Authentifizierung | ~2 Tage | Passwortlos einloggen via WebAuthn/FIDO2 (Face ID, Touch ID, Hardware-Key); `webauthn` Gem; als Alternative zum Passwort, nicht als Ersatz |

> Vollständige Dokumentation: [docs/security.md](docs/security.md)

---

### X2 — KI-Integration (Fortsetzung)

X2a (Post-Assistent) und X2b (@claude Bot) sind abgeschlossen ✅, aber der KI-Ausbau ist **nicht final** — der aktuelle Stand ist ein erster Schritt. Offene Punkte:

- ✦ improve erscheint nur im Haupt-Compose, nicht in Reply-Feldern
- Kein Feedback wenn Verbesserung schlechter ist als das Original
- @claude antwortet ohne Kontext (sieht nur den einzelnen Post, nicht den Thread)

Weitere geplante Features:

| # | Feature | Beschreibung | Aufwand |
|---|---------|--------------|---------|
| X2b | Thread-Zusammenfassung | Lange Threads auf Permalink-Seite zusammenfassen | ~1 Tag |
| X2c | Smart Search | Semantische Suche statt ILIKE via Embeddings | ~2 Tage |
| X2d | Content-Moderation | Automatisches Flaggen toxischer Posts via Claude API | ~2 Tage |

**Technischer Ansatz:** Claude API (Anthropic) · `anthropic` Gem (v1) · Stimulus-Controller

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
1. Erst PWA nutzen (bereits aktiv ✅) — für die meisten Nutzer ausreichend, kein App Store nötig
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
| `v0.8.0` | E-Mail via Brevo SMTP, Passwort-Reset, Login-Link |
| `v0.9.0` | In-App Notifications (N5), Push Notifications (N6), PWA Service Worker (M6) |
| `v0.9.1` | Teststrategie: 102 Tests, 252 Assertions — Models, Controller, Jobs vollständig abgedeckt |
| `v0.9.2` | Favicons: vollständiges favicon.io-Paket (ICO, PNG 16/32/180/192/512), manifest.webmanifest |
| `v0.9.3` | Like 500-Bugfix (Race-Condition), Follower/Following-Listen |
| `v0.9.4` | Privates Profil (U3), Live-Feed (T8), Mobile-Layout (einspaltig + Slide-in-Nav) |
| `v0.9.5` | @Mentions (verlinkt + Notification), Link Previews (OpenGraph async via LinkPreviewJob) |
| `v0.9.6` | KI-Post-Assistent (X2a, ✦ improve-Button via Claude Haiku), @claude Bot (X2b, ClaudeBotJob) |
| `v0.9.7` | PostgreSQL Full-Text Search (T6) — `websearch_to_tsquery` + GIN-Indexes statt ILIKE |
| `v0.9.8` | E-Mail-Verifikation (S4) — Token 24h, Banner + Resend, Auto-Invalidierung nach Bestätigung |
| `v0.9.9` | Avatar Variant Caching (T10) — Named Variant `:thumb` mit `preprocessed: true` |
| `v0.9.10` | Direkt­nachrichten N4a — Inbox, Konversation, Real-time, Unread-Badge, `can_message?` |
| `v0.9.11` | Bugfixes (Avatar-URL, Delete-Button), Inbox-Tabs, DM-Einstiegspunkte (Profilseite + New-Message-Formular) |
| `v0.9.11.1` | LP2 Link-Vorschau live via Turbo Broadcast, Test-Fix MessagesController |
| `v0.9.12` | Version-Link → GitHub CHANGELOG, @fl4re_bot postet Release-Ankündigungen bei Deploy |
| `v0.9.13` | T9 Error-Tracking im Admin — Rack-Middleware, gruppierte Fehler, Stack Trace, resolve |
| `v0.9.14` | S2 Admin-Audit-Log — `> audit`-Tab, User-/Post-Aktionen protokolliert |
| `v0.9.15` | Landing Page — Hero + Live-Stats + Feature-Liste + Register-CTA neben Login-Form |
| `v0.9.16` | Community-Wachstum — Öffentlicher Feed (/explore), OG-Tags, Invite-System (5 Codes/User), Welcome-Bot |
| `v0.9.17` | Interaktion — Repost/Boost, Lesezeichen, Polls, Threads, Hashtags (#tag → Feed) |
| `v0.9.17.1` | Mobile Fixes — Service Worker cacht kein HTML mehr (CSRF-Fix), Toggle-Controller `toggle()`-Methode ergänzt (DM-Inbox) |
| `v0.9.17.2` | Mobile Fix 2 — SW reload nach Aktivierung (stale CSRF in aktiven Tabs), Tests für Boost/Bookmark/Vote (169 Tests, 440 Assertions) |
| `v0.9.17.3` | Mobile Fix 3 — SW Caching komplett entfernt; nur noch Push Notifications. client.navigate() funktionierte auf iOS Safari PWA nicht → Posting weiterhin kaputt. Root fix: kein Cache = kein stale CSRF. |
| `v0.9.17.4` | Mobile Fix 4 — Compose-Form Turbo deaktiviert (iOS PWA silent fail), Form-Footer CSS space-between fix (Post-Button war auf Mobile nicht zuverlässig tappbar) |
