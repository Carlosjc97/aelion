# Edaptia [![CI](https://github.com/Carlosjc97/Edaptia/actions/workflows/ci.yml/badge.svg)](https://github.com/Carlosjc97/Edaptia/actions/workflows/ci.yml)

Modern learning companion built with Flutter and Firebase. The `outline` HTTPS Function (Genâ€‘2) produces curated course outlines with Firestore-backed caching, defensive JSON parsing, and observability telemetry. The Flutter client persists the last generated outline locally so learners can resume instantly.

## What's New (Jan 2025)

- **âš¡ Performance Boost** â€“ Migrated from GPT-4o to GPT-4o-mini for calibration quiz, adaptive plans, and module generation. **3x faster response times, 16x cost reduction** (~$0.012 vs ~$0.19 per user journey).
- **ðŸš€ Timeout Fix** â€“ Extended Firebase Functions timeout from 60s to 300s for all generative endpoints. Eliminated connection abort errors during plan generation.
- **ðŸ“ˆ Rate Limit Optimization** â€“ Increased rate limits for development (20 requests/5min for adaptive plans, 10 requests/5min for placement quizzes).
- **Adaptive engagement** â€“ Placement quizzes now cache locally/offline, forward detected gaps to an OpenAI "tweak" call before persisting, and expose shareable, topic-aware results.
- **Interactive lessons** â€“ Lesson detail screens render AI-authored markdown hooks and validate user submissions through the `validateChallenge` endpoint to unlock badges.
- **Gamification** â€“ Daily streaks are stored in Firestore via a Riverpod provider and can trigger FCM reminders for lapsed learners.
- **Cost transparency** â€“ The new usage dashboard consumes `openaiUsageMetrics` to visualize token/cost spend per endpoint with `fl_chart`.
- **Safer paywall UX** â€“ Paywall helper/modal handle entitlement failures gracefully, emit GA4 `paywall_dismissed`, and expose a callback for additional tracking.

## ðŸš€ Production Services

### Assessment API (IRT Adaptive Testing)
**Live Service:** https://assessment-api-110324120650.us-central1.run.app

Adaptive assessment engine using Item Response Theory (IRT) with 3-parameter logistic model. Deployed on Cloud Run with:
- Firebase Authentication
- Google Cloud Secret Manager integration
- HMAC signing + Rate limiting
- 15 tests passing

**Health Check:**
```bash
curl -H "Origin: https://Edaptia-c90d2.web.app" https://assessment-api-110324120650.us-central1.run.app/health
# Returns: {"ok":true}
```

See [DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md) for full deployment documentation.

---

## ðŸ’° Paywall & Monetization (MVP)

**Status:** Functional (Mock - No real payment)

The app implements a freemium model with paywall gating:
- **M1 (Fundamentos SELECT)**: Free forever - 4 lessons (~28 min)
- **M2-M6**: Premium locked - 18 lessons (~126 min)
- **Mock Exam**: Premium locked
- **PDF Cheat Sheet**: Premium locked

### Paywall Triggers
Three strategic paywall moments:
1. **Post-calibration**: "Desbloquear plan completo" (first contact after quiz)
2. **Module locked**: "Continuar con Premium" (friction moment when accessing M2-M6)
3. **Mock exam**: "Acceder a examen de prÃ¡ctica" (added value)

### Trial
- **7 days free** (no credit card required)
- Mock implementation (no RevenueCat integration yet)
- Trial state persists in memory only (resets on app restart)

### Implementation Files
```
lib/services/entitlements_service.dart  # Trial & premium logic
lib/features/paywall/paywall_modal.dart # Paywall UI
lib/features/paywall/paywall_helper.dart # Helper for showing paywall
test/paywall_smoke_test.dart  # 4/4 tests passing
```

### Testing Paywall Locally
```bash
# Run paywall tests
flutter test test/paywall_smoke_test.dart

# Expected output:
# âœ… 4/4 tests passing
```

### GA4 Events
```
paywall_viewed (placement: 'post_calibration' | 'module_locked' | 'mock_locked')
trial_start (trigger: string, trial_days: 7)
```

