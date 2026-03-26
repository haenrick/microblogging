# AnonBlog — Projektanalyse & Entwicklungs-Roadmap

> Stand: März 2026

---

## Teil 1: Architektur-Analyse

### State Management

Vollständig imperativ, kein Framework. Drei globale Variablen:

```js
let posts = [];          // Nested array (Top-Level-Posts + replies rekursiv)
let currentUser = null;  // { id: string } — 8-stellige UUID-Kurzform
let lastPostTime = 0;    // Timestamp für 10s Rate-Limit
```

Kein Reactive Layer, kein Diffing — jede Änderung löst einen vollständigen DOM-Rebuild aus (`feed.innerHTML = ''` + rekursiver Re-Render).

### Datenpersistenz

Ausschließlich `localStorage`:

| Key              | Inhalt                                      |
|------------------|---------------------------------------------|
| `anonblog_posts` | Kompletter Post-Tree als JSON               |
| `anonblog_user`  | `{ id: "abc12345" }` — bleibt dauerhaft     |
| `theme`          | `"dark"` / `"light"`                        |
| `post_draft`     | Textentwurf (auto-save bei jedem Keystroke) |

Cross-Tab-Sync via `BroadcastChannel('anonblog_sync')`: Jedes `savePosts()` broadcastet ein `UPDATE`, andere Tabs laden neu.

### Rendering-Strategie

HTML `<template>`-Element als Klon-Vorlage für Posts. Funktion `renderList(list, container, level)` arbeitet rekursiv und rendert Replies direkt in `.replies`-Container des Eltern-Posts. Unbegrenzte Verschachtelungstiefe möglich.

---

## Teil 2: Implementierte Features

- Anonyme Identität (kurze UUID, persistent)
- Posts erstellen (280-Zeichen-Limit, Char-Counter mit Warnung)
- Posts löschen (nur eigene)
- Likes / Unlikes (pro User via `likedBy`-Array)
- Nested Replies (inline Form, rekursives Rendering)
- Dark/Light Theme (mit System-Präferenz-Erkennung)
- Suche (Freitextfilter)
- Draft-Speicherung
- Rate Limiting (10s Cooldown)
- Cross-Tab-Sync via BroadcastChannel
- Toast-Benachrichtigungen
- Seed-Daten beim ersten Start
- "Alle löschen" mit Bestätigung

---

## Teil 3: Bugs & Technische Schulden

### Kritische Bugs

**1. Search filtert Replies falsch** (`renderFeed`, Zeile 646)
```js
if (searchQuery && !post.content.toLowerCase().includes(searchQuery)) {
    return; // Wird auf JEDER Ebene des rekursiven Renderings geprüft
}
```
- Wenn ein Top-Level-Post matcht, werden seine Replies trotzdem gefiltert — eine Reply die "hallo" enthält wird versteckt, wenn der Suchbegriff nur im Parent vorkommt.
- Wenn nur eine Reply matcht, wird sie nie angezeigt, weil der Parent-Post ausgeblendet wurde.

**2. Reply-Zähler zählt nur direkte Replies**
```js
replyBtn.querySelector('.count').textContent = post.replies ? post.replies.length : 0;
```
Zeigt nur die Anzahl direkter Kinder, nicht den gesamten Thread-Baum.

**3. Char-Counter zeigt "280" im leeren Zustand**
Leicht verwirrend: Der Counter erscheint sofort mit "280" auch wenn noch nichts geschrieben wurde. Besser: erst ab 1 Zeichen anzeigen oder ab einem Schwellenwert.

### Technische Schulden

**4. Vollständiger Re-Render bei jeder Interaktion**
Jedes Like, jede neue Reply, jeder Toggle löst `feed.innerHTML = ''` + kompletten Rebuild aus. Bei vielen Posts (>100) wird das spürbar.

**5. Unbegrenzte Verschachtelungstiefe**
Kein `maxDepth`-Check. Bei tiefer Verschachtelung (`level > 5`) würde das Layout durch `margin-left: 20px; border-left: 2px solid` stark einrücken und unleserlich werden.

