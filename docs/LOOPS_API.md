# How Loops Works — Architecture & API Reference

This document describes how the **loops_flutter** app talks to a Loops server
(default: `loops.video`), how authentication works, and every backend endpoint
the app uses. It is written from the actual client code in `lib/`, so it
reflects what the app really does rather than the upstream server spec.

Loops is a short-video platform (Pixelfed-family / Laravel + Sanctum + OAuth).
The Flutter app is a multi-instance client: most users hit `loops.video`, but
the login screen lets you point at any custom Loops server.

---

## 1. High-level architecture

The app is organized by **feature**, each feature split into the classic
clean-architecture layers:

```
lib/
├── core/                        # cross-cutting infrastructure
│   ├── auth/                    # OAuthService (+ provider)
│   ├── network/                 # ApiClient (Dio wrapper)
│   ├── storage/                 # StorageService (SharedPreferences)
│   ├── theme/  utils/  widgets/
├── features/
│   ├── auth/                    # login, 2FA, captcha, OAuth, register
│   ├── feed/                    # for-you / following feeds, video actions, upload
│   ├── profile/                 # own + other users, followers/following
│   ├── explore/                 # suggested accounts, trending tags, search
│   ├── activity/                # notifications
│   └── settings/                # account / privacy / password / avatar
└── main.dart                    # app entry, GoRouter, shell + bottom nav
```

Each feature typically has:

- `domain/models/` — data models (Freezed + json_serializable).
- `domain/repositories/` — abstract repository interfaces.
- `data/repositories/` — concrete implementations that call `ApiClient`.
- `presentation/` — screens, widgets, and Riverpod controllers.

**State management:** Riverpod (`flutter_riverpod` + `riverpod_annotation`).
Repositories and services are exposed as providers (e.g.
`apiClientProvider`, `authRepositoryProvider`, `feedRepositoryProvider`).

