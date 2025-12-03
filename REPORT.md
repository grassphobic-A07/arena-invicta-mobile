# Work Summary (adam/discussions-page)

- Implemented glass bottom nav with center glow and integrated across home and discussions screens.
- Added Discussions skeleton, fetching threads from `/discussions/api/threads/`, with loading/error/empty states and pull-to-refresh.
- Moved discussions feature into `lib/adam_discussions/` and routed via `MaterialApp` and bottom nav.
- Added login shortcut on discussions app bar.
- Implemented “Tulis Diskusi” flow with form (title/body + news ID/URL), validation against `/news/<uuid>/json-data`, and POST to `/discussions/api/threads/create/` using `CookieRequest` session.
- Snackbars now float above the bottom nav; home scaffold allows inset.

# Current State

- Branch: `adam/discussions-page` (pushed).
- Create discussion requires a news UUID/URL (validated) due to backend requirement.
- Discussions list shows live threads from API.
- Login/register flows show snackbars above nav.

# Next Steps

- Improve news selection UX: replace UUID/URL field with a searchable dropdown backed by a news list API (backend support needed).
- Handle CORS/session for Flutter web (or use `--disable-web-security` during dev) so login/register/threads creation work in Chrome dev mode.
- Address lint warnings (`withOpacity` deprecations, unused imports) if desired.

# API Notes

- Login: `POST /accounts/api/login/` with `username`, `password`.
- Create thread: `POST /discussions/api/threads/create/` with `title`, `body`, `news` (UUID). Requires authenticated session cookie.
- Get threads: `GET /discussions/api/threads/`.
