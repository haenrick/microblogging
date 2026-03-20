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
| G4 | **E2E-verschlüsselte private Nachrichten** | Wochen |

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
