# Privacy Policy and AI Transparency Implementation

## Context
Edaptia is preparing for Google Play Store submission. Two critical requirements remain:
1. **Privacy Policy** - REQUIRED by Play Store for apps collecting user data
2. **AI Transparency Disclosure** - RECOMMENDED best practice for AI-generated content

Both are NON-BLOCKING for beta launch but REQUIRED before public Play Store submission.

---

## TASK 1: Create Privacy Policy

### Overview
Create a comprehensive Privacy Policy that complies with:
- Google Play Store requirements
- GDPR (European users)
- CCPA (California users)
- General data protection best practices

### Data Collection Inventory

**Personal Information:**
- Email address (Firebase Auth)
- Display name (optional, from Google Sign-In or manual input)
- User ID (Firebase UID)
- Device information (via Firebase Analytics)

**Usage Data:**
- Course progress and quiz results
- Lesson completion timestamps
- Module unlocks and progression
- Learning preferences and goals (from onboarding)
- Skill assessment data (placement quiz results)

**Analytics Data (via PostHog):**
- App usage patterns
- Feature engagement
- Session duration
- Screen views
- Error tracking (via Firebase Crashlytics)

**Subscription Data:**
- Google Play subscription status
- Purchase tokens (stored in Firestore)
- Subscription expiry dates
- Payment history (managed by Google Play)

**AI-Generated Content:**
- User inputs to AI (course topics, learning goals)
- AI-generated responses (lesson content, quiz questions)
- User feedback on AI content

### File to Create

**Path:** `assets/privacy_policy.html`

**Content Requirements:**

1. **Information We Collect**
   - List all data types from inventory above
   - Explain HOW we collect (Firebase Auth, user input, automatic)
   - Explain WHY we collect (personalization, progress tracking, analytics)

2. **How We Use Your Information**
   - Personalized learning paths with AI
   - Progress tracking and analytics
   - Account management
   - Service improvement
   - Legal compliance

3. **Data Sharing and Third Parties**
   - Firebase (Google) - hosting, auth, database
   - OpenAI - AI content generation (clarify: prompts sent, responses received)
   - PostHog - analytics
   - Google Play - payment processing
   - **IMPORTANT:** State explicitly: "We do NOT sell your personal data"

