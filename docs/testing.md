# fl4re — Teststrategie

> Stand: v0.9.1 · 102 Tests · 252 Assertions · 0 Failures

---

## Philosophie

Drei Ebenen, nichts mehr:

```
Model-Tests       → Business-Logik, Validierungen, Callbacks
Controller-Tests  → HTTP-Flows, Auth-Guards, Status-Codes
Job-Tests         → Seiteneffekte (Push-Versand, Purge)
```

**Kein Mocking der Datenbank.** Tests laufen gegen echte PostgreSQL-Instanz — so wie es in Production läuft. System-Tests (Browser/Capybara) werden bewusst weggelassen: zu langsam, zu fragil, zu viel Aufwand für eine Single-developer App.

---

## Tests ausführen

```bash
DB_HOST=localhost DB_USER=microblog DB_PASSWORD=microblog_dev RAILS_ENV=test bin/rails test
```

Einzelne Datei:

```bash
DB_HOST=localhost DB_USER=microblog DB_PASSWORD=microblog_dev RAILS_ENV=test bin/rails test test/models/notification_test.rb
```

---

## Struktur

```
test/
├── test_helper.rb                         # Basis-Setup, stub_method-Helper
├── test_helpers/
│   └── session_test_helper.rb             # sign_in_as / sign_out
├── fixtures/
│   ├── users.yml                          # 3 User (admin, regular, third)
│   ├── posts.yml                          # 4 Posts (normal, normal, reply, expired)
│   ├── follows.yml                        # leer — Controller-Tests bauen direkt
│   ├── likes.yml                          # 1 Like (two→post one)
│   ├── notifications.yml                  # 3 Notifications (like unread, like read, follow)
│   └── push_subscriptions.yml             # 1 Subscription (user one)
├── models/
│   ├── user_test.rb
│   ├── post_test.rb
│   ├── follow_test.rb
│   ├── like_test.rb
│   ├── notification_test.rb
│   └── push_subscription_test.rb
├── controllers/
│   ├── sessions_controller_test.rb
│   ├── registrations_controller_test.rb
│   ├── passwords_controller_test.rb
│   ├── posts_controller_test.rb
│   ├── follows_controller_test.rb
│   ├── blocks_controller_test.rb
│   ├── profiles_controller_test.rb
│   ├── search_controller_test.rb
│   ├── notifications_controller_test.rb
│   └── push_subscriptions_controller_test.rb
└── jobs/
    ├── purge_expired_posts_job_test.rb
    └── send_push_notification_job_test.rb
```

---

## Was getestet wird

### Model-Tests

| Model | Getestete Aspekte |
|-------|-------------------|
| `User` | Email-Normalisierung, Username-Validierung (Format, Länge, Uniqueness), `admin?`, `following?`, `blocking?`, `dependent: :destroy` für Notifications |
| `Post` | Validierungen (Presence, Max-Length), `to_param`, `expiry_status` (fresh/aging/critical), Scopes (`top_level`, `active`), Reply-Notification-Callback, kein Self-Notify |
| `Follow` | No-self-follow, Uniqueness, Notification-Callback für gefolgten User |
| `Like` | Uniqueness, Notification-Callback für Post-Autor, kein Self-Notify |
| `Notification` | `unread?`, `mark_read!` (incl. Idempotenz), `unread`-Scope, `message` für alle drei Typen, `path` für like/follow |
| `PushSubscription` | Validierungen (Presence, Endpoint-Uniqueness), `to_webpush_subscription`-Format |

### Controller-Tests

| Controller | Getestete Aspekte |
|------------|-------------------|
| `SessionsController` | Login, Logout, falsche Credentials |
| `RegistrationsController` | Registrierung |
| `PasswordsController` | Reset-Mail, ungültiger Token, Passwort-Update |
| `PostsController` | Auth-Guard, erstellen, Like-Toggle, Like/Reply erzeugen Notifications, kein Self-Notify, Destroy (eigene/fremde) |
| `FollowsController` | Follow/Unfollow, Auth-Guard |
| `BlocksController` | Block (inkl. Follow-Cleanup), can't-self-block, Unblock, Auth-Guard |
| `ProfilesController` | show, edit, Bio-Update |
| `SearchController` | Auth-Guard, Suche |
| `NotificationsController` | Auth-Guard, index markiert als gelesen, destroy_all |
| `PushSubscriptionsController` | Auth-Guard, create, upsert bei gleicher Endpoint, destroy |

### Job-Tests

| Job | Getestete Aspekte |
|-----|-------------------|
| `PurgeExpiredPostsJob` | Löscht abgelaufene Posts, lässt aktive in Ruhe, idempotent |
| `SendPushNotificationJob` | Sendet an alle Subscriptions, überspringt bei keiner Subscription, no-op bei fehlendem Record, entfernt expired Subscriptions und wirft keinen Error |

---

## Konventionen

### Fixtures

Fixtures repräsentieren einen **stabilen Basis-Zustand**. Tests, die spezifische Kombinationen brauchen, erstellen ihre Daten selbst (z.B. `users(:two).follows.create!(following: users(:one))`).

Fixture-Daten niemals in Tests implizit voraussetzen ohne expliziten Hinweis im Kommentar — z.B.:

```ruby
test "cannot like same post twice" do
  # fixture two_likes_post_one bereits vorhanden
  duplicate = Like.new(user: users(:two), post: posts(:one))
  assert duplicate.invalid?
end
```

### Stubbing (minitest 6)

`minitest/mock` existiert in minitest 6 nicht mehr. Stattdessen steht `stub_method` aus dem `test_helper` zur Verfügung:

```ruby
stub_method(WebPush, :payload_send, ->(*_a, **_k) { calls += 1 }) do
  SendPushNotificationJob.perform_now(notification.id)
end
```

`stub_method` stellt die originale Methode per `ensure` immer wieder her — auch bei Exceptions.

### Auth-Guards

Jeder Controller-Test hat einen Auth-Guard-Test (`not logged in → redirect`). Dieser kommt immer zuerst, bevor der Happy-Path getestet wird.

### Notification-Callbacks

`after_create_commit`-Callbacks feuern in Rails 8 auch in Tests mit transactional fixtures. Callback-Tests nutzen `assert_difference("Notification.count", 1)` als primäre Assertion.

---

## CI

Tests laufen automatisch via GitHub Actions (`.github/workflows/ci.yml`) bei jedem Push auf `main` und bei Pull Requests. Der `test`-Job blockt den `deploy`-Job — kein Deploy bei roten Tests.

```yaml
test:
  - bin/rails db:test:prepare test
deploy:
  needs: [scan_ruby, lint, test]
```

**Wichtig:** Nach neuen Migrationen muss `db/schema.rb` committed sein, sonst schlägt `db:test:prepare` in CI fehl.

---

## Neue Tests hinzufügen

1. Model-Logik → `test/models/<model>_test.rb`
2. HTTP-Flow → `test/controllers/<controller>_test.rb`
3. Seiteneffekte/Jobs → `test/jobs/<job>_test.rb`
4. Fixtures wenn nötig ergänzen (minimaler Basis-Zustand)
5. Lokal grün: `RAILS_ENV=test bin/rails test`
6. `db/schema.rb` committen wenn neue Migrationen vorhanden