**6. BroadcastChannel wird nie geschlossen**
Kein `channel.close()` bei `beforeunload`. Kleines Memory Leak.

**7. Kein Keyboard-Shortcut zum Posten**
`Cmd+Enter` fehlt — Standard-Erwartung bei Textfeldern in Social Apps.

**8. localStorage-Größenlimit**
~5 MB Limit. Bei vielen Posts mit langen Inhalten kann dies überschritten werden, ohne dass der User eine verständliche Fehlermeldung erhält.

**9. Theme-Icon ist ein generischer Kreis**
Das Toggle-Icon (Zeile 342) ist ein Kreis-Outline, kein Mond/Sonne. Funktioniert, ist aber nicht intuitiv.

**10. `cursor: pointer` auf `.post` ohne Click-Handler**
Suggeriert Klickbarkeit (z.B. für Detailansicht), aber kein Handler implementiert.

---

## Teil 4: Feature-Ideen (priorisiert)

### Quick Wins (wenig Aufwand, großer Impact)

| # | Feature | Aufwand | Nutzen |
|---|---------|---------|--------|
| Q1 | **Cmd+Enter zum Posten** | 5 min | Stark — Standard-Erwartung |
| Q2 | **Search-Bug fixen** (Replies durchsuchen, Parent anzeigen) | 30 min | Stark — aktuell kaputt |
| Q3 | **Sonne/Mond Icon** für Theme-Toggle | 10 min | Mittel — UX-Klarheit |
| Q4 | **Char-Counter erst ab 1 Zeichen** anzeigen | 5 min | Gering |
| Q5 | **Hashtag-Erkennung**: `#tag` im Post-Content als klickbarer Filter | 45 min | Mittel |
| Q6 | **Post bearbeiten** (Edit-Modus, timestamp "edited" setzen) | 1h | Mittel |
| Q7 | **Max-Depth-Limit** für Replies (z.B. 4 Ebenen), danach flach | 20 min | Mittel |
| Q8 | **localStorage-Fehlerbehandlung** (try/catch + Toast bei QuotaExceeded) | 20 min | Mittel |

### Mittelfristig (erfordert Architekturentscheidungen)

| # | Feature | Aufwand | Entscheidung |
|---|---------|---------|--------------|
| M1 | **Backend-Migration** (Self-Hosted, s. Teil 5) | 1–3 Tage | Stack-Wahl |
| M2 | **Echter User-Account-Flow** (Username wählbar, Password oder Passkey) | 1 Tag | Auth-Strategie |
| M3 | **Mentions (`@username`)** mit Inline-Autocomplete | 1 Tag | Braucht User-Registry |
| M4 | **Pagination / Virtual Scroll** statt alles rendern | 1 Tag | API oder cursor-based |
| M5 | **Bild-Upload** (File → Base64 → localStorage oder S3-kompatibel) | 2–4h | Storage-Limit beachten |
| M6 | **PWA + Service Worker** für Offline-Support | 1 Tag | Manifest + Cache-Strategie |
| M7 | **Reaktive Architektur** (state → diff-render statt full rebuild) | 2 Tage | Vanilla Signals oder kleines Framework |

### Große Features (eigenständige Projekte)

| # | Feature | Aufwand |
|---|---------|---------|
| G1 | **Mehrere Channels/Feeds** (Topics, Gruppen) | 1 Woche |
| G2 | **Medien-Feed** (nur Posts mit Bildern) | 2–3 Tage |
| G3 | **ActivityPub-Kompatibilität** (eigene Mini-Mastodon-Alternative) | Wochen |
| G4 | **E2E-verschlüsselte private Nachrichten** *(→ jetzt N1, siehe unten)* | Wochen |

---

## Teil 4b: Neue Features (hinzugefügt März 2026)

### N0 — Benutzerprofil (Avatar + Bio)

**Ziel:** Jeder User hat ein Profilbild und eine kurze Selbstbeschreibung.

**Datenbankschema:**
```
users (Erweiterung)
  bio        string (max. 160 Zeichen)
  avatar     ActiveStorage attachment
```