**Routing:** `go_router`. See [§7 Routing & app shell](#7-routing--app-shell).

---

## 2. The network layer — `ApiClient`

File: `lib/core/network/api_client.dart`

`ApiClient` is a thin wrapper around a single configured [Dio] instance. It is
the only thing that actually performs HTTP, and it centralizes base URL,
headers, cookies, CSRF, retries, and logging.

### 2.1 Base URL resolution

```
https://<instance>
```

The instance is read from `StorageService.getInstance()`. If unset, it
defaults to `https://loops.video`. All repository calls pass **relative**
paths (e.g. `api/v1/feed/for-you`); `ApiClient` prepends the base URL. Absolute
URLs (`http(s)://…`) are passed through untouched.

### 2.2 Default headers

Every request carries (see `_getHeaders()`):

| Header | Value |
|---|---|
| `Content-Type` | `application/json` (removed automatically for `FormData`) |
| `Accept` | `application/json` |
| `X-Requested-With` | `XMLHttpRequest` |
| `Origin` | `https://<instance>` |
| `Referer` | `https://<instance>/` |
| `User-Agent` | `LoopsFlutter/0.1 (Flutter; Dio)` |
| `Authorization` | `Bearer <token>` — only if a token is stored (OAuth path) |

`Origin`/`Referer`/`X-Requested-With` are what Laravel Sanctum expects from a
"first-party SPA" so it accepts the session-cookie auth flow.

### 2.3 Cookies & sessions

- A `CookieManager` interceptor (backed by a cookie jar) persists cookies
  across requests. This is how **session-based login** stays authenticated —
  the Laravel `laravel_session` cookie and `XSRF-TOKEN` cookie live here.
- The jar starts **in-memory** (`DefaultCookieJar`) so it works on web and
  sandboxed platforms. On native platforms it asynchronously upgrades to a
  **persistent** jar (`PersistCookieJar` under the app documents dir) once it
  confirms the directory is writable. If anything fails it silently stays
  in-memory.
- `clearCookies()` wipes the jar — called on logout and before a fresh login
  to avoid stale-session bugs.

### 2.4 CSRF (Sanctum) handling

Laravel Sanctum uses the **double-submit cookie** pattern:

1. `ensureCsrfCookie()` does `GET /sanctum/csrf-cookie`. The server sets an
   `XSRF-TOKEN` cookie.
2. A request interceptor reads that cookie on every outgoing request,
   URL-decodes it, and copies it into the `X-XSRF-TOKEN` header.

So any state-changing request (login, like, comment, follow, upload, settings)
must be preceded by a valid `XSRF-TOKEN` cookie. Repositories call
`ensureCsrfCookie()` before `POST`s (see `_postWithCsrf` helpers).

A `419` response means "CSRF token expired/rotated" — the login flow handles
this by re-fetching the cookie and retrying once.

### 2.5 Retries

`_RetryInterceptor` retries **only idempotent GETs** on transient failures
(connection/timeout/`IOException`), up to 2 times with backoff (400ms, 1000ms).
`POST`s are never auto-retried. 4xx/5xx are not retried — `validateStatus` lets
status codes `< 500` through as normal responses so repositories inspect them
directly.

### 2.6 Timeouts

- connect: 20s, receive: 30s, send: 30s (defaults).
- Video upload overrides send/receive to **10 minutes**.

---

## 3. Storage — `StorageService`

File: `lib/core/storage/storage_service.dart`

Thin wrapper over `SharedPreferences`. Three keys:

| Key | Purpose |
|---|---|
| `app.token` | OAuth bearer token (session login does **not** use this) |
| `app.instance` | Server host, e.g. `loops.video` |
| `app.logged_in` | Boolean used by the router to gate access |

> Note: session-based auth relies on the **cookie jar**, not on `app.token`.
> `app.logged_in` is the flag the router checks; the actual session lives in
> cookies. OAuth login additionally stores the bearer token.

`SharedPreferences` is initialized in `main()` and injected via a provider
override so the rest of the app can read it synchronously.

---

## 4. Authentication

There are **three** ways to sign in, all reachable from the welcome screen
(`lib/features/auth/presentation/screens/login_screen.dart`). The auth logic
lives in `AuthRepositoryImpl` (`lib/features/auth/data/repositories/`) and
`OAuthService` (`lib/core/auth/oauth_service.dart`).

### 4.1 Method A — Email/password (Sanctum session login) — primary

This is the default "Sign in with email" path and is currently hard-pinned to
`loops.video`.

Flow (`AuthRepositoryImpl.login`):

1. `setInstance('loops.video')`.
2. `clearCookies()` — drop any stale session.
3. `ensureCsrfCookie()` → `GET /sanctum/csrf-cookie`.
4. `POST /login` with JSON body:
   ```json
   {
     "email": "...",
     "password": "...",
     "remember": true,
     "captcha_type":  "<optional>",
     "captcha_token": "<optional>"
   }
   ```
5. If `419` (CSRF rotated): re-fetch cookie and retry the `POST` once.
6. On `200/204`:
   - If the response body has `"has_2fa": true` → **do not** mark logged in;
     return `false` and route to the 2FA step.
   - Otherwise set `app.logged_in = true`. Done — the session cookie now
     authenticates subsequent requests.
7. On failure, throw with the server's `message` field if present.

There is no separate token; **the session cookie is the credential**.

#### Two-factor (2FA)

`AuthRepositoryImpl.submitTwoFactor`:

- `POST /api/v1/auth/2fa/verify` with `{ "otp_code": "..." }`.
- On `200`, set `app.logged_in = true`.

#### Captcha (Cloudflare Turnstile)

File: `lib/features/auth/presentation/screens/captcha_screen.dart`

`loops.video` may require a Cloudflare **Turnstile** challenge. The app renders
the Turnstile widget inside a `WebView`:

- The challenge HTML is loaded with `baseUrl: https://loops.video/` so the
  WebView's document origin is `loops.video` (Turnstile site keys are
  domain-bound; loading via a raw `data:` URL gives an opaque origin and
  Turnstile rejects it as "Invalid domain").
- On success the page posts the token back through a JS channel named
  `Turnstile`; the screen pops with the token.
