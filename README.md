# Edaptia [![CI](https://github.com/Carlosjc97/aelion/actions/workflows/ci.yml/badge.svg)](https://github.com/Carlosjc97/aelion/actions/workflows/ci.yml)

Modern adaptive learning companion built with Flutter and Firebase. Intelligent course generation powered by GPT-4o with Firestore-backed caching, defensive JSON parsing, and observability telemetry.

agent/audit-remediation
## Production Status (Nov 28, 2025)

=======

## What's New (November 2025)
 main

- **GitHub CI**: ✅ PASSING (flutter + functions)
- **Firebase Functions**: ✅ DEPLOYED
- **App Hosting**: ✅ ACTIVE
- **Backend Server**: https://aelion-110324120650.us-east4.run.app
- **Assessment API**: https://assessment-api-110324120650.us-central1.run.app

## What's New (Nov 2025)

- **Critical Bug Fixes** - Fixed 3 production blockers:
  - Quiz placement topic validation (backend)
  - UTF-8 encoding issues (mojibake)
  - Duplicate module rendering
- **App Hosting Deployment** - Backend server now running on Cloud Run via Firebase App Hosting
- **Performance Boost** - Migrated from GPT-4o to GPT-4o-mini for most endpoints. 3x faster, 16x cost reduction
- **Timeout Fix** - Extended Functions timeout from 60s to 300s
- **Adaptive Lessons** - 8 specialized lesson types (quizzes, practice, games, projects)
- **Interactive UI** - Timeline-based adaptive journey with expandable modules
- **Daily Streaks** - Gamification with Firestore-backed streak tracking

## Backend Services

### App Hosting (Node.js Server)
**Live Service:** https://aelion-110324120650.us-east4.run.app

Assessment API server running on Firebase App Hosting with:
- Express.js backend
- Firebase Admin SDK integration
- IRT-based adaptive testing
- CORS + rate limiting
- Health check endpoint

**Health Check:**
```bash
curl https://aelion-110324120650.us-east4.run.app/health
# Returns: OK
```

### Firebase Functions v2
**Base URL:** https://us-east4-aelion-c90d2.cloudfunctions.net

Key endpoints:
- `/placementQuizStartLive` - Initiate placement quiz
- `/placementQuizGradeLive` - Grade quiz and recommend band
- `/adaptiveModuleGenerate` - Generate adaptive learning modules
- `/outline` - Generate course outlines (legacy)

## Quickstart

### Prerequisites
- Node.js 20
- Flutter 3.x
- Firebase CLI authenticated to `aelion-c90d2` project

### Backend (Firebase Functions)
```bash
cd functions
npm ci
npm run build
npm test
firebase deploy --only functions
```

### Frontend (Flutter)
```bash
flutter pub get
flutter test
flutter run -d chrome
```

### Full CI Check
```bash
./tool/ci.sh
```

## Architecture

### Adaptive Learning Flow
1. **Placement Quiz** - 10 questions calibrated to topic
2. **Band Detection** - Basic, Intermediate, or Advanced
3. **Module Generation** - GPT-4o creates personalized curriculum
4. **Adaptive Lessons** - Content adjusts to learner progress
5. **Streak Tracking** - Gamification for engagement

### Lesson Types
- `welcome_summary` - Module introduction
- `diagnostic_quiz` - Knowledge assessment with scoring
- `guided_practice` - Interactive exercises with validation
- `mini_game` - Gamified learning with timer/streaks
- `activity` - Hands-on practice
- `applied_project` - Real-world application
- `reflection` - Self-assessment
- `theory_refresh` - Concept review

## Deployment Guide

### Firebase Functions
```bash
cd functions
npm run build
firebase deploy --only functions
```

### App Hosting
```bash
# Automatic deployment via Git push
git push origin main

# Manual rollout
firebase apphosting:rollouts:create aelion --git-branch main
```

### Flutter Web
```bash
flutter build web --release
firebase deploy --only hosting
```

## Environment Variables

### App Hosting (`apphosting.yaml`)
- `PORT` - Server port (8080)
- `SERVER_ALLOWED_ORIGINS` - CORS whitelist
- `OPENAI_API_KEY` - OpenAI API secret
- `NODE_ENV` - Environment (production)

### Flutter (`env.public`)
- `AELION_ENV` - Environment label (production)
- `API_BASE_URL` - Functions base URL
- `USE_FUNCTIONS_EMULATOR` - Local emulator toggle

## Testing

### Backend Tests
```bash
cd functions
npm test
# 21 tests passing
```

### Frontend Tests
```bash
flutter test
# 43+ tests passing, 4 skipped
```

### Smoke Tests
```bash
# Placement quiz
curl -X POST https://us-east4-aelion-c90d2.cloudfunctions.net/placementQuizStartLive \
  -H "Content-Type: application/json" \
  -d '{"topic":"Francés Básico","lang":"es"}'

# Module generation
curl -X POST https://us-east4-aelion-c90d2.cloudfunctions.net/adaptiveModuleGenerate \
  -H "Content-Type: application/json" \
  -d '{"topic":"SQL","band":"intermediate","nextModuleNumber":1}'
```

## Troubleshooting

| Issue | Resolution |
|-------|------------|
| App Hosting port error | Check PORT=8080 in apphosting.yaml |
| Missing firebase-admin | Ensure package.json includes firebase-admin@13.5.0 |
| CORS errors | Verify SERVER_ALLOWED_ORIGINS in apphosting.yaml |
| Quiz off-topic questions | Backend validates topic in prompt (fixed) |
| Mojibake (â€¢) | UTF-8 encoding fixed in all UI files |
| Duplicate modules | Removed legacy _buildModuleCard function |

## CI/CD

Workflow: `.github/workflows/ci.yml`
- Flutter analyze + test + build
- Functions build + test (Node.js 20)
- Gitleaks security scanning

## Observability

All API calls log to Firestore `observability` collection:
- Route, timestamp, user, cache status
- Token usage, cost (USD)
- Request parameters
- Response metadata

## Documentation

- [CONTEXT_V2.md](CONTEXT_V2.md) - Complete project context
- [DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md) - Deployment procedures
- [BUG_REPORT_27NOV_2025.md](BUG_REPORT_27NOV_2025.md) - Critical bugs (fixed)

## License

Proprietary - Edaptia Learning Platform

---

Built with ❤️ using Flutter, Firebase, and GPT-4o