**Frontend:**
- Profilseite `/profile` — Avatar, Username, Bio, eigene Posts
- Einstellungsseite `/profile/edit` — Bio bearbeiten, Avatar hochladen
- Avatar-Thumbnail neben jedem Post im Feed

**Backend-Logik:**
- `has_one_attached :avatar` in `User`
- Bild-Resize via ActiveStorage Variant (100×100px)
- Fallback: Initials-Avatar wenn kein Bild gesetzt

**Abhängigkeiten:** Rails-Migration (erledigt), ActiveStorage (bereits in Rails enthalten)
**Aufwand:** ~1 Tag
**Priorität:** Mittel — verbessert Erkennbarkeit im Feed

---

### N1 — User abonnieren (Follow-System)

**Ziel:** Usern folgen und einen personalisierten Feed aus deren Posts sehen.

**Datenbankschema:**
```
follows
  id          (auto)
  follower    (relation → users)
  following   (relation → users)
  created     (auto)
```

**Frontend:**
- Profilkarte / Hover-Popup auf `@username` → "Folgen"-Button
- Separater Tab im Feed: "Alle" | "Abonniert"
- Follower-/Following-Zähler im User-Settings-Drawer

**Backend-Logik:**
- `POST /api/follows` — folgen
- `DELETE /api/follows/:id` — entfolgen
- `GET /api/feed/following` — Posts nur von gefolgten Usern, sortiert nach `-created`

**Abhängigkeiten:** M2 (Auth), PocketBase läuft bereits
**Aufwand:** ~1–2 Tage
**Priorität:** Hoch — Kernfeature für soziale Interaktion

---

### N2 — Platform-Migration: Ruby on Rails

**Ziel:** Den gesamten Stack (aktuell PocketBase + Vanilla-JS-Frontend) auf Ruby on Rails migrieren. Rails übernimmt Routing, Auth, Datenbank (PostgreSQL), Server-Side-Rendering und API.

**Warum Rails?**
- Convention over Configuration — schnelle Entwicklung ohne Boilerplate
- ActiveRecord + PostgreSQL: robustere Grundlage als PocketBase/SQLite für Wachstum
- Action Cable: WebSocket-Support für Realtime out-of-the-box
- Devise + Rodauth: ausgereifte Auth-Libraries
- Hotwire (Turbo + Stimulus): reaktives UI ohne schweres JS-Framework, passt zur bisherigen Vanilla-JS-Philosophie

**Migrations-Schritte:**
1. Rails-App anlegen (`rails new microblog --database=postgresql`)
2. Models: `User`, `Post` (mit `parent_id` für Replies), `Follow`, `Like`, `Block`, `Message`
3. Devise für Auth einrichten (Username, E-Mail, Passwort)
4. PocketBase-Daten per Rake-Task nach PostgreSQL migrieren
5. Turbo Streams für Realtime (ersetzt BroadcastChannel + PocketBase-SSE)
6. Frontend-JS in Stimulus-Controller überführen
7. Bestehende UI (CSS, Templates) übernehmen und auf ERB-Partials umstellen

**Breaking Changes:**
- PocketBase entfällt komplett
- Alle API-Calls werden zu Rails-Controllern
- Auth wechselt von PocketBase-Auth zu Devise

**Aufwand:** 3–5 Tage (sauber, mit Tests)
**Priorität:** Strategisch — alle anderen N-Features bauen idealerweise darauf auf

---

### N3 — User blockieren

**Ziel:** Andere User blockieren. Blockierte User können einem nicht mehr folgen, sehen eigene Posts nicht und erscheinen selbst nicht im Feed.

**Datenbankschema:**
```
blocks
  id        (auto)
  blocker   (relation → users)
  blocked   (relation → users)
  created   (auto)
```

**Verhalten:**
- Blockierter User sieht Posts des Blockers nicht (Feed-Filter)
- Blockierter User kann dem Blocker nicht mehr folgen (Follow-Endpunkt prüft Block-Relation)
- Bestehende Follow-Relation wird beim Blockieren automatisch aufgelöst
- Blockierter User kann keine DMs senden (s. N4)
- Block ist einseitig und still (kein Hinweis an den Blockierten)