See [SMOKE_TEST_CHECKLIST.md](docs/SMOKE_TEST_CHECKLIST.md) for complete testing guide.

---

## Backend Quickstart (Firebase Functions)

**Prerequisites**
- Node.js 20
- Firebase CLI authenticated against the `Edaptia-c90d2` project

```bash
cd functions
npm ci
npm run build
npm run test
firebase deploy --only functions:outline
```

### CI / Smoke Checks

Use the shared CI helper to run linting, tests and the Functions build in one go:

```bash
./tool/ci.sh
```

### Smoke Test (Windows)
```powershell
$body = @{
  topic = "Flutter crash course"
  depth = "medium"
  lang  = "en"
} | ConvertTo-Json -Compress
Invoke-RestMethod `
  -Method POST `
  -Uri "https://us-east4-Edaptia-c90d2.cloudfunctions.net/outline" `
  -ContentType "application/json" `
  -Body $body
```

```powershell
@'
{"topic":"Flutter crash course","depth":"medium","lang":"en"}
'@ | Out-File -Encoding utf8 payload.json
curl.exe -sS -i -X POST ^
  "https://us-east4-Edaptia-c90d2.cloudfunctions.net/outline" ^
  -H "Content-Type: application/json" ^
  --data-binary "@payload.json"
```

### Logs & Diagnostics
```bash
firebase functions:log --only outline --project Edaptia-c90d2
```

### Firestore Rules

- Production deployments ship with a fully closed `firestore.rules` file (`allow read, write: if false;`). All client requests must flow through Cloud Functions.
- When you need permissive rules for local emulation only, create a throwaway file such as `firestore.rules.emulator` with `allow read, write: if true;` and start the emulator explicitly:  
  `firebase emulators:start --only firestore --project Edaptia-c90d2 --rules firestore.rules.emulator`  
  Never deploy these permissive rules to production.

### Behaviour Guarantees
- Invalid or malformed JSON returns **400** with validation details (never a 500).
- Firestore cache is resilient: expired or malformed documents are ignored and replaced automatically. TTL varies per `depth` (`intro`: 7d, `medium`: 3d, `deep`: 1d).
- Observability documents record route, user, cache status, params, cost, and token metrics without impacting the response path.

---

## Quiz de colocacion

**Resumen**
- `POST /placementQuizStart` crea una sesion de 10 preguntas. Responde `OPTIONS` con `204` y cabeceras CORS para navegadores.
- `POST /placementQuizGrade` califica las respuestas, decide la banda sugerida y si hace falta regenerar el plan.

**Comandos rapidos (PowerShell)**

```powershell
$URL_START = "https://us-east4-Edaptia-c90d2.cloudfunctions.net/placementQuizStart"
$startBody = @{ topic = "Historia de Roma"; lang = "es" } | ConvertTo-Json -Compress
$start = Invoke-RestMethod -Method POST -Uri $URL_START -ContentType "application/json" -Body $startBody
$start | ConvertTo-Json -Depth 10
```

```powershell
$URL_GRADE = "https://us-east4-Edaptia-c90d2.cloudfunctions.net/placementQuizGrade"
$answers = $start.questions | ForEach-Object { @{ id = $_.id; choiceIndex = 0 } }
$gradeBody = @{ quizId = $start.quizId; answers = $answers } | ConvertTo-Json -Compress
Invoke-RestMethod -Method POST -Uri $URL_GRADE -ContentType "application/json" -Body $gradeBody
```

**Politica de costos y estabilidad**
- Rate limit: maximo un `placementQuizStart` por usuario cada 5 minutos (`x-user-id`). Los excesos devuelven **429** con payload JSON.
- TTL: la sesion expira en 60 minutos (`expiresAt`). La cache de outline se invalida con `expiresAt` o cuando falta el campo.
- Regeneracion condicionada: solo se recalcula el outline si `recommendRegenerate` llega en `true`; de lo contrario se reutiliza el cache.
- Fallback determinista: sin `OPENAI_API_KEY` se entrega un cuestionario generico estable, util para QA sin costo.
- Observabilidad: los logs estructurados (`info` / `warn` / `error`) incluyen `message`, `code`, y nunca exponen `correctAnswerIndex` al cliente.