4. **Data Storage and Security**
   - Firestore security rules (mention they're active)
   - Encryption in transit (HTTPS)
   - Server-side verification for purchases
   - Data retention: kept until account deletion

5. **Your Rights**
   - Access your data (via Settings > Export Data)
   - Delete your account (via Settings > Delete Account)
   - Opt-out of analytics (via Settings > Privacy)
   - Request data correction
   - Withdraw consent

6. **Children's Privacy**
   - Minimum age: 13+ (or 16+ for EU)
   - No intentional collection from children under minimum age
   - Parent consent mechanisms (if applicable)

7. **AI-Generated Content Disclaimer**
   - Content is generated using OpenAI's API
   - May contain inaccuracies or biases
   - Users should verify critical information
   - User inputs to AI are processed but not shared publicly

8. **Changes to This Policy**
   - How users will be notified (email, in-app notification)
   - Effective date of changes

9. **Contact Information**
   - Email: privacy@edaptia.io (or support@edaptia.io)
   - Physical address (if required)
   - Response timeframe: within 30 days

10. **Legal Compliance**
    - GDPR compliance statement (for EU users)
    - CCPA compliance statement (for California users)
    - Governing law: specify jurisdiction

**Format:**
- HTML for web hosting
- Mobile-responsive design
- Clear headings and sections
- Easy-to-read font (16px minimum)
- Last updated date at top
- Table of contents with anchor links

**Tone:**
- Clear and accessible (not legal jargon)
- Transparent about data practices
- User-friendly language
- Bullet points for readability

**Example Structure Template:**

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Política de Privacidad - Edaptia</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        h1 { color: #2563eb; font-size: 2em; margin-bottom: 0.5em; }
        h2 { color: #1e40af; font-size: 1.5em; margin-top: 1.5em; }
        h3 { color: #1e3a8a; font-size: 1.2em; margin-top: 1.2em; }
        p { margin: 1em 0; }
        ul { margin: 0.5em 0; padding-left: 2em; }
        li { margin: 0.5em 0; }
        .updated { color: #666; font-size: 0.9em; margin-bottom: 2em; }
        .toc { background: #f3f4f6; padding: 1em; border-radius: 8px; margin: 2em 0; }
        .toc ul { list-style: none; padding-left: 0; }
        .toc a { color: #2563eb; text-decoration: none; }
        .toc a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Política de Privacidad</h1>
    <p class="updated">Última actualización: [DATE]</p>

    <div class="toc">
        <h3>Tabla de Contenidos</h3>
        <ul>
            <li><a href="#informacion-recopilamos">1. Información que Recopilamos</a></li>
            <li><a href="#como-usamos">2. Cómo Usamos tu Información</a></li>
            <!-- Add all sections -->
        </ul>
    </div>

    <h2 id="informacion-recopilamos">1. Información que Recopilamos</h2>
    <h3>Información Personal</h3>
    <ul>
        <li><strong>Correo electrónico:</strong> Recopilado al registrarte para gestionar tu cuenta.</li>
        <li><strong>Nombre:</strong> Opcional, obtenido de Google Sign-In o ingresado manualmente.</li>
        <!-- Continue with all data types -->
    </ul>

    <!-- Continue with all sections -->

    <h2 id="contacto">10. Contacto</h2>
    <p>Si tienes preguntas sobre esta Política de Privacidad, contáctanos:</p>
    <ul>
        <li><strong>Email:</strong> privacy@edaptia.io</li>
        <li><strong>Respuesta:</strong> Dentro de 30 días</li>
    </ul>
</body>
</html>
```

**Also create English version:** `assets/privacy_policy_en.html`

---

## TASK 2: Link Privacy Policy in App

### File to Modify: `lib/features/settings/settings_view.dart`

**Current Location:** After line 176 (subscription section)

**Add New Section:**

```dart
const Divider(),
const SizedBox(height: 8),
ListTile(
  leading: const Icon(Icons.privacy_tip_outlined),
  title: const Text('Política de Privacidad'),
  subtitle: const Text('Cómo manejamos tus datos'),
  trailing: const Icon(Icons.open_in_new, size: 20),
  onTap: () async {
    final url = Uri.parse('https://edaptia.io/privacy-policy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir la política de privacidad'),
        ),
      );
    }
  },
),
ListTile(
  leading: const Icon(Icons.gavel_outlined),
  title: const Text('Términos de Servicio'),
  subtitle: const Text('Condiciones de uso de la app'),
  trailing: const Icon(Icons.open_in_new, size: 20),
  onTap: () async {
    final url = Uri.parse('https://edaptia.io/terms-of-service');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir los términos de servicio'),
        ),
      );
    }
  },
),
```

**Import Required:**
```dart
import 'package:url_launcher/url_launcher.dart';
```

**Note:** The URLs point to edaptia.io - you'll need to host the HTML files there or use a GitHub Pages fallback.

---

## TASK 3: Add AI Transparency Disclaimers

### Location 1: When Generating Courses

**File:** `lib/features/adaptive_journey/adaptive_journey_screen.dart`

**Find:** The skeleton/loading UI when generating modules (around line 800+)

**Add below the loading indicator:**

```dart
const SizedBox(height: 16),
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.blue.shade50,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.blue.shade200),
  ),
  child: Row(
    children: [
      Icon(Icons.auto_awesome, size: 20, color: Colors.blue.shade700),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'Contenido generado con IA. Puede contener imprecisiones.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue.shade700,
          ),
        ),
      ),
    ],
  ),
),
```

### Location 2: Quiz Generation Screen

**File:** `lib/features/quiz/module_gate_quiz_screen.dart`

**Find:** The `_GateQuizSkeleton` widget (around line 727)

**Add after the loading messages:**

```dart
const SizedBox(height: 16),
Container(
  margin: const EdgeInsets.symmetric(horizontal: 24),
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.amber.shade50,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.amber.shade200),
  ),
  child: Row(
    children: [
      Icon(Icons.info_outline, size: 18, color: Colors.amber.shade900),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'Las preguntas son generadas con IA basándose en el contenido del módulo.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.amber.shade900,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  ),
),
```

### Location 3: Onboarding/Welcome Screen

**File:** `lib/features/home/home_view.dart`

**Find:** The "Generar plan con IA" search box (around line 200+)

**Add below the TextField:**

```dart
Padding(
  padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.auto_awesome, size: 14, color: Colors.grey.shade600),
      const SizedBox(width: 4),
      Text(
        'Contenido personalizado con IA',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
        ),
      ),
    ],
  ),
),
```

---

## TASK 4: Add AI Disclosure to App Info (Optional but Recommended)

### File to Modify: `lib/features/support/help_support_screen.dart`

**Add new section in the help/about screen:**

```dart
ListTile(
  leading: const Icon(Icons.psychology_outlined),
  title: const Text('Acerca de la IA'),
  subtitle: const Text('Cómo usamos inteligencia artificial'),
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.blue),
            SizedBox(width: 8),
            Text('Inteligencia Artificial en Edaptia'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edaptia usa IA para personalizar tu experiencia de aprendizaje:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• Generación de módulos y lecciones adaptadas a tu nivel'),
              Text('• Creación de quizzes basados en tu progreso'),
              Text('• Recomendaciones de contenido personalizadas'),
              SizedBox(height: 12),
              Text(
                'Transparencia:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'El contenido es generado usando la API de OpenAI (GPT-4). '
                'Aunque nos esforzamos por ofrecer contenido preciso, la IA '
                'puede ocasionalmente generar información incorrecta o sesgada. '
                'Recomendamos verificar información crítica con fuentes adicionales.',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 12),
              Text(
                'Privacidad:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Tus inputs a la IA (como temas de cursos) se envían a OpenAI '
                'para procesamiento, pero no se comparten públicamente ni se usan '
                'para entrenar modelos de OpenAI según su política de uso de API.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  },
),
```

---

## TASK 5: Update Localization Files

### File: `lib/l10n/app_es.arb`

**Add new keys:**

```json
"settingsPrivacyPolicy": "Política de Privacidad",
"settingsPrivacyPolicySubtitle": "Cómo manejamos tus datos",
"settingsTermsOfService": "Términos de Servicio",
"settingsTermsOfServiceSubtitle": "Condiciones de uso de la app",
"aiDisclaimerGenerating": "Contenido generado con IA. Puede contener imprecisiones.",
"aiDisclaimerQuiz": "Las preguntas son generadas con IA basándose en el contenido del módulo.",
"aiDisclaimerPowered": "Contenido personalizado con IA",
"aiAboutTitle": "Acerca de la IA",
"aiAboutSubtitle": "Cómo usamos inteligencia artificial"
```

### File: `lib/l10n/app_en.arb`

```json
"settingsPrivacyPolicy": "Privacy Policy",
"settingsPrivacyPolicySubtitle": "How we handle your data",
"settingsTermsOfService": "Terms of Service",
"settingsTermsOfServiceSubtitle": "App usage conditions",
"aiDisclaimerGenerating": "AI-generated content. May contain inaccuracies.",
"aiDisclaimerQuiz": "Questions are AI-generated based on module content.",
"aiDisclaimerPowered": "AI-powered personalized content",
"aiAboutTitle": "About AI",
"aiAboutSubtitle": "How we use artificial intelligence"
```

**After adding, run:**
```bash
flutter gen-l10n
```

---

## TASK 6: Update Disclaimers to Use Localization

**Update all hardcoded strings to use AppLocalizations:**

```dart
// Instead of:
Text('Contenido generado con IA. Puede contener imprecisiones.')

// Use:
Text(AppLocalizations.of(context)!.aiDisclaimerGenerating)
```

Apply this pattern to all AI disclosure strings added in Task 3.

---

## Testing Checklist

**Privacy Policy:**
- [ ] HTML file renders correctly on mobile
- [ ] All links work
- [ ] Responsive on different screen sizes
- [ ] English version available
- [ ] Settings links open external browser

**AI Disclaimers:**
- [ ] Visible during course generation
- [ ] Visible during quiz generation
- [ ] Visible on home screen search
- [ ] "About AI" dialog opens in help/support
- [ ] Localization works (ES/EN)

**Compliance:**
- [ ] Privacy Policy covers all data types
- [ ] Contact email is valid and monitored
- [ ] AI disclosure is clear and transparent
- [ ] No misleading statements

---

## Success Criteria

**Privacy Policy:**
✅ Comprehensive coverage of all data collection
✅ Clear explanation of AI usage
✅ GDPR/CCPA compliance statements
✅ User rights clearly explained
✅ Contact information provided
✅ Hosted and accessible via URL
✅ Linked from app Settings

**AI Transparency:**
✅ Disclaimers visible during AI operations
✅ Clear language about AI limitations
✅ User education about AI content
✅ Privacy implications explained

**Play Store Readiness:**
✅ Privacy Policy URL ready for Play Console
✅ App meets transparency requirements
✅ No blocking issues for submission

---

## Files to Create/Modify

**New Files:**
- `assets/privacy_policy.html`
- `assets/privacy_policy_en.html`

**Modified Files:**
- `lib/features/settings/settings_view.dart`
- `lib/features/adaptive_journey/adaptive_journey_screen.dart`
- `lib/features/quiz/module_gate_quiz_screen.dart`
- `lib/features/home/home_view.dart`
- `lib/features/support/help_support_screen.dart`
- `lib/l10n/app_es.arb`
- `lib/l10n/app_en.arb`

**Run After Completion:**
```bash
flutter gen-l10n
flutter analyze
flutter test
```

---

## Time Estimate
- Privacy Policy HTML: 25-30 minutes
- App integration: 10-15 minutes
- AI disclaimers: 15-20 minutes
- Localization: 5 minutes
- Testing: 10 minutes

**Total: 60-80 minutes**

---

## Hosting Privacy Policy

**Option 1: Firebase Hosting (Recommended)**
```bash
# In project root
mkdir -p public
cp assets/privacy_policy.html public/
cp assets/privacy_policy_en.html public/

# Deploy
firebase deploy --only hosting
```

**Option 2: GitHub Pages**
Create a `gh-pages` branch with the HTML files

**Option 3: edaptia.io Website**
Upload to your existing website at:
- https://edaptia.io/privacy-policy
- https://edaptia.io/terms-of-service

**Update URLs in settings_view.dart accordingly.**

---

**END OF SPECIFICATION**

This completes all remaining Play Store compliance requirements.
After implementation, the app is 100% ready for beta launch and Play Store submission.