- That token is then passed into `login()` as `captcha_token` (with
  `captcha_type`).

### 4.2 Method B — OAuth 2.0 (authorization code) — "Continue with browser"

`OAuthService.login(server)` implements a standard OAuth Authorization Code
flow against a Loops/Mastodon-style API. Works against arbitrary instances.

Constants:

- App name: `Loops for Flutter`
- Default scopes: `user:read user:write video:create video:read`
- Redirect URI: `com.example.loopsflutter://login-callback`

Steps:

1. **Register the app** — `POST /api/v1/apps` (multipart form):
   ```
   client_name      = "Loops for Flutter"
   website          = "https://joinloops.org"
   scopes           = "user:read user:write video:create video:read"
   redirect_uris[]  = "com.example.loopsflutter://login-callback"
   ```
   Returns `{ client_id, client_secret, ... }`.

2. **Authorize** — open a browser (`flutter_web_auth_2`) to:
   ```
   https://<server>/oauth/authorize
       ?client_id=<id>
       &scope=user:read+user:write+video:create+video:read
       &redirect_uri=<url-encoded redirect>
       &response_type=code
   ```
   Scopes are joined with `+` to match the upstream `loops-expo` format
   exactly. The browser redirects back to the custom scheme with `?code=...`.

3. **Exchange the code** — `POST /oauth/token` (multipart form):
   ```
   client_id, client_secret, redirect_uri,
   grant_type = "authorization_code",
   code       = <code from step 2>,
   scope      = <default scopes>
   ```
   Returns `{ access_token, ... }`.

4. **Verify** — `GET /api/v1/account/info/self` with
   `Authorization: Bearer <access_token>`. Response is `{ "data": { ...user } }`.

5. **Persist** — store the token (`app.token`), instance, and
   `app.logged_in = true`.

> The bearer token from this flow is what populates the `Authorization` header
> in `ApiClient._getHeaders()`.

### 4.3 Method C — Browser registration — "Sign up"

`OAuthService.registerWithWebBrowser(server)`:

1. Open a browser to:
   ```
   https://<server>/auth/app/register?mobile=true&redirect_uri=<encoded redirect>
   ```
2. The server redirects back with `?token=...&user=<json>`.
3. Validate the user JSON parses into `UserModel`, then store token + instance
   and set `app.logged_in = true`.

### 4.4 Logout

`AuthRepositoryImpl.logout()` clears the stored token, sets
`app.logged_in = false`, and clears cookies. (No server-side logout call.)

### 4.5 Session restoration

`isAuthenticated()` simply returns the `app.logged_in` flag.
`getCurrentUser()` calls `GET /api/v1/account/info/self`; a non-200 resets the
logged-in flag (handles server-side session expiry).

---

## 5. API endpoint reference

All paths are relative to `https://<instance>`. Unless noted, responses follow
Laravel's resource envelope: `{ "data": ... , "meta": {...}, "links": {...} }`.

State-changing `POST`s require a valid CSRF cookie (see §2.4) and accept
`200/201/204` as success.

### 5.1 Auth & account

| Method | Path | Purpose |
|---|---|---|
| `GET`  | `/sanctum/csrf-cookie` | Obtain `XSRF-TOKEN` cookie |
| `POST` | `/login` | Session login (email/password, optional captcha) |
| `POST` | `/api/v1/auth/2fa/verify` | Submit 2FA OTP |
| `POST` | `/api/v1/apps` | Register OAuth client app |
| `GET`  | `/oauth/authorize` | OAuth authorization (browser) |
| `POST` | `/oauth/token` | Exchange auth code for token |
| `GET`  | `/auth/app/register` | Browser registration flow |
| `GET`  | `/api/v1/account/info/self` | Current authenticated user |
| `GET`  | `/api/v1/account/info/{userId}` | Public profile of a user |

### 5.2 Feeds & videos

File: `feed/data/repositories/feed_repository_impl.dart`,
`video_actions_repository_impl.dart`.

