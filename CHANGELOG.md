# Changelog

Alle nennenswerten Änderungen werden hier dokumentiert.
Format: [Semantic Versioning](https://semver.org/) — `MAJOR.MINOR.PATCH`

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
