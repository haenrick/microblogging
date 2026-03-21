# Changelog

## 2026-03-21

### Features
- **User Settings Drawer** — Slide-in Panel (Klick auf `@username` im Header). Ermöglicht: Anzeigename + E-Mail ändern, Passwort ändern, Account löschen.
- **Hashtags (Q5)** — `#tag` im Post-Inhalt wird als klickbarer Link gerendert und öffnet den Suchfilter.
- **Post bearbeiten (Q6)** — Eigene Posts können inline bearbeitet werden (Stift-Icon). Bearbeitete Posts zeigen ein `(bearbeitet)`-Badge.
- **Mention-Autocomplete (M3)** — `@name` beim Schreiben zeigt ein Dropdown mit passenden Usern aus PocketBase.
- **Enter zum Posten** — `Enter` schickt den Post ab, `Shift+Enter` erzeugt einen Zeilenumbruch.

### Bugfixes
- **Posts-Sortierung repariert** — Neue Posts erscheinen jetzt oben. Root Cause: Die `posts`-Collection hatte keine `created`/`updated`-Felder (wurden beim Erstellen nie angelegt). Behoben durch:
  1. `ALTER TABLE posts ADD COLUMN created/updated` in SQLite
  2. Collection-Definition in `_collections` aktualisiert
  3. Sort im Frontend von `sort: '-id'` (zufällige IDs, nicht zeitgeordnet) auf `sort: '-created'` umgestellt
- **PocketBase Auto-Cancellation** — `requestKey: null` verhindert, dass gleichzeitige `loadPosts()`-Aufrufe sich gegenseitig canceln.
- **`created` ging beim Object-Spread verloren** — PocketBase SDK gibt `created`/`updated` als Prototyp-Getter zurück. Beim Spread `{ ...r }` gehen Getter verloren. Fix: explizit `created: r.created, updated: r.updated` kopieren.

### Offen / Für Pi-Deployment merken
Die SQLite-Migration für `created`/`updated` muss auf dem Pi manuell nachgezogen werden:
```sql
ALTER TABLE posts ADD COLUMN created TEXT NOT NULL DEFAULT '';
ALTER TABLE posts ADD COLUMN updated TEXT NOT NULL DEFAULT '';
UPDATE posts SET created = strftime('%Y-%m-%d %H:%M:%S.000Z', 'now'), updated = strftime('%Y-%m-%d %H:%M:%S.000Z', 'now') WHERE created = '';
```
Außerdem muss die `_collections`-Tabelle um die `autodate`-Felddefinitionen für `created`/`updated` ergänzt werden.