**UI:**
- "..." Menü auf jedem Post/Profil → "Blockieren"
- Blockliste im User-Settings-Drawer verwaltbar

**Backend-Logik (Rails):**
- `before_action :check_blocked` in Feed-, Follow- und Message-Controllern
- Scope `Post.visible_to(current_user)` filtert blockierte User heraus

**Abhängigkeiten:** N2 (Rails), N1 (Follow-System)
**Aufwand:** ~1 Tag
**Priorität:** Mittel — wichtig für Safety, aber nach Follow sinnvoll

---

### N4 — Ende-zu-Ende-verschlüsselte Direktnachrichten (E2E-DMs)

**Ziel:** Private Nachrichten zwischen Usern, die der Server nie im Klartext sieht.

**Kryptographie-Ansatz: X25519 + AES-GCM (Web Crypto API)**

```
Schlüsselgenerierung (einmalig pro User, im Browser):
  const keyPair = await crypto.subtle.generateKey(
      { name: 'X25519' }, true, ['deriveKey']
  );
  // Public Key → Server speichern (öffentlich)
  // Private Key → localStorage (niemals den Server verlassen)

Nachricht verschlüsseln (Sender):
  const sharedKey = await crypto.subtle.deriveKey(
      { name: 'X25519', public: recipientPublicKey },
      senderPrivateKey, { name: 'AES-GCM', length: 256 }, false, ['encrypt']
  );
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const ciphertext = await crypto.subtle.encrypt(
      { name: 'AES-GCM', iv }, sharedKey, encode(plaintext)
  );
  // ciphertext + iv → Server

Nachricht entschlüsseln (Empfänger):
  const sharedKey = await crypto.subtle.deriveKey(
      { name: 'X25519', public: senderPublicKey },
      recipientPrivateKey, { name: 'AES-GCM', length: 256 }, false, ['decrypt']
  );
  const plaintext = await crypto.subtle.decrypt(
      { name: 'AES-GCM', iv }, sharedKey, ciphertext
  );
```

**Datenbankschema (Rails):**
```ruby
# messages
  id            (uuid)
  sender        (references users)
  recipient     (references users)
  ciphertext    (text)      # Base64-encoded verschlüsselter Inhalt
  iv            (text)      # Base64-encoded Initialization Vector
  created_at    (datetime)

# user_keys
  user          (references users)
  public_key    (text)      # Base64-encoded X25519 Public Key
```

**Sicherheits-Eigenschaften:**
- Server speichert ausschließlich Ciphertext + IV + Public Keys
- Private Keys verlassen nie den Browser (localStorage)
- Forward Secrecy: nicht eingebaut (statische Keys) — für spätere Version Signal-Protokoll möglich
- Blockierte User können keine Nachrichten senden (s. N3)

**UI:**
- DM-Icon in der Navigation → Posteingang
- Konversationsansicht pro User-Paar
- Schlüssel-Generierung automatisch beim ersten DM-Öffnen
- Warnung: "Private Key ist nur in diesem Browser gespeichert. Kein Recovery möglich."

**Risiken / Einschränkungen:**
- Kein Key-Recovery: verliert der User den Browser-Storage, sind alle DMs unlesbar
- Kein Multi-Device ohne Key-Export-Flow
- Key-Authentizität: kein Web-of-Trust, User könnte falschen Public Key akzeptieren (TOFU — Trust on First Use)

**Abhängigkeiten:** N2 (Rails), N3 (Block-Check)
**Aufwand:** 3–5 Tage (Crypto-Layer + UI + Tests)
**Priorität:** Groß — eigenständiges Projekt, nach Rails-Migration angehen

---

## Zusammenfassung: Empfohlene Reihenfolge (aktualisiert)

