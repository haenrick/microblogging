# Changelog

Alle nennenswerten Änderungen werden hier dokumentiert.
Format: [Semantic Versioning](https://semver.org/) — `MAJOR.MINOR.PATCH`

---

## [0.9.11.1] — 2026-04-07

### Neu
- **LP2 Link-Vorschau live** — Nach Abschluss des `LinkPreviewJob` wird die OpenGraph-Card per `Turbo::StreamsChannel.broadcast_replace_to` in den Feed und die Permalink-Seite nachgeliefert — kein Reload mehr nötig

### Fixes
- `MessagesControllerTest` auf `params[:content]` angepasst (war nach params-Änderung in v0.9.11 rot)

### Technisch
- `_link_preview.html.erb` als eigenes Partial extrahiert (war inline in `_post.html.erb`)
- `dom_id(post, :link_preview)` als stabiles Broadcast-Target
- Broadcast an `"feed"` (Feed-Seite) und `"post_#{post.public_id}"` (Permalink)
- `turbo_stream_from "post_#{@post.public_id}"` in `posts/show.html.erb`
- 160 Tests, 414 Assertions

---

## [0.9.11] — 2026-04-07

### Neu
- **DM-Einstiegspunkte** — „// message"-Button auf Profilseiten (sichtbar wenn `can_message?` true); „// new message"-Formular in der Inbox mit Select aller anschreibbaren Follower
- **Inbox-Tabs** — Notifications und Messages zu einer gemeinsamen Inbox zusammengefasst; Tab-Bar wie beim Feed; Sidebar zeigt nur noch einen `> inbox`-Link mit kombiniertem Unread-Badge

### Fixes
- **Avatar-Fragezeichen in Posts** — `action_controller.default_url_options` fehlte; Turbo-Broadcasts generierten ActiveStorage-URLs mit `host: localhost`, die im Fragment-Cache landeten und im Browser ungültig waren
- **T10 reaktiviert** — Named Variant `:thumb` mit `preprocessed: true` nach Behebung des obigen Bugs wieder aktiv
- **Delete-Button in Post-Edit** — `button_to` war in `form_with` verschachtelt (ungültiges HTML); Browser ignorierte das innere Form; Delete-Button jetzt außerhalb des Edit-Forms

### Technisch
- `config.action_controller.default_url_options` in `production.rb` gesetzt
- Route `GET /messages/new` → `messages#new_conversation` (vor `:username`-Catch-all platziert)
- `MessagesController#new_conversation` leitet zu Konversationsseite weiter
- `MessagesController#create` nutzt `params[:content]` statt `params[:message][:content]` (Form ohne Model-Scope)
- CSS: `.new-message-bar`, `.new-message-select-form`, `.select-input`, `.tab-action`

---

## [0.9.10] — 2026-04-07

### Neu
- **N4a Direkt­nachrichten** — 1:1-DMs zwischen Usern; Inbox-Übersicht mit letzter Nachricht und Unread-Dot; Konversations-Ansicht mit Real-time via Turbo Streams (Solid Cable); `> messages`-Eintrag in Sidebar + Mobile-Nav mit Unread-Badge
- Permission-Regel: Du kannst User X anschreiben, wenn X dir folgt; zentralisiert in `user.can_message?(target)` — leicht anpassbar ohne Controller/View-Änderungen
- Geblockte User können sich nicht anschreiben; Nachrichten werden beim Öffnen als gelesen markiert

### Technisch
- `messages`-Tabelle: `sender_id`, `recipient_id`, `content`, `read_at` + Foreign Keys + Indexes
- `Message#broadcast_to_recipient` via Turbo Streams zu `"messages_#{recipient_id}"`
- `DISTINCT ON`-SQL-Query für Inbox (eine Zeile pro Konversationspartner, neueste Nachricht)
- Routes vor `/:username`-Catch-all platziert (Routing-Konflikt vermieden)
- 18 neue Tests; gesamt: 159 Tests, 411 Assertions

---

## [0.9.9] — 2026-04-07

### Technisch
- **T10 Avatar Variant Caching** — Named Variant `:thumb` mit `preprocessed: true`; Thumbnail (100×100) wird nach jedem Avatar-Upload automatisch via `ActiveStorage::PreprocessImageVariantsJob` vorberechnet; kein on-demand Rendering mehr; kein extra Gem, keine Migration

---

## [0.9.8] — 2026-04-07

### Neu
- **S4 E-Mail-Verifikation** — Nach der Registrierung wird eine Bestätigungs-Mail gesendet (Brevo SMTP); Token läuft nach 24h ab und wird nach Verifikation invalidiert; Banner im App-Layout mit "Mail erneut senden"-Button für unverified User; `EmailVerificationMailer` im fl4re-Stil

### Technisch
- `users.email_verified_at` (datetime, nullable)
- `generates_token_for :email_verification, expires_in: 24h` im User-Model (mit `email_verified_at` als Digest — Token wird nach Verifikation automatisch ungültig)
- `EmailVerificationsController#show` (öffentlich) + `#create` (resend, requires auth)
- Routes: `GET /verify-email/:token`, `POST /verify-email/resend`
- 6 neue Tests; gesamt: 141 Tests, 373 Assertions

---

## [0.9.7] — 2026-04-07

### Technisch
- **T6 PostgreSQL Full-Text Search** — Post- und User-Suche nutzt jetzt `tsvector`/`websearch_to_tsquery` statt `ILIKE`; GIN-Indexes auf `posts.content` und `users.username+bio` für indexierbare, relevantere Volltextsuche
- `websearch_to_tsquery('simple', ?)` unterstützt natürliche Suchsyntax (`wort1 wort2` = AND, `"phrase"`, `-ausschließen`)
- Dictionary `simple` (nur Lowercasing) statt `english` — sprachunabhängig, kein unerwartetes Stemming
- 4 neue Search-Controller-Tests; gesamt: 135 Tests, 340 Assertions

---

## [0.9.6] — 2026-04-03

### Neu
- **✦ Post-Assistent (X2a)** — Button im Compose-Bereich verbessert den Draft-Text per Claude API (Haiku); rate-limited auf 10 Requests/Minute
- **@claude Bot (X2)** — `@claude` in einem Post triggert eine Antwort via `ClaudeBotJob`; kein Notifications-Spam für den Bot-User; Bot-Account wird per `db/seeds.rb` angelegt

### Technisch
- `gem "anthropic"` hinzugefügt
- `AiController#suggest` — POST `/ai/suggest`, JSON-Response
- `ClaudeBotJob` — async, toleriert API-Fehler
- Stimulus `ai-assist-controller` — fetch → textarea update
- `db/seeds.rb` — `@claude` User idempotent anlegen
- 131 Tests, 329 Assertions

### Setup
- `ANTHROPIC_API_KEY=sk-ant-...` in `.env` auf dem Pi setzen
- `bin/rails db:seed` ausführen (einmalig, idempotent)

---

## [0.9.5] — 2026-04-03

### Neu
- **@Mentions** — `@username` in Posts und Replies wird als klickbarer Link gerendert; erwähnte User erhalten eine Mention-Notification; Doppelbenachrichtigung bei Replies (Reply + Mention) wird unterdrückt; max. 5 Mentions pro Post
- **Link Previews** — Posts mit URLs zeigen nach dem Speichern automatisch eine Vorschau-Card (Titel, Beschreibung, Bild, Site-Name) via OpenGraph; wird asynchron per `LinkPreviewJob` geladen; kein extra Gem nötig

### Technisch
- `posts.link_preview` jsonb-Spalte für OG-Daten
- `Notification::TYPES` um `"mention"` erweitert
- `LinkPreviewJob` nutzt `Nokogiri` + `URI.open` (stdlib); toleriert Netzwerkfehler
- `render_post_content` Helper escaped content sicher und linkt @mentions
- 31 Tests, 59 Assertions

---

## [0.9.4] — 2026-04-01

### Neu
- **U3 Privates Profil** — Profil auf "privat" stellen in den Settings; Follow-Button wird zu "Request"; Besitzer sieht offene Anfragen mit Accept/Decline direkt auf der Profilseite; nicht-Follower sehen keine Posts; Benachrichtigung erst bei Annahme
- **T8 Live-Feed** — Neue Posts erscheinen sofort im "All"-Tab ohne Seitenreload via Turbo Broadcast; Posts von privaten Profilen werden nicht gesendet
- **Mobile Layout** — Sidebar auf kleinen Screens ausgeblendet; sticky Kopfzeile mit Logo, Notification-Badge und Avatar-Button; Klick auf Avatar öffnet ein Slide-in-Navigationsmenü (Stimulus `mobile-nav`); `main-content` nutzt die volle Breite

### Technisch
- `users.private_profile` boolean (default: false); `follows.status` string (default: "accepted")
- `Follow#after_update_commit` sendet Notification wenn pending → accepted
- `Post#after_create_commit` broadcasted zu `"feed"` Kanal (nur public, nur top-level)
- nil-sichere Cache-Keys und `Current.user`-Guards in `_post`- und `_post_actions`-Partials

---

## [0.9.3] — 2026-04-01

### Bugfix
- **Like 500-Fehler behoben** — Race-Condition bei Doppelklick/-tap (Safari): `ActiveRecord::RecordNotUnique` wird jetzt abgefangen; die Aktion gibt immer den aktuellen Zustand per Turbo Stream zurück statt einem 500-Fehler

### Neu
- **Follower-/Following-Listen** — Klick auf "Followers" oder "Following" auf jedem Userprofil öffnet eine dedizierte Listenseite (`/:username/followers`, `/:username/following`) mit Avatar, Username, Bio-Preview und Follow/Unfollow-Button (analog Discover-Seite); Stats in der Profilheader-Zeile sind jetzt klickbare Links

---

## [0.9.2] — 2026-03-31

### Assets
- **Favicons** — vollständiges favicon.io-Paket eingebunden: `favicon.ico` (16+32px), `favicon-16x16.png`, `favicon-32x32.png`, `apple-touch-icon.png` (180×180), `android-chrome-192x192.png`, `android-chrome-512x512.png`
- **PWA-Manifest** — `manifest.webmanifest` mit korrektem `name`/`short_name` ("fl4re"), passenden Icon-Pfaden und `theme_color`/`background_color` #000000
- **Layout** — `<head>` referenziert jetzt spezifische Favicon-Größen statt generischem `icon.png`

---

## [0.9.1] — 2026-03-31

### Tests & Qualität
- **Teststrategie** — vollständige Testabdeckung eingeführt; 102 Tests, 252 Assertions, 0 Failures (Baseline: 29 Tests)
- **Model-Tests** — `User`, `Post`, `Follow`, `Like`, `Notification`, `PushSubscription`: Validierungen, Callbacks, Business-Logik
- **Controller-Tests** — `NotificationsController`, `PushSubscriptionsController`, `BlocksController` neu; `PostsController` um Like/Reply/Destroy-Tests erweitert
- **Job-Tests** — `PurgeExpiredPostsJob` (löscht abgelaufene, lässt aktive, idempotent) und `SendPushNotificationJob` (Push-Versand, expired Subscription Cleanup)
- **Fixtures** — erweitert: 3 User, 4 Posts (inkl. Reply + Expired), Likes, Notifications, PushSubscriptions
- **`stub_method`-Helper** — in `test_helper.rb` für minitest 6 (kein `minitest/mock` mehr verfügbar)
- **Dokumentation** — `docs/testing.md` mit Teststrategie, Konventionen und Anleitung

### Bugfix
- `PushSubscriptionsController#destroy` nutzt jetzt numerische ID statt Endpoint-URL als Pfad-Segment

---

## [0.9.0] — 2026-03-31

### Neu
- **N5 In-App Notifications** — Notification-Model (polymorphic) für drei Events: Like auf eigenen Post, neuer Follower, Reply auf eigenen Post; kein Self-Notify; Badge in der Sidebar mit ungelesener Anzahl; Notifications-Feed unter `/notifications` mit Auto-Mark-Read beim Öffnen; "clear all"-Aktion
- **Real-time Badge** — Turbo Broadcast aktualisiert den Badge sofort ohne Seitenreload (solid_cable, kein Redis)
- **N6 Push Notifications** — Browser-/OS-Benachrichtigungen auch wenn fl4re geschlossen ist; Web Push API mit VAPID; Opt-in per Browser-Permission-Dialog; `web-push` Gem; `SendPushNotificationJob` mit automatischem Cleanup abgelaufener Subscriptions
- **M6 PWA Service Worker** — aktiver Service Worker unter `/service-worker.js`; Offline-Cache für Assets (Cache-first); Push-Handler + notificationclick-Navigation (vervollständigt M6, Basis-Manifest war bereits in v0.6.0)

### Infrastruktur
- VAPID-Keys werden auf dem Server generiert und in `.env` gesetzt — kein Secret landet im Repository
- `action_text-trix` auf 2.1.18 aktualisiert (XSS-Fix GHSA-53p3-c7vp-4mcc)

---

## [0.8.0] — 2026-03-29

### Neu
- **T3 E-Mail via Brevo** — ActionMailer über Brevo SMTP konfiguriert; Passwort-Reset funktioniert in Production; Absender: `noreply@fl4re.datenkistchen.de`; SMTP-Credentials via `BREVO_SMTP_USER` + `BREVO_SMTP_KEY` in `.env`
- **Mail-Template** — fl4re-Terminal-Stil (schwarz/neongrün) für HTML-Mails, Plaintext-Fallback

---

## [0.7.0] — 2026-03-29

### Gefixt
- **Post-Edit speicherte nicht** — `form_with url:` ohne Model-Objekt generierte `name="content"` statt `name="post[content]"`, `params.require(:post)` fand nichts; auf `form_with model: post` umgestellt
- **Theme-Wechsel erst nach Reload sichtbar (Safari)** — Turbo-Page-Cache restaurierte alten DOM-Snapshot mit altem `<style>`-Tag; neuer `theme_controller.js` setzt CSS-Variablen sofort per JS beim Klick auf einen Swatch — kein Reload mehr nötig, funktioniert als Live-Preview
- **Likes und Replies nach Reload weg** — Fragment-Cache hatte keinen Mechanismus zur Invalidierung bei Like/Reply-Änderungen; `touch: true` auf `Like→Post` und `Reply→Parent-Post` sorgt dafür dass `updated_at` sich ändert und der Cache-Key automatisch bricht
- **Fragment Cache zeigte veraltete Zeitangaben** — `time_ago_in_words` und `expiry_label` wurden dauerhaft gecacht; `expires_in: 1.hour` begrenzt die maximale Staleness

### Neu
- **T5 Fragment Caching** — `_post.html.erb` wrapped in `cache [post, Current.user.id]`; Cache invalidiert automatisch bei Post-Update (cache_key_with_version)
- **S1 Account-Lockout** — Rack::Attack throttelt Login-Versuche zusätzlich auf 20/Stunde pro IP (war vorher nur 10/20s und 5/min)
- **D3 GitHub Actions Deploy** — Deploy-Job in `ci.yml`; läuft nach scan_ruby + lint + test, nur auf `main`, via `bin/deploy` auf dem self-hosted Pi-Runner

### Hinweis D3
Der Deploy-Job setzt einen **Self-hosted Runner auf dem Pi** voraus. Einmalig einrichten: GitHub → repo Settings → Actions → Runners → „New self-hosted runner" → Anweisungen für Linux/ARM64 folgen → als systemd-Service registrieren.

---

## [0.6.0] — 2026-03-29

### Neu
- **T4 Stimulus PostForm-Controller** — Zeichenzähler, Datei-Upload-Label und Enter-to-Post aus globalem Inline-`<script>` in einen dedizierten Stimulus-Controller (`post_form_controller.js`) ausgelagert; Layout hat nun kein Inline-JavaScript mehr
- **M6 PWA-Basis** — `manifest.webmanifest`-Route + `PwaController`, fl4re-Daten in `manifest.json.erb` (Name, Farben, Beschreibung), `apple-touch-icon` + `<link rel="manifest">` im Layout

### Sicherheit
- **T7 Admin-Hierarchie** — Admins können andere Admins weder löschen noch degradieren; verhindert versehentliche oder böswillige Rechte-Eskalation
- **S5 Session-Ablauf** — Sessions laufen serverseitig nach 30 Tagen ab (`expires_at`-Spalte + Index); abgelaufene Sessions werden beim nächsten Request automatisch ignoriert

### Infrastruktur
- **docker-compose.yml** — Postgres-Port nur noch auf `127.0.0.1` gebunden (kein externer Zugriff), Memory-Limits gesetzt; Redis-Service endgültig entfernt (war nach v0.4.0 fälschlicherweise wieder hinzugefügt worden)

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
