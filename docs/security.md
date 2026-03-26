# fl4re — Sicherheitskonzept

> Stand: März 2026

---

## Implementierte Maßnahmen

### Authentifizierung & Autorisierung

| Maßnahme | Implementierung | Status |
|----------|----------------|--------|
| Alle Routen hinter Login | `before_action :require_authentication` in `ApplicationController` | ✅ |
| Admin-Bereich geschützt | `Admin::BaseController` prüft `current_user.admin?` | ✅ |
| Eigene Posts only | `Current.user.posts.find_by!(public_id:)` — fremde Posts nicht manipulierbar | ✅ |
| Passwort-Hashing | `has_secure_password` mit bcrypt (cost factor 12) | ✅ |
| Session-Cookies | `httponly: true`, `same_site: :lax`, signiert | ✅ |
| Selbst-Follow/Block verhindert | Model-Validierung `no_self_follow` / `no_self_block` | ✅ |

### Eingabe-Validierung

| Maßnahme | Implementierung | Status |
|----------|----------------|--------|
| SQL Injection | ActiveRecord-Parameterisierung durchgehend | ✅ |
| XSS | ERB escaped automatisch, kein `html_safe` / `raw` im Einsatz | ✅ |
| CSRF | Rails-Standard (`csrf_meta_tags`, `authenticity_token`) | ✅ |
| Datei-Typ-Validierung | `validates :media, content_type:` — nur PNG/JPEG/GIF/WebP, max. 10 MB | ✅ |
| Post-Länge | `validates :content, length: { maximum: 280 }` | ✅ |
| Username-Format | Regex `/\A[a-z0-9_]{3,30}\z/` — nur sichere Zeichen | ✅ |

### Rate Limiting & Abuse-Schutz

| Maßnahme | Limit | Status |
|----------|-------|--------|
| Login pro IP | 10 Versuche / 20 Sekunden | ✅ Rack::Attack |
| Login pro E-Mail | 5 Versuche / 1 Minute | ✅ Rack::Attack |
| Registrierung pro IP | 5 Accounts / 1 Stunde | ✅ Rack::Attack |
| Posts/Replies pro User | 20 / 1 Minute | ✅ Rails rate_limit |
| Login (SessionsController) | 10 / 3 Minuten | ✅ Rails rate_limit |

### HTTP-Sicherheitsheader

| Header | Wert | Status |
|--------|------|--------|
| Content-Security-Policy | `default-src 'self'`, keine inline-Scripts ohne Nonce | ✅ |
| CSRF-Token | Automatisch in allen Forms | ✅ |
| Secure Cookies | Via Cloudflare HTTPS (TLS 1.3) | ✅ |

---

## Bekannte offene Punkte

| # | Risiko | Priorität | Maßnahme |
|---|--------|-----------|----------|
| S1 | Kein Account-Lockout nach X fehlgeschlagenen Logins | Mittel | Rack::Attack `blocklist` nach 20 Fehlversuchen |
| S2 | Admin-Vergabe nur per Console, kein Audit-Log | Mittel | Admin-Aktionen in separater Tabelle loggen |
| S3 | Kein 2FA / MFA | Niedrig | TOTP via `rotp` Gem (vor Public Launch) |
| S4 | Keine E-Mail-Verifikation bei Registrierung | Niedrig | Token-basierte Verifikation |
| S5 | Kein automatischer Session-Ablauf | Niedrig | Sessions nach X Tagen invalidieren |
| S6 | Avatar-Upload ohne Virenprüfung | Niedrig | Für Pi-Betrieb akzeptabel |

---

## Admin-Rechtevergabe

Admin-Rechte werden **ausschließlich per Rails Console** vergeben — nie über die App-Oberfläche durch andere Admins. Das verhindert privilege escalation durch kompromittierte Admin-Accounts.

```bash
# Auf dem Pi:
DB_HOST=localhost DB_USER=microblog DB_PASSWORD=microblog_dev bin/rails console
User.find_by(username: "dein_username").update!(admin: true)
```

**Wichtig:** Nur der Server-Betreiber mit SSH-Zugang kann Admin-Rechte vergeben.
Der Admin-Toggle in `/admin/users` kann bestehende Admins verwalten —
den **ersten Admin** muss man immer per Console setzen.

---

## Deployment-Sicherheit

| Maßnahme | Status |
|----------|--------|
| HTTPS via Cloudflare Tunnel (TLS 1.3) | ✅ |
| Firewall: nur Port 4000 lokal, kein direkter Internetzugang | ✅ |
| PostgreSQL nicht von außen erreichbar | ✅ |
| Redis nicht von außen erreichbar | ✅ |
| Secrets nie in Git | ✅ (ENV-Variablen) |
