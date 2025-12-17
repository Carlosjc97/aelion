# Edaptia [![CI](https://github.com/Edaptia/Edaptia/actions/workflows/ci.yml/badge.svg)](https://github.com/Edaptia/Edaptia/actions/workflows/ci.yml)

**Tu tutor personal impulsado por IA.** Genera cursos personalizados en tiempo real sobre cualquier tema que quieras aprender: desde SQL y Python hasta Marketing y Excel. Contenido adaptado a tu nivel, a tu ritmo.

 agent/audit-remediation
Built with Flutter, Firebase, and OpenAI GPT-4o with intelligent caching, defensive parsing, and real-time adaptive content generation.

## Production Status (Dec 14, 2024)

- **Play Store Beta**: 🚀 **LIVE** - https://play.google.com/apps/testing/com.aelion.learning
- **Landing Page**: ✅ https://www.edaptia.io
- **GitHub CI**: ✅ CONFIGURED

agent/audit-remediation
## Production Status (Nov 28, 2025)



## What's New (November 2025)
 main

- **GitHub CI**: ✅ PASSING (flutter + functions)
 main
- **Firebase Functions**: ✅ DEPLOYED
- **Backend Server**: https://aelion-110324120650.us-east4.run.app
- **Beta Mode**: ✅ ALL USERS HAVE PREMIUM ACCESS (during beta)

## What is Edaptia?

Edaptia is your **AI-powered personal tutor** that generates educational content adapted to your level in real-time. Instead of generic eternal courses, you get a **dynamic 4-12 module plan** with 3-7 minute lessons that adjust based on your performance.

### Key Features

- 🎯 **Choose ANY topic** - SQL, Python, Marketing, Excel, or anything you want to learn
- 🤖 **AI generates your course** - Personalized content created in real-time
- 📊 **Adaptive learning** - Difficulty adjusts based on your progress
- 🎮 **Smart quizzes** - Assessments that evolve with you
- 📈 **Progress tracking** - See your advancement in real-time
- 🌍 **Bilingual** - Available in Spanish and English

### For Whom

Professionals and teams who need fast results in:
- **Technology** (SQL, Python, .NET, JavaScript, etc.)
- **Business/Marketing** (Analytics, Growth, SEO)
- **Professional Languages** (English B1-B2)
- **Creative Skills** (Design, Writing, Video)

## What's New (Dec 2024)

- **🚀 Play Store Beta Launch** - Live on Google Play Closed Testing track
- **🎯 Beta Mode Active** - All users have premium access during beta testing
- **🎨 Logo Refresh** - New brain icon configured across app and web
- **📱 Signed App Bundle** - Production-ready v1.0.0+4 with proper signing
- **🌐 Landing Page Live** - Beta signup at https://www.edaptia.io
- **📝 Play Store Optimized** - SEO-optimized listings emphasizing multi-topic capability
- **🔒 Critical Security Fix** - Fixed cross-account data sharing bug (userId scoping)
- **📊 Lesson Progress Tracking** - Completely overhauled to persist correctly
- **✅ Module Unlock Logic** - Now requires both lesson completion AND quiz passage
- **🐛 Critical Bug Fixes** - Fixed 6 production blockers:
  - Cross-account data isolation (CRITICAL)
  - Lesson progress not persisting
  - Quiz failure wiping all progress
  - Module unlock requiring only quiz OR lessons (now AND)
  - UTF-8 encoding issues (mojibake) in Spanish
  - Crashlytics permission-denied errors
- **App Hosting Deployment** - Backend server now running on Cloud Run via Firebase App Hosting
- **Performance Boost** - Migrated from GPT-4o to GPT-4o-mini for most endpoints. 3x faster, 16x cost reduction
- **Timeout Fix** - Extended Functions timeout from 60s to 300s
- **Adaptive Lessons** - 8 specialized lesson types (quizzes, practice, games, projects)
- **Interactive UI** - Timeline-based adaptive journey with expandable modules
- **Daily Streaks** - Gamification with Firestore-backed streak tracking

## 🧪 Beta Testing Program

Join the beta testing program to be among the first to try Edaptia:

1. **Visit**: https://aelion-c90d2.web.app
2. **Sign up** with your email
3. **Receive** invitation email from `privacy@edaptia.io`
4. **Download** from Play Store (link in email) or Firebase App Distribution

### For Beta Testers
Once invited, you'll get:
- Early access to new features
- Direct feedback channel
- Special beta tester recognition
- Opportunity to shape the product

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
