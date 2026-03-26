# Microblog — Roadmap

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

---

## In Arbeit 🔧

| # | Feature | Branch |
|---|---------|--------|
| — | Code-Cleanup (tote Dateien, Gem-Bereinigung) | feature/code-cleanup |

---

## Geplant 📋

### Nächste Schritte (priorisiert)

| # | Feature | Aufwand | Beschreibung |
|---|---------|---------|--------------|
| U3 | Privates Profil | ~1–2 Tage | Profil auf privat stellen, Follower-Anfragen mit pending-Status |
| M6 | PWA / Service Worker | ~1 Tag | App-Icon auf Home-Screen, Vollbild, Offline-Fähigkeit |
| X2 | KI-Integration | ~1–3 Tage | Post-Assistent via Claude API (X2a), Smart Search (X2c) |
| N4 | E2E-DMs | ~3–5 Tage | Ende-zu-Ende-verschlüsselte Direktnachrichten (X25519 + AES-GCM) |
| I1 | iOS App | Später | Erst PWA, dann SwiftUI wenn Nutzerbasis es rechtfertigt |

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
microblog.datenkistchen.de
        │
  Cloudflare Tunnel (HTTPS automatisch)
        │
  Raspberry Pi 5
  ┌──────────────────────────┐
  │  Rails (Puma)  :4000     │
  │  PostgreSQL    :5432     │
  │  Redis         :6379     │
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
