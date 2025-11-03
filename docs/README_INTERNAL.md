# Internal Handbook

## Data Connect SDK Regeneration

1. Ensure you have the Firebase CLI = 14.19 installed and authenticated against `aelion-c90d2`.
2. Set a writable cache path so the emulator download can succeed:

   ```powershell
   $env:FIREBASE_EMULATOR_DOWNLOAD_PATH = "$PWD/.firebase-cache"
   ```

3. Regenerate both Dart and JavaScript SDKs:

   ```powershell
   firebase dataconnect:sdk:generate
   ```

   The command rewrites `lib/dataconnect_generated/` and `src/dataconnect-generated/`. Commit both directories together and never edit the generated files manually.

4. If Windows refuses to delete an old emulator binary (`EPERM`), manually remove it from `%USERPROFILE%\.cache\firebase\emulators` before re-running the command.

## Production vs Emulator

- **Production**: The generated connector is already bound to the `us-east4` service `courses` in `dataconnect/dataconnect.yaml`. `CoursesConnector.instance` connects to production by default once Firebase is initialised.
- **Emulator**: To use the local emulator, call `CoursesConnector.instance.dataConnect.useDataConnectEmulator('localhost', 9399);` during app start-up. Remember to seed the emulator with `firebase dataconnect:sql:migrate --local` and apply the migrations under `dataconnect/schema/migrations/`.

## E2E Verification

1. Launch the Flutter app with Firebase configured (production is the default).
2. Sign in and open the overflow menu on the home screen; choose **Catalogo** to navigate to the temporary `LessonsPage`.
3. The screen calls `GetCourseCatalog` followed by `GetCourseOutline` through `CoursesConnector.instance.<op>().execute()` and renders modules/lessons from the production database.
4. To point the verification flow at the emulator instead, initialise Firebase normally and invoke `CoursesConnector.instance.dataConnect.useDataConnectEmulator('localhost', 9399);` before the first query.

## CI / Local Verification

Run the unified quick-check script before opening a PR:

```bash
./tool/ci.sh
```

It executes `flutter analyze`, `flutter test` and `npm --prefix functions run test` (which compiles the Functions TypeScript and runs the Node test suite). Ensure Flutter SDK is installed/available in PATH; otherwise the script will bail while trying to upgrade the tool cache.

## Operations & Security

| Operation | File | Notes |
|-----------|------|-------|
| `GetCourseCatalog` | `dataconnect/courses/queries.gql` | Lists published courses by language. `@auth(level: USER)` guarantees we only respond to authenticated users. |
| `GetCourseOutline` | `dataconnect/courses/queries.gql` | Fetches modules + lessons for a course. Also `@auth(level: USER)`. |
| `UpsertLessonProgress` | `dataconnect/courses/mutations.gql` | Records progress per lesson. Uses `lessonProgress_upsert` and requires `USER` auth. |

All operations require a Firebase ID token; there are no PUBLIC endpoints any more. Add finer-grained role checks in the future through Remote Config once service roles are defined.

## Assessment API v1

Base path: `/assessment`. Responses contain `level` in `{Basico, Intermedio, Avanzado}`, `confidence` in `[0, 1]`, and `ability` in `[-3, 3]` (logit scale).

Prerequisites:
- Obtain a signed timestamp via `GET /server/timestamp` and send `X-Server-Timestamp` / `X-Server-Signature` headers on every request. Signatures are HMAC-SHA256 with key rotation controlled by `ASSESSMENT_HMAC_KEYS`; timestamps more than +/- 120 seconds from server time are rejected.
- The API enforces 45 requests per rolling minute per `sessionId`, `userId`, and hashed client IP. Breaching a bucket returns `rate_limit_{scope}` (with scopes `session`, `user`, `ip`).

Endpoints:
- `POST /assessment/start` → creates a session (45 min TTL) and returns `{sessionId, status, config, level, confidence, totalAnswered, remaining}`. Payload may include `userId` or `topic` metadata (optional).
- `GET /assessment/{sessionId}/next` → fetches the pending prompt or assigns the next adaptive item. Returns `{sessionId, sequence, question, progress, config}`. While a question is pending this endpoint is idempotent.
- `POST /assessment/{sessionId}/answer` → body `{sequence, attemptId, optionIndex}`; evaluates the item, updates adaptive state, and returns `{correct, finished, level, confidence, totalAnswered, remaining, skillProfile[]}`. Replays with the same `(sequence, attemptId)` replay the cached outcome.
- `POST /assessment/{sessionId}/finish` → marks the run as finished and yields the final summary (also used when the UI abandons the flow).
- `GET /assessment/{sessionId}/state` → retrieves the live snapshot (including `pendingQuestion` when applicable) so the client can resume after reconnecting.

The service never returns correct answers or rationales; those remain server-side for audit logs only.

Adaptive calibration: up to 68 items with early stop when `confidence >= 0.72` before delivering item 8 (requires at least 4 responses). `skillProfile` aggregates accuracy and confidence per competency (`numeracy`, `logic`, `data`, `communication`) for reporting.

## Cloud SQL Schema

- Canonical schema lives in `dataconnect/schema/schema.gql`.
- The matching Postgres migrations reside in `dataconnect/schema/migrations/20251030__create_courses.sql`.
- Seed content for smoke tests is provided in `20251030__seed_courses.sql`.
- The runtime instance is `edaptia-fdc` / database `edaptia` in `us-east4` (update credentials in Cloud Console when rotating the service account).

## Version Matrix

| Component | Version |
|-----------|---------|
| Flutter | revision `20f82749394e` (stable channel) |
| Dart SDK | 3.5 (via Flutter toolchain) |
| firebase_core | 4.1.1 |
| firebase_data_connect | 0.2.1 |
| package_info_plus | 8.0.0 |
| firebase_cli | 14.19+ |

Keep these pinned in `pubspec.yaml` and regenerate the lock file after every upgrade.
