# Changelog

Alle nennenswerten Änderungen werden hier dokumentiert.
Format: [Semantic Versioning](https://semver.org/) — `MAJOR.MINOR.PATCH`

---

## [0.5.1] — 2026-03-26

### Gefixt
- **Theme-Auswahl** — CSP blockierte den Inline-`<style>`-Block mit Theme-Variablen (fehlender Nonce); Theme-Wahl wird jetzt korrekt visuell übernommen und persistiert
- **Theme-Swatches** — Inline-`style`-Attribute auf Swatch-Spans durch CSS-Klassen ersetzt (CSP-konform); Farben sind jetzt für alle User sichtbar
- **README** — Datenbankpasswörter aus Deployment-Doku entfernt; Pi-Deployment referenziert jetzt `bin/start`

---

## [0.5.0] — 2026-03-26

### Neu
- **User Preferences** — erweiterbare Einstellungen als JSONB-Spalte (`preferences`) auf dem User-Model
- **Enter-to-post** — erste Preference: Enter-Taste zum Posten ein-/ausschaltbar in den Settings
- **CSP-Fix** — Inline-Script in `application.html.erb` erhält korrekten Nonce (war durch Content Security Policy blockiert)
- **Styleguide** — `docs/styleguide.md` ins Repo übernommen und für fl4re angepasst (Themes, Terminal-Sprache)

---

## [0.4.0] — 2026-03-26

### Infrastruktur
- **Production-Mode** — `bin/start` lädt `.env`, startet standardmäßig mit `RAILS_ENV=production`
- **assume_ssl** — aktiviert für Cloudflare-Tunnel-Betrieb (HTTPS-Header korrekt)
- **systemd-Service** — Template in `config/fl4re.service` für Auto-Restart + Boot-Start
- **bin/backup** — Backup-Script für täglichen `pg_dump` mit automatischer Rotation
- **.env.example** — vollständige Vorlage für Umgebungsvariablen inkl. `RAILS_MASTER_KEY`

### Optimierungen
- **T1 Redis eliminiert** — `solid_cable` in Production aktiv, Redis-Container aus docker-compose entfernt
- **T2 delete_all** — `PurgeExpiredPostsJob` nutzt `delete_all` statt `destroy_all` (direkte DB-Deletion)
- **Mailer-Host** — auf `fl4re.datenkistchen.de` gesetzt (Passwort-Reset-Links korrekt)

---

## [0.3.2] — 2026-03-26

### Neu
- **Turbo Streams** — Like-Button aktualisiert sich ohne Seitenreload (nur Zähler + Farbe wechselt)
- **Stimulus Toggle-Controller** — Reply- und Edit-Button nutzen jetzt Stimulus statt inline-onclick (CSP-konform)

### Gefixt
- **Reply-/Edit-Button reagierte nicht** — inline `onclick` wurde von Content Security Policy blockiert
- **Block-Button ohne Design** — `btn-danger` hatte keine Basis-CSS-Definition, nur einen Hover-State

### Infrastruktur
- `importmap-rails` wieder hinzugefügt (wird von `turbo-rails` + `stimulus-rails` benötigt)
- Stimulus-Controller-Setup: `app/javascript/controllers/`
- Like-Actions-Partial `_post_actions.html.erb` extrahiert für Turbo-Stream-Targeting

---

## [0.3.1] — 2026-03-26

### Gefixt
- **Routing-Konflikt** — `/admin` wurde von `/:username`-Route abgefangen; Admin-Namespace jetzt vor Wildcard-Route, Username-Constraint schließt `admin` aus
- **Media-Validierung** — `ContentTypeValidator` (benötigt nicht installiertes Gem) durch native `validate`-Methode ersetzt
- **Server-Binding** — Puma lauschte nur auf `localhost`; `bin/start` bindet jetzt auf `0.0.0.0`
- **Datenbank-Name** — `DB_NAME` ENV-Variable für Pi-Deployment ohne Rename (default: `fl4re_development`)
- **Gemfile** — `importmap-rails`, `jbuilder`, `capybara`, `selenium-webdriver` entfernt (Überbleibsel aus Scaffold)

---

## [0.3.0] — 2026-03-26

### Neu
- **Rack::Attack** — Brute-Force-Schutz: Login 10/20s pro IP, 5/min pro E-Mail, Registrierung 5/h pro IP
- **Rate Limiting Posts** — max. 20 Posts/Replies pro Minute pro User
- **Datei-Validierung** — Media-Uploads: nur PNG/JPEG/GIF/WebP, max. 10 MB (serverseitig)
- **Content Security Policy** — CSP-Header aktiv, schützt gegen XSS
- **Sicherheitsdokumentation** — `docs/security.md` mit vollständigem Überblick
- **Roadmap** — Sicherheits-Backlog mit offenen Punkten (S1–S5)

---

## [0.2.0] — 2026-03-26

### Neu
- **Admin-Konsole** (`/admin`) — Dashboard mit Statistiken, User-Verwaltung (make/revoke admin, löschen), Post-Moderation
- **Admin-Rolle** — `admin: boolean` auf User, Admin-Link in Sidebar (nur für Admins sichtbar)
- **Umbenennung** — Projekt heißt jetzt **fl4re** (vorher: Microblog)

### Gefixt
- Registrierung war durch `require_authentication` blockiert — neue User konnten sich nicht anmelden
- `stale_when_importmap_changes` entfernt (Projekt nutzt Propshaft, nicht Importmap)
- RuboCop: doppeltes Leerzeichen in routes.rb

### Infrastruktur
- `db/schema.rb` hinzugefügt (fehlte, CI konnte DB nicht aufbauen)
- CI: `scan_js` und `system-test` Jobs entfernt
- Code-Cleanup: tote Scaffold-Views, `importmap-rails` / `jbuilder` / `capybara` aus Gemfile entfernt
- Fehlende CSS-Klassen ergänzt
- Tests für `DiscoverController`, `BlocksController`, `ProfilesController#change_password/destroy`
- Roadmap vollständig überarbeitet

---

## [0.1.0] — 2026-03-25

### Neu
- **Rails-Migration** — vollständiger Wechsel von PocketBase + Vanilla JS zu Ruby on Rails 8.1
- **Authentifizierung** — Rails 8 built-in Auth (has_secure_password, Sessions)
- **Posts** — erstellen, löschen, bearbeiten ("edited"-Kennzeichnung), Permalink (random public_id)
- **Ephemeral Posts** — 30-Tage-Ablauf mit Countdown-Badge (fresh/aging/critical), Auto-Purge via Solid Queue
- **Replies** — verschachtelte Antworten
- **Likes** — mit Counter-Cache
- **Follow-System** — folgen/entfolgen, Following-Feed-Tab
- **Blockieren** — Block/Unblock, Feed-Filter, Follow-Guard
- **Suche** — Posts und User (ILIKE)
- **User-Discover** — User-Grid mit Follow-Button
- **Profile** — Avatar (ActiveStorage), Bio, Profilseite
- **Terminal-Themes** — 6 Farbthemen (green, amber, purple, pink, cyan, white)
- **Registrierung** — Terminal Boot-Aesthetic Signup-Seite
- **Settings** — Passwort ändern, Account löschen
- **Zeichenzähler** beim Verfassen
- **Versionsnummer** in Sidebar-Footer
- **DIVIDE Styleguide** — JetBrains Mono, neon green `#00ff88` auf schwarz

---

<!-- Template für neue Einträge:

## [X.Y.Z] — YYYY-MM-DD

### Neu
-

### Geändert
-

### Gefixt
-

### Entfernt
-

-->
