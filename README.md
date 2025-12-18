# Edaptia [![CI](https://github.com/Edaptia/Edaptia/actions/workflows/ci.yml/badge.svg)](https://github.com/Edaptia/Edaptia/actions/workflows/ci.yml)

**Tu tutor personal impulsado por IA.** Genera cursos personalizados en tiempo real sobre cualquier tema que quieras aprender: desde SQL y Python hasta Marketing y Excel. Contenido adaptado a tu nivel, a tu ritmo.

Built with Flutter, Firebase, and OpenAI GPT-4o with intelligent caching, defensive parsing, and real-time adaptive content generation.

## Production Status (Dec 17, 2024)

- **Play Store Beta**: 🚀 **LIVE** - https://play.google.com/apps/testing/com.aelion.learning
- **Landing Page**: ✅ https://www.edaptia.io
- **GitHub CI**: ✅ CONFIGURED
- **Firebase Functions**: ✅ DEPLOYED
- **Backend Server**: https://aelion-110324120650.us-east4.run.app
- **Beta Mode**: ✅ ALL USERS HAVE PREMIUM ACCESS (during beta)
- **Adaptive Storytelling**: ✨ **NEW** - Explicit visualization of personalization

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

### 🎭 Adaptive Storytelling (Dec 17, 2024) - **LATEST**

**Problem Solved:** "Users don't see WHAT adapted based on their quiz"

**New Features:**
- ✨ **AdaptationResultScreen** - Post-quiz visualization showing:
  * Detected level (Beginner/Intermediate/Advanced) with visual design
  * Specific content adjustments (what's omitted, prioritized, reinforced)
  * 3 personalized adaptations per level
  * Smooth animations and band-specific colors
- 🎯 **Humanized Quiz Copy** - Changed from "exam" language to "personalization":
  * "Personaliza tu camino" instead of "Quiz de calibración"
  * "Ayúdanos a conocerte" instead of "Pregunta X/Y"
  * Psychology icon instead of quiz icon
- 📚 **Preview Badge** - Clear context that micro-lesson is initial sample
- 🎨 **Visual Design System** - Gradient backgrounds, icon system, smooth UX

**Impact:** Users now UNDERSTAND and TRUST the adaptation (solves perception crisis)

**Branch:** `feat/adaptive-storytelling`

---

### 🚀 Previous Updates

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

## 🔧 Beta Mode Configuration

### Disabling Beta Mode for Production

When you're ready to launch to production and re-enable premium features, follow these steps:

#### 1. Update Beta Configuration
**File:** `lib/config/beta_config.dart`

```dart
// Change from:
const bool isBetaMode = true;

// To:
const bool isBetaMode = false;
```

Also update feature flags:
```dart
class BetaConfig {
  static const bool simplifiedFlow = false;      // Disable simplified onboarding
  static const bool allowTopicSelection = true;  // Enable free topic selection
  static const bool optionalQuiz = false;        // Make quiz required
  static const bool enhancedAnalytics = true;    // Keep analytics enabled
}
```

#### 2. Re-enable Premium Paywall (Revert Beta Bypass)

**IMPORTANT:** During beta, premium features are bypassed - ALL users have free access to M2-M6.

**File:** `lib/services/entitlements_service.dart`

Find the beta bypass flag around line 29:

```dart
// ⚠️ BETA MODE: Todos los usuarios tienen acceso premium gratis
// TODO: Cambiar a false antes de lanzar en producción
const bool _isBetaMode = true;

bool get hasPremiumAccess {
  // Durante beta, todos tienen acceso premium gratis
  if (_isBetaMode) return true;  // ← THIS BYPASSES THE PAYWALL
  return _isPremium || isInTrial;
}
```

**Change to:**

```dart
// Production mode - paywall enabled
const bool _isBetaMode = false;

bool get hasPremiumAccess {
  // Production: require premium or active trial
  if (_isBetaMode) return true;
  return _isPremium || isInTrial;  // ← NOW PAYWALL IS ENFORCED
}
```

**What this does:**
- `_isBetaMode = true` → ALL users bypass paywall (beta behavior)
- `_isBetaMode = false` → Paywall enforced, only premium/trial users access M2+

#### 3. Verification Checklist

Before deploying to production:

- [ ] `lib/config/beta_config.dart` - Set `isBetaMode = false`
- [ ] `lib/services/entitlements_service.dart` - Set `_isBetaMode = false`
- [ ] Run `flutter analyze` - No warnings
- [ ] Run `flutter test` - All tests pass
- [ ] Test premium paywall appears for M2+ modules
- [ ] Test trial activation flow works
- [ ] Test purchase flow completes successfully
- [ ] Update version in `pubspec.yaml` (e.g., `1.0.0+6`)
- [ ] Create git tag: `git tag -a v1.0.0+6-production -m "Production release"`
- [ ] Push tag: `git push origin v1.0.0+6-production`

#### 4. Rollback Procedure (If Needed)

If issues arise in production:

```bash
# List available tags
git tag -l

# Checkout previous stable version
git checkout v1.0.0+5-beta-stable

# Create hotfix branch
git checkout -b hotfix/rollback-beta-config

# Make necessary fixes, then deploy
```

### Beta Mode Features & Premium Bypass

#### Current Beta Bypass (Active)

When `isBetaMode = true` in `lib/services/entitlements_service.dart`:

**Premium Bypass Active:**
- ✅ **M1 (Module 1):** Always free (normal behavior)
- ✅ **M2-M6 (Modules 2-6):** FREE for ALL users (normally requires premium)
- ✅ No 7-day trial restrictions
- ✅ No purchase prompts or paywall modals
- ✅ `hasPremiumAccess` always returns `true`
- ✅ `isModuleUnlocked()` returns `true` for ALL modules

**What Gets Bypassed:**
```dart
// In production: M2+ requires premium or trial
bool isModuleUnlocked(String moduleId) {
  if (_isBetaMode) return true;  // ← BYPASS: Always unlocked

  // Normal logic (only runs when _isBetaMode = false):
  if (moduleId == 'M1') return true;
  return hasPremiumAccess;  // Would check subscription status
}
```

**Beta Testing Benefits:**
- Testers can access full curriculum without payment
- Test complete learning journey (M1 → M6)
- Validate premium content quality before monetization
- Gather feedback on all features

#### Simplified Onboarding (Optional)

If `BetaConfig.simplifiedFlow = true`:
- Topic selection defaults to "SQL" for focused testing
- Enhanced analytics tracking for Google Play metrics
- Optional quiz flow (can skip directly to lessons)

**Analytics events tracked:**
- `topic_submitted` - When user selects a learning topic
- `first_lesson_viewed` - First lesson engagement
- `first_lesson_completed` - Lesson completion
- `quiz_started` - Quiz attempt initiated
- `quiz_completed` - Quiz completion with band/score
- `second_session_within_48h` - Retention metric

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