```
✅ [Q7] Max-Depth für Replies
✅ [N2] Rails-Migration                — Rails 8.1, PostgreSQL, Auth
✅ [N0] Benutzerprofil (Avatar + Bio)  — Avatar, Bio, Profilseite, Sidebar-Nav
✅ [Q1] Enter zum Posten               — Enter sendet, Shift+Enter = Zeilenumbruch
~~[D1] Hetzner CX22~~ → ersetzt durch Pi 5 + Cloudflare Tunnel
✅ [N1] Follow-System                  — Follow/Unfollow, Following-Feed-Tab
✅ [S1] Suche                          — Posts und User durchsuchen (ILIKE)
✅ [U1] Registrierung                  — Terminal Boot-Aesthetic Signup-Seite
✅ [N3] Blockieren                     — Block/Unblock, Feed-Filter, Follow-Guard
1. [S2] User-Discover                  — Alle User browsen ohne Username kennen zu müssen
2. [U2] Admin-Bereich                  — User verwalten, Posts moderieren, Rollen
3. [U3] Privates Profil                — User kann Profil auf privat stellen, Follower-Anfragen
4. [M6] PWA / Service Worker           — 1 Tag
5. [X1] Medien                         — Bilder & Videos in Posts einbetten
6. [X2] KI-Integration                 — KI-Features direkt in der App
7. [N4] E2E-DMs                        — 3–5 Tage, nach allem anderen
```

---

## Teil 4d: User-Verwaltung (hinzugefügt März 2026)

### U1 — Registrierung

**Ziel:** Neue User können sich selbst registrieren, ohne dass jemand per Console einen Account anlegen muss.

**Umfang:**
- Signup-Formular: Username, Email, Passwort
- Optional: Email-Bestätigung via Token (verhindert Fake-Accounts)
- Weiterleitung nach Registrierung direkt in den Feed
- Passwort-Anforderungen (min. 8 Zeichen)

**Aufwand:** ~2–3h
**Abhängigkeiten:** Auth (erledigt)

---

### U2 — Admin-Bereich

**Ziel:** Ein geschützter Bereich um die App zu verwalten ohne Rails Console.

**Umfang:**
- Admin-Rolle auf `User` (`admin: boolean`)
- Geschützter Bereich `/admin` (nur für Admins)
- User-Liste: einsehen, sperren, löschen
- Post-Moderation: anstößige Posts löschen
- Einfache Statistiken: Anzahl User, Posts, Likes

**Aufwand:** ~1 Tag
**Abhängigkeiten:** U1 (Registrierung)

---

### U3 — Privates Profil

**Ziel:** User können ihr Profil auf privat stellen. Posts sind dann nur für Follower sichtbar.

**Umfang:**
- `private_profile: boolean` auf `User`
- Follower-Anfragen statt direktem Follow (`pending` Status auf `Follow`)
- Anfragen annehmen / ablehnen auf Profilseite
- Nicht-Follower sehen nur Avatar + Bio, keine Posts

**Aufwand:** ~1–2 Tage
**Abhängigkeiten:** N1 (Follow-System, erledigt)

---

---

### X1 — Medien (Bilder & Videos)

**Ziel:** Nutzer können Bilder und Videos direkt in Posts hochladen oder verlinken.

**Umfang:**

- **Bilder:** Upload via ActiveStorage (wie Avatar), max. 10 MB, JPEG/PNG/GIF/WebP
- **Videos:** Upload kleiner Clips (max. ~50 MB) oder Einbettung externer Links (YouTube, Vimeo) via URL-Erkennung
- Vorschau im Feed (Bild direkt sichtbar, Video als Thumbnail mit Play-Button)
- Auf der Permalink-Seite vollständig dargestellt
- Optionale Bildkompression via libvips (bereits auf Pi installiert)

**Datenbankschema:**
```
posts (Erweiterung)
  media   ActiveStorage attachment (has_one_attached)
```

**Abhängigkeiten:** ActiveStorage (bereits eingerichtet), libvips (bereits auf Pi)
**Aufwand:** ~1 Tag
**Priorität:** Mittel — großer UX-Gewinn, technisch überschaubar

---

### X2 — KI-Integration

**Ziel:** KI-Features direkt in der App, die den Mehrwert für Nutzer erhöhen.

**Mögliche Features (Priorisierung offen):**