| Method | Path | Purpose |
|---|---|---|
| `GET`  | `/api/v1/feed/for-you` | "For You" feed (cursor paginated) |
| `GET`  | `/api/v1/feed/following` | Following feed (cursor paginated) |
| `GET`  | `/api/v1/video/{videoId}` | Single video |
| `GET`  | `/api/v1/video/showVideoLikes?id={videoId}` | Users who liked a video |
| `GET`  | `/api/v1/video/comments/{videoId}` | Top-level comments |
| `GET`  | `/api/v1/video/comments/reply/{videoId}/{commentId}` | Replies to a comment |
| `POST` | `/api/v1/video/like/{videoId}` | Like a video |
| `POST` | `/api/v1/video/unlike/{videoId}` | Unlike a video |
| `POST` | `/api/v1/video/comments/{videoId}` | Add comment `{ "comment": "..." }` |
| `POST` | `/api/v1/video/comments/reply/{videoId}` | Reply `{ "comment", "parent_id" }` |
| `POST` | `/api/v1/comments/like/{videoId}/{commentId}` | Like a comment |
| `POST` | `/api/v1/comments/unlike/{videoId}/{commentId}` | Unlike a comment |
| `POST` | `/api/v1/comments/delete/{videoId}/{commentId}` | Delete a comment |

#### Video upload

File: `feed/data/repositories/video_upload_repository_impl.dart`

- Client-side compresses the video (`video_compress`, medium quality, output
  `mp4`) to avoid `413 Payload Too Large`.
- `ensureCsrfCookie()`, then `POST /api/v1/studio/upload` as multipart:
  ```
  description = <caption or "">
  video       = <multipart file, video/mp4>
  ```
- Send/receive timeouts raised to 10 minutes; upload progress streamed via
  `onSendProgress`. Compressed temp files are cleaned afterward.

### 5.3 Profile

File: `profile/data/repositories/profile_repository_impl.dart`

| Method | Path | Purpose |
|---|---|---|
| `GET`  | `/api/v1/feed/account/self` | Current user's videos (cursor) |
| `GET`  | `/api/v1/account/videos/likes` | Current user's liked videos (cursor) |
| `GET`  | `/api/v1/account/followers/{userId}` | Followers list |
| `GET`  | `/api/v1/account/following/{userId}` | Following list |
| `GET`  | `/api/v1/account/info/{userId}` | A user's profile |
| `GET`  | `/api/v1/feed/account/{userId}/cursor?limit=20&id={cursor}` | A user's videos (paginated) |
| `GET`  | `/api/v1/feed/account/{userId}?limit=20` | A user's videos (first page, no cursor — fallback) |
| `POST` | `/api/v1/account/follow/{userId}` | Follow a user |
| `POST` | `/api/v1/account/unfollow/{userId}` | Unfollow a user |

> **Pagination gotcha (documented in code):** the plain
> `/feed/account/{id}` endpoint returns a page with **no** next-cursor, which
> silently caps a user's video grid at the first page (~10–20 videos). The
> `/cursor` variant is the only one that returns `links.next` / `meta`, so it
> is used as the primary path, with the plain endpoint only as a first-page
> fallback for servers that reject `/cursor` without an `id`.

### 5.4 Explore & search

File: `explore/data/repositories/explore_repository_impl.dart`

| Method | Path | Purpose |
|---|---|---|
| `GET`  | `/api/v1/accounts/suggested` | Suggested accounts to follow |
| `GET`  | `/api/v1/explore/tags` | Trending tags |
| `GET`  | `/api/v1/explore/tag-feed/{tag}` | Videos for a tag (cursor; `#` stripped) |
| `POST` | `/api/v1/search/users` | Search users `{ "q": "..." }` |
| `GET`  | `/api/v1/search/videos?query=...&cursor=...` | Search videos |
| `POST` | `/api/v1/account/follow/{userId}` | Follow (also used here) |
| `POST` | `/api/v1/account/unfollow/{userId}` | Unfollow |

### 5.5 Activity / notifications

File: `activity/data/repositories/activity_repository_impl.dart`

