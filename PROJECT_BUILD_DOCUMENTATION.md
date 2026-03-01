# IMS Scanner App - Build Documentation
Last updated: 2026-03-01

## 1) Project Goal
Build a Flutter-based IMS scanner app for cold storage operations that supports:
- Fast barcode-driven task execution
- Reliable online/offline behavior
- Configurable backend endpoint per deployment

## 2) What Is Already Built
### App foundation
- Flutter app bootstrapped with `ProviderScope`
- `MaterialApp.router` with light/dark theme setup
- Central route constants in `lib/routers/app_route_paths.dart`

### Implemented screens and flow
- `Network Configuration` screen (`/networkConfig`)
- `Login` screen (`/login`) with form validation
- `Home` screen (`/home`)
- `Cold Storage Dashboard` screen (`/dashboard`)

### Current UI modules
- Dashboard tiles for:
  - Receiving
  - Put Away
  - Check
  - Dispatch
  - Transfer Tag
  - Transfer Pallet
  - Recount
  - Pallet Compression

### Utilities currently in code
- `dio` wrapper client in `lib/utils/http/http_client.dart`
- Shared reusable app bar and theme components
- Basic Riverpod state usage for home slider indicator

## 3) Current Gaps To Close
- Network endpoint entries are in-memory only (not persisted yet)
- Selected endpoint does not yet update `dio` base URL globally
- Login submit is placeholder navigation (auth API not integrated yet)
- Dashboard module routes are not implemented yet
- `/settings` route is referenced in UI but not defined in router
- Installed packages for offline/security/monitoring are not wired yet

## 4) Target Technical Architecture
### Presentation layer
- Feature-first folders (`authentication`, `coldstorage`, `home`, etc.)
- `go_router` for navigation
- Riverpod providers/notifiers for screen logic and state

### Data layer
- `dio` for API communication
- `drift` + SQLite for local operational data and pending sync queue
- `flutter_secure_storage` for secrets/session data

### Reliability layer
- `connectivity_plus` for online/offline awareness
- Sync queue replay when back online
- `sentry_flutter` for crash and runtime error monitoring

## 5) Build Roadmap (What We Are About To Build)
### Phase 1: Foundation hardening
- Persist endpoint list and selected endpoint
- Load selected endpoint at startup and bind to `dio` base URL
- Add app-level config provider for active environment URL
- Clean route table and remove/implement dangling routes

### Phase 2: Authentication integration
- Connect login form to backend auth endpoint
- Store token/session securely
- Add auth guard/redirect logic in router
- Add logout flow and session restore on app launch

### Phase 3: Scanner-ready receiving MVP
- Implement scanner input abstraction (keyboard wedge first)
- Build Receiving screen with scan list and validation
- Save scans locally when offline
- Sync queued scans when connection is restored

### Phase 4: Warehouse module rollout
- Implement module screens from dashboard routes
- Reuse shared scan + submit workflow components
- Add status feedback, retries, and audit trail entries

### Phase 5: Production readiness
- Sentry initialization and release tagging
- Better logging boundaries and error handling strategy
- Unit/widget tests for auth, config, and receiving flow

## 6) Proposed Core Data Objects
- `EndpointConfig`: id, title, baseUrl, isSelected
- `UserSession`: userId, token, refreshToken, expiresAt
- `ScanEvent`: localId, module, barcode, timestamp, syncStatus
- `SyncQueueItem`: id, payload, retryCount, lastError, createdAt

## 7) Immediate Next Tasks
1. Persist network config to secure storage and bind active URL to `AppHttpClient`.
2. Add `AuthRepository` + login API call and token storage.
3. Create first real module route (`/receiving`) and screen scaffold.
4. Add scanner input handler service and connect it to Receiving screen.
5. Introduce a local queue table using `drift` for offline scan submissions.