| # | Feature | Beschreibung |
|---|---------|--------------|
| X2a | **Post-Assistent** | KI schlägt Formulierungen vor oder verbessert den Entwurf auf Knopfdruck |
| X2b | **Auto-Zusammenfassung** | Lange Threads werden auf der Permalink-Seite zusammengefasst |
| X2c | **Smart Search** | Semantische Suche statt nur ILIKE — findet Posts nach Bedeutung, nicht nur Stichwort |
| X2d | **Content-Moderation** | Automatisches Flaggen von toxischen Posts (Unterstützung für U2 Admin-Bereich) |
| X2e | **Feed-Kuratierung** | KI gewichtet den Feed nach persönlichem Leseinteresse |

**Technischer Ansatz:**
- Claude API (Anthropic) — passt zum bestehenden Stack, kein eigenes Modell nötig
- Einfacher Einstieg: X2a (Post-Assistent) als Stimulus-Controller mit fetch → `/ai/suggest`
- Rails-Controller ruft Claude API auf, gibt Vorschläge zurück

**Abhängigkeiten:** Anthropic API Key, `anthropic-rb` Gem oder HTTP-Client
**Aufwand:** X2a ~1 Tag; X2c–X2e jeweils 2–3 Tage
**Priorität:** Hoch — starkes Differenzierungsmerkmal

---

## Teil 4c: Deployment — Raspberry Pi 5 + Cloudflare Tunnel

### Entscheidung: Pi statt Hetzner

Kein extra Server nötig. Der Pi 5 läuft bereits mit Docker und Cloudflare Tunnel (`datenkistchen.de`). Die Rails-App wird dort als vollständige Testumgebung betrieben.

**Stack:**

```
microblog.datenkistchen.de
        │
  Cloudflare Tunnel (HTTPS automatisch)
        │
  Raspberry Pi 5
  ┌─────────────────────────────┐
  │  Rails (Puma)     :3000     │
  │  PostgreSQL       :5432     │
  │  Redis            :6379     │
  │  (Docker Compose)           │
  └─────────────────────────────┘
```

**Kosten: €0/Monat** (Pi und Cloudflare-Account bereits vorhanden)

**Setup-Schritte (einmalig):**

1. Subdomain `microblog.datenkistchen.de` im Cloudflare Tunnel auf `localhost:3000` routen
2. `docker-compose.yml` für Rails + PostgreSQL + Redis anlegen
3. `docker compose up` — fertig

**Entwicklungs-Workflow:**

```bash
docker compose up          # App starten
docker compose run web rails console
docker compose run web rails db:migrate
docker compose logs -f
```

---

## Teil 5: Empfohlener nächster Schritt

### Empfehlung: Backend-Migration auf Self-Hosted Stack

**Warum genau dieser Schritt?**

Der `localStorage`-Ansatz ist das fundamentale Limit der App. Kein echtes Multi-User-Erlebnis, kein geräteübergreifendes Lesen, ~5 MB Datenlimit, keine Datensicherung. Mit einem Self-Hosted Backend auf dem bereits vorhandenen Raspberry Pi 5 mit Docker, PostgreSQL und Cloudflare Tunnel (datenkistchen.de) lassen sich alle anderen Features (Auth, Suche, Pagination, Medien) sauber darauf aufbauen.

**Was müsste technisch geändert werden?**

1. `loadPosts()` → `GET /api/posts` (fetch)
2. `savePosts()` → `POST /api/posts` oder `DELETE /api/posts/:id`
3. `toggleLike()` → `POST /api/posts/:id/like`
4. `currentUser` → JWT/Session statt localStorage-UUID
5. `BroadcastChannel` → Server-Sent Events (SSE) oder WebSocket für Live-Updates
6. `renderFeed()` bleibt unverändert — nur die Datenquelle ändert sich

**Betroffene Funktionen in index.html:**

- `loadPosts()` (Zeile 481)
- `savePosts()` (Zeile 495)
- `createPost()` (Zeile 528)
- `deletePost()` (Zeile 577)
- `toggleLike()` (Zeile 600)
- `init()` — User-Auth-Flow statt UUID