The notifications endpoint varies by deployment, so the client tries a list of
candidates in order and uses the first that responds (skips `404`s):

1. `/api/v1/account/notifications`  ← works on `loops.video`
2. `/api/v1/notifications`
3. `/api/v1/notifications/unread`
4. `/api/notifications`
5. `/api/v1/notifications/list`

All accept an optional `?cursor=` param.

### 5.6 Settings

File: `settings/data/repositories/settings_repository_impl.dart`

| Method | Path | Body / notes |
|---|---|---|
| `POST` | `/api/v1/account/settings/update-password` | `current_password`, `password`, `password_confirmation` |
| `POST` | `/api/v1/account/settings/bio` | `name?`, `bio?` |
| `POST` | `/api/v1/account/settings/data` | `data_retention_period`, `analytics_tracking`, `research_data_sharing` |
| `POST` | `/api/v1/account/settings/email/update` | `email`, `password?` |
| `POST` | `/api/v1/account/settings/update-avatar` | multipart `avatar` (jpeg/png/gif) |
| `GET`  | `/api/v1/account/settings/privacy` | Read privacy settings |
| `POST` | `/api/v1/account/settings/privacy` | Update privacy (field is `discoverable`, not `is_private`) |
| `POST` | `/api/v1/account/disable` | Disable account |
| `POST` | `/api/v1/account/delete` | Delete account |

---

## 6. Pagination

Loops uses Laravel-style **cursor pagination**, but inconsistently across
endpoints. The helper `extractNextCursor()`
(`feed/domain/models/feed_page.dart`) normalizes it:

1. Prefer `meta.next_cursor` (or `meta.nextCursor`).
2. Otherwise parse `links.next` and read its `?id=` or `?cursor=` query param.

Repositories return a `FeedPage { videos, nextCursor }`. A `null` `nextCursor`
means "no more pages." Controllers pass the previous `nextCursor` back as the
`cursor`/`id` query param to load the next page (infinite scroll).

Malformed items inside a page are skipped individually (the `expand` +
`try/catch` pattern) so one bad video object never breaks the whole feed.

---

## 7. Routing & app shell

File: `lib/main.dart`

- `go_router` with a `redirect` guard: if `!isAuthenticated` → `/login`;
  if authenticated and on `/login` → `/`.
- A `ShellRoute` wraps the four main tabs in `MainScreen` (custom bottom nav):
  - `/` → Feed
  - `/explore` → Explore
  - `/activity` → Activity
  - `/profile` → Profile
- `/login` and `/user/:id` (other-user profile) sit outside the shell.
- The center "+" button is an **action**, not a route — it launches the
  gallery picker → caption dialog → upload flow.

---

## 8. Error & resilience patterns

- **`validateStatus < 500`**: 4xx/5xx come back as normal responses;
  repositories check `statusCode` instead of catching exceptions for expected
  failures.
- **Graceful empties**: list/feed fetches catch errors and return empty
  results rather than throwing, so the UI degrades to "nothing here" instead of
  crashing.
- **Safe error widget**: `ErrorWidget.builder` is replaced globally with a
  quiet placeholder so an isolated render error never shows the red crash
  screen.
- **CSRF retry**: login retries once on `419`.
- **GET retries**: transient network errors retried twice with backoff.

---

## 9. Quick reference — the auth decision tree

```
Welcome screen
├── "Sign in with email"        → Sanctum session login (loops.video)
│      ├── needs captcha?        → Turnstile WebView → captcha_token
│      ├── has_2fa?              → /api/v1/auth/2fa/verify
│      └── success               → session cookie + app.logged_in=true
│
├── "Continue with browser"     → OAuth 2.0 code flow (any instance)
│      → /api/v1/apps → /oauth/authorize → /oauth/token
│      → store bearer token + app.logged_in=true
│
└── "Sign up"                    → /auth/app/register?mobile=true
       → callback ?token&user → store token + app.logged_in=true
```

---

*Generated from the client source in `lib/`. If endpoints change server-side,
the source files referenced above are the source of truth.*