---

## Frontend Quickstart (Flutter)

```bash
flutter pub get
flutter test
flutter run -d chrome
```

### Analytics Debugging
- **GA4 DebugView**: run the app with analytics debug mode enabled (Android: `adb shell setprop debug.firebase.analytics.app com.Edaptia.learning`; iOS: launch with `-FIRDebugEnabled`). Open *Google Analytics ? Configure ? DebugView* to inspect live events, filtered by the active device stream.
- **PostHog Live Events**: open your PostHog project and select *Live events*. Events are tagged with `schema_ver="v1"` plus the shared context (platform, build type, locale) for quick filtering.

### Key UX Notes
- After any successful outline request, the app saves `topic`, raw JSON, and timestamp in `SharedPreferences`.
- Home screen surfaces the cached outline card with a `View outline` action and a stale badge when data is older than 24 hours.
- `ModuleOutlineView` hydrates immediately from the cached payload (if available), highlights the source (`fresh` vs `cache`), and regenerates on demand without blocking the user.

---

## Public Environment Variables (`env.public`)

| Variable | Purpose | Default |
|----------|---------|---------|
| `Edaptia_ENV` | Logical environment label used for analytics and feature toggles. | `production` |
| `API_BASE_URL` | Base HTTPS URL for the deployed Functions instance. | `https://us-east4-Edaptia-c90d2.cloudfunctions.net` |
| `BASE_URL` | Backwards-compatible alias for `API_BASE_URL`. | same as above |
| `CV_STUDIO_API_KEY` | Optional integration token (leave blank for local). | `changeme` |
| `USE_FUNCTIONS_EMULATOR` | When `true`, routes API calls to the local emulator. | `false` |
| `FUNCTIONS_EMULATOR_HOST` / `PORT` | Host and port overrides for the emulator when enabled. | `localhost` / `5001` |

---

## Troubleshooting

| Symptom | Cause | Resolution |
|---------|-------|------------|
| `SERVICE_DISABLED: Cloud Firestore API has not been used in project` | Firestore API disabled or project not provisioned. | Enable Cloud Firestore API from Google Cloud Console and initialise the database in region `nam5`. Re-run the outline request once the service is active. |
| `SyntaxError: Unexpected token ...` when calling the function from PowerShell | Raw JSON string passed without proper escaping. | Pipe a PSCustomObject through `ConvertTo-Json -Compress` or use `curl.exe` with `--data-binary` as shown above. |
| Cache document `NOT_FOUND` or malformed fields | Legacy data or TTL expiration. | Current function treats these as cache misses, regenerates the outline, and rewrites the cache safely. No manual cleanup required - trigger a fresh request. |

---

## CI/CD Overview

Workflow: [`.github/workflows/ci.yml`](.github/workflows/ci.yml)
- `flutter analyze`, `flutter test`, and `flutter build web --release`
- `npm ci` + `npm run build` for Firebase Functions under Node.js 20
- Gitleaks SARIF reports for PRs and blocking scans on pushes to `main`

Badge at the top reflects the latest pipeline status for `main`.

---

## Observability

Each outline invocation appends a document to the `observability` collection:
- `route`, `ts`, `user`, `cached`
- `params.topic`, `params.depth`, `params.lang`
- `cost_usd`, `tokens_in`, `tokens_out`, `cache_key`, `outline_size`

Failures to write observability data are logged but never impact the client response.



## Plan Refinement Policy

Manual "Actualizar plan" actions were removed from the Module Outline screen to avoid unlimited regenerations. Learners now refresh their plans only through the post-quiz flow or the existing "Refinar plan" sheet. See [PLAN_REFINEMENT_POLICY.md](docs/PLAN_REFINEMENT_POLICY.md) for details.


## UI Preview

![Sign-in Screen](docs/assets/ui-signin.png)
![Home Screen](docs/assets/ui-home.png)
![Home Screen (Plan suggestions)](docs/assets/ui-home2.png)
![Placement Quiz](docs/assets/ui-quiz.png)