**Breaking Changes:** Ja — alle localStorage-Daten werden nicht migriert (oder einmalig als Seed importiert). Cross-Tab-Sync entfällt zugunsten von SSE/WebSocket.

---

## Teil 6: Self-Hosted Backend — Architektur-Skizze

### Empfehlung: PocketBase als Docker Container

PocketBase ist eine einzelne Go-Binary mit eingebautem SQLite, Admin-UI, REST-API, Realtime (SSE), Auth und File-Upload. Ideal für diesen Use Case: kein separates Backend-Framework, kein ORM, minimal Konfiguration.

**Warum nicht Express + PostgreSQL?**

PostgreSQL läuft bereits auf dem Pi — das wäre die "erwachsene" Lösung für späteres Wachstum. Aber für ein persönliches Microblogging-Projekt ist PocketBase erheblich schneller aufgesetzt und gewartet. **Wenn ActivityPub oder komplexe Queries geplant sind**, wäre ein Custom-Backend mit PostgreSQL die bessere Wahl.

### Stack-Entscheidungsmatrix

| | PocketBase | Express + PostgreSQL |
|---|---|---|
| Setup-Zeit | ~30 Min | ~3–4h |
| Auth out-of-the-box | Ja (inkl. OAuth) | Nein, selbst bauen |
| Realtime | Ja (SSE eingebaut) | Selbst implementieren |
| File Upload | Ja | Multer + Disk/S3 |
| Skalierung | SQLite-Limit (~TB) | Unbegrenzt |
| Admin-UI | Ja | Nein |
| ActivityPub-ready | Nein | Ja |

### Deployment-Plan für PocketBase auf dem Pi

```yaml
# docker-compose.yml
services:
  pocketbase:
    image: ghcr.io/muchobien/pocketbase:latest
    volumes:
      - ./pb_data:/pb/pb_data
    ports:
      - "8090:8090"
    restart: unless-stopped
```

Cloudflare Tunnel weiterleiten:
```
microblog.datenkistchen.de → localhost:8090
```

### PocketBase Collections

**posts**
```
id          (auto)
user        (relation → users)
content     (text, max 280)
parent_id   (relation → posts, optional)
likes       (number, default 0)
created     (auto)
updated     (auto)
```

**likes** (separate Collection für N:M statt Array)
```
user    (relation → users)
post    (relation → posts)
```

### Frontend-Änderung (Kernprinzip)

```js
// Vorher: localStorage
function loadPosts() {
    const raw = localStorage.getItem(STORE_KEY);
    posts = raw ? JSON.parse(raw) : [];
}

// Nachher: PocketBase SDK (1KB gzip)
import PocketBase from 'pocketbase';
const pb = new PocketBase('https://microblog.datenkistchen.de');

async function loadPosts() {
    const records = await pb.collection('posts')
        .getList(1, 50, {
            filter: 'parent_id = ""',
            expand: 'replies(parent_id)',
            sort: '-created'
        });
    posts = records.items;
}

// Realtime statt BroadcastChannel
pb.collection('posts').subscribe('*', () => loadPosts());
```

### Migrations-Strategie

1. PocketBase Docker Container aufsetzen, Admin-UI konfigurieren
2. Collections anlegen
3. Frontend auf PocketBase SDK umstellen (parallel zu localStorage, Feature-Flag)
4. Einmalige Migration: `localStorage`-Daten per Script in PocketBase importieren
5. localStorage-Code entfernen

---

## Zusammenfassung: Empfohlene Reihenfolge

```
1. [Q1] Cmd+Enter Shortcut          — 5 Min, sofortiger Komfort
2. [Q2] Search-Bug fixen            — 30 Min, Basisfunktion reparieren
3. [Q7] Max-Depth für Replies       — 20 Min, Layout-Schutz
4. [M1] PocketBase Backend          — 2–3 Tage, fundamentaler Schritt
5. [M2] Username-Wahl + Auth        — 1 Tag, baut auf Backend auf
6. [M3] Mentions (@username)        — 1 Tag, baut auf Auth auf
7. [M6] PWA / Service Worker        — 1 Tag, polished experience
```
