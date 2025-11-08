# 🤖 PROMPT PARA IA EJECUTORA - MVP EDAPTIA LANZAMIENTO LUNES

> **Instrucción:** Copia y pega este prompt completo a otra IA (ChatGPT, Claude, etc.)

---

## TU ROL

Eres un **Senior Flutter Developer + DevOps Engineer** con experiencia en:
- Flutter/Dart mobile development
- Firebase (Firestore, Auth, Functions, Analytics, Crashlytics)
- Google Play Console & Google Play Billing
- App deployment (Android)
- i18n/l10n (multi-idioma)

Tu tarea: **Implementar el MVP de Edaptia para lanzar el LUNES 11 Nov 2025.**

---

## CONTEXTO DEL PROYECTO

### ¿Qué es Edaptia?

**Edaptia** es una app móvil (Android/iOS) de aprendizaje técnico adaptativo para LATAM.

**MVP Track:** SQL para Marketing (aprendizaje adaptativo con algoritmo IRT)

**Diferenciador único:** Contenido técnico en ESPAÑOL + "Inglés Técnico para Devs" gratis.

**Competidores:** DataCamp ($400/año, solo inglés), Primer (genérico), Coursera.

**Target:** Marketing analysts y developers LATAM que quieren aprender SQL.

---

## ESTADO ACTUAL (QUÉ YA ESTÁ)

### ✅ Backend Completo:
- Firebase proyecto: `edaptia-mvp` (o similar)
- Cloud Functions deployadas con IRT algorithm
- Firestore estructura multi-track lista
- Firebase Auth configurado
- GA4 + Crashlytics integrado

### ✅ Content Listo:
- `content/sql-marketing/question-bank-es.json` (100 preguntas SQL español)
- `content/sql-marketing/question-bank-en.json` (100 preguntas SQL inglés)
- IRT params (a, b, c) para cada pregunta
- Módulos M1-M6 definidos

### ✅ Flutter App Funcional (80% completo):
- Calibración IRT implementada
- Assessment flow E2E funcionando
- Paywall modal (M1 gratis, M2-M6 locked)
- Analytics events (GA4)
- Crashlytics

### ✅ Deployment:
- Landing page `landing/index.html`
- DNS edaptia.io → Firebase Hosting configurado

---

## TU TAREA - LO QUE FALTA

### 🔴 VIERNES 8 NOV (8 horas):

**1. Google Play Console Setup (2h)**
- Crear cuenta Google Play Developer ($25 one-time)
- Crear app "Edaptia" en Console
- Package name: `com.edaptia.aelion` (o el que ya esté en pubspec.yaml)
- Configurar Google Play Billing:
  - Product ID: `edaptia_premium_monthly`
  - Tipo: Subscription
  - Precio: $9.99 USD/mes
  - Trial: 7 días

**2. Onboarding Screen (4h)**

Crear nueva pantalla `lib/features/onboarding/onboarding_screen.dart`:

**5 preguntas secuenciales:**
1. **Edad:** Dropdown (18-24, 25-34, 35-44, 45+)
2. **Temas de interés:** Multi-select chips (SQL, Python, Excel, Data Analysis, Marketing)
3. **Escolaridad:** Dropdown (Secundaria, Universidad, Posgrado, Autodidacta)
4. **¿Primera vez con SQL?:** Yes/No buttons
5. **¿Quieres ser beta tester?:** Checkbox + text:
   ```
   "Edaptia está en desarrollo activo. Como beta tester:
   ✅ Recibirás actualizaciones antes que nadie
   ✅ Tendrás acceso a features experimentales
   ✅ Tu feedback nos ayuda a mejorar

   [✓] Sí, quiero ser beta tester"
   ```

**Implementación:**
```dart
class OnboardingScreen extends StatefulWidget {
  // PageView con 5 páginas
  // Botones: "Siguiente", "Anterior", "Saltar"
  // En última página: "Empezar" → main home
}

// Guardar respuestas en:
// 1. Firestore: users/{uid}/onboarding: { age, interests, education, ... }
// 2. Local: SharedPreferences: hasCompletedOnboarding = true
// 3. Analytics: logEvent('onboarding_completed', { age, interests, ... })
```

**Navigation:**
```dart
// main.dart
Widget build(BuildContext context) {
  return FutureBuilder<bool>(
    future: _checkOnboardingStatus(),
    builder: (context, snapshot) {
      if (snapshot.data == false) {
        return OnboardingScreen();
      }
      return HomeScreen();
    },
  );
}
```

**3. Language Switcher (2h)**

**Setup i18n:**
```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true
```

**Crear archivos:**
- `l10n.yaml`
- `l10n/app_es.arb` (español)
- `l10n/app_en.arb` (inglés)

**Traducir strings clave:**
```json
// app_es.arb
{
  "homeTitle": "Inicio",
  "startCalibration": "Descubre tu nivel",
  "module1Free": "Módulo 1 GRATIS",
  "unlockPremium": "Desbloquear Premium",
  "perMonth": "/mes"
}

// app_en.arb
{
  "homeTitle": "Home",
  "startCalibration": "Discover your level",
  "module1Free": "Module 1 FREE",
  "unlockPremium": "Unlock Premium",
  "perMonth": "/month"
}
```

**Settings screen:**
```dart
// lib/features/settings/settings_screen.dart

ListTile(
  title: Text('Language / Idioma'),
  subtitle: Text(_currentLanguage == 'es' ? 'Español' : 'English'),
  trailing: DropdownButton<String>(
    value: _currentLanguage,
    items: [
      DropdownMenuItem(value: 'es', child: Text('🇪🇸 Español')),
      DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
    ],
    onChanged: (String? newLang) {
      setState(() {
        _currentLanguage = newLang!;
        _saveLanguage(newLang);
        // Restart app to apply
        Phoenix.rebirth(context); // Usa package: flutter_phoenix
      });
    },
  ),
)
```

---

### 🟡 SÁBADO 9 NOV (10 horas):

**1. "Tu Nivel en 60s" Feature (3h)**

**Nueva pantalla post-calibración:**
```dart
// lib/features/assessment/assessment_results_screen.dart

class AssessmentResultsScreen extends StatelessWidget {
  final double theta; // IRT theta estimate (-3 to +3)
  final List<bool> responses;

  Widget build(BuildContext context) {
    final level = _getLevelFromTheta(theta);
    final percentile = _getPercentile(theta);

    return Scaffold(
      body: Column(
        children: [
          // Confetti animation
          ConfettiWidget(),

          // Big reveal card
          Card(
            child: Column([
              Text("TU NIVEL SQL", style: headline),
              Text(level, style: display1), // "MID-LEVEL"
              Text("Top $percentile% de 1,248 usuarios"),
            ]),
          ),

          // Skills you have
          _buildSkillsList(responses),

          // Skills to learn
          _buildGapsList(theta),

          // Personalized path
          _buildPathTree(),

          // Share button
          ElevatedButton.icon(
            icon: Icon(Icons.share),
            label: Text("Compartir en LinkedIn"),
            onPressed: () => _shareResults(level, percentile),
          ),

          // CTA
          ElevatedButton(
            child: Text("Empezar mi plan personalizado"),
            onPressed: () => Navigator.pushNamed(context, '/home'),
          ),
        ],
      ),
    );
  }

  String _getLevelFromTheta(double theta) {
    if (theta > 1.5) return "SENIOR";
    if (theta > 0.5) return "MID-LEVEL";
    if (theta > -0.5) return "JUNIOR";
    return "BEGINNER";
  }

  int _getPercentile(double theta) {
    // Normal CDF approximation
    // theta = 0 → 50th percentile
    // theta = 1 → ~84th percentile
    return (normalCDF(theta) * 100).round();
  }

  Future<void> _shareResults(String level, int percentile) async {
    await Share.share(
      'Soy $level en SQL (Top $percentile%) en @Edaptia 🎯\n\n'
      'Descubre tu nivel: https://edaptia.io',
    );
  }
}
```

**Packages needed:**
```yaml
dependencies:
  confetti: ^0.7.0
  share_plus: ^7.2.1
```

**2. "Inglés Técnico Coming Soon" Card (30 min)**

**En home screen:**
```dart
// lib/features/home/home_screen.dart

Column(
  children: [
    // Existing SQL track card...

    // NEW: Inglés Técnico placeholder
    Card(
      child: ListTile(
        leading: Icon(Icons.language, size: 48),
        title: Text("🌍 Inglés Técnico para Devs"),
        subtitle: Text("PRÓXIMAMENTE\nAprende términos técnicos, code review English, y más."),
        trailing: ElevatedButton(
          child: Text("NOTIFICARME"),
          onPressed: () {
            // Save to Firestore: waitlist_english_tech
            _notifyMeEnglishTech();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Te avisaremos cuando esté listo!")),
            );
          },
        ),
      ),
    ),
  ],
)
```

**3. Play Store Assets (4h)**

**Screenshots (usar emulator o device real):**

**Español (6 screenshots):**
1. Home screen (con "Descubre tu nivel")
2. Onboarding (pregunta 1-2)
3. Calibración en progreso
4. Results screen ("Tu nivel: MID-LEVEL")
5. M1 content screen
6. Paywall modal

**English (6 screenshots):**
- Cambiar idioma a English en settings
- Repetir los 6 screenshots

**App Icon (512×512):**
- Si no tienes, usar Figma/Canva template
- Colores: Púrpura (#667eea) + blanco
- Texto: "E" o logo simple

**Feature Graphic (1024×500):**
- Mockup de app + texto: "Learn SQL in 3 weeks"

**Store Listing Text:**
```
Short Description (ES):
Aprende SQL en 3 semanas. Adaptativo. Gratis módulo 1.

Short Description (EN):
Learn SQL in 3 weeks. Adaptive. Free module 1.

Full Description: Ver template en MVP_LANZAMIENTO_LUNES_FINAL.md
```

**4. Build & Upload AAB (3h)**

```bash
# 1. Verificar signing
cat android/key.properties
# Si no existe, crear keystore:
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# 2. Build release
flutter clean
flutter pub get
flutter build appbundle --release

# 3. Verificar output
ls -lh build/app/outputs/bundle/release/app-release.aab
# Should be < 50MB

# 4. Upload a Play Store
# → Google Play Console → Internal Testing → Create release
# → Upload app-release.aab
# → Add release notes (ver template)
# → Review → Start rollout to Internal testing
```

**Release notes template:**
```
Primera versión MVP:
• Calibración SQL adaptativa (IRT)
• 6 módulos de contenido (M1 gratis)
• Inglés + Español
• Paywall con trial 7 días
• "Tu nivel en 60s" reveal

Bugs conocidos: Ninguno

Feedback bienvenido: hola@edaptia.io
```

---

### 🟢 DOMINGO 10 NOV (6 horas):

**1. Internal Testing (3h)**

```bash
# 1. Install en tu device
# → Abrir email de invitación Internal Testing
# → Click "Accept invitation"
# → Install desde Play Store

# 2. Smoke test completo (ESPAÑOL)
[ ] App abre sin crash
[ ] Onboarding 5 preguntas completa
[ ] Calibración SQL 10 preguntas
[ ] Results screen muestra nivel + percentil
[ ] Share button funciona
[ ] M1 se puede abrir (gratis)
[ ] M2 muestra paywall
[ ] Iniciar trial ($9.99/mes) funciona
[ ] Google Play Billing flow completo

# 3. Smoke test completo (ENGLISH)
[ ] Settings → Switch to English
[ ] Repetir flujo completo
[ ] Verificar traducciones correctas
[ ] No crashes
```

**2. Bug Fixing (2h)**

**Si encuentras bugs P0:**
- Crashes
- Paywall no funciona
- Language switch rompe app
- Google Play Billing falla

→ Fix, rebuild, re-upload a Internal Testing

**3. Launch Prep (1h)**

```bash
# 1. Preparar posts
# Ver templates en MVP_LANZAMIENTO_LUNES_FINAL.md
# Agregar screenshots
# Schedule para mañana 9am

# 2. Dashboard GA4
# Firebase Console → Analytics → Dashboard
# Verificar events:
# - app_open
# - onboarding_completed
# - calibration_completed
# - trial_started
```

---

### 🚀 LUNES 11 NOV (3 horas):

**LAUNCH DAY**

```bash
# 09:00 - Promote to Closed Testing
# Play Console → Internal Testing → Promote to Closed Testing
# → Expandir lista de testers a 50-100 emails

# 09:30 - Posts en redes
# LinkedIn: Ver template en MVP_LANZAMIENTO_LUNES_FINAL.md
# Twitter: Thread con screenshots
# Grupos LATAM: Slack, Discord, WhatsApp

# 10:00-18:00 - Monitor
# → GA4 dashboard cada 2h
# → Crashlytics: 0 crashes esperados
# → Play Console: Reviews/ratings
# → Responder usuarios < 2h
```

---

## ARCHIVOS IMPORTANTES

**Ubicaciones clave:**
```
aelion/
├── lib/
│   ├── features/
│   │   ├── onboarding/          # ← CREAR ESTO
│   │   ├── assessment/
│   │   │   └── assessment_results_screen.dart  # ← ACTUALIZAR
│   │   ├── home/
│   │   │   └── home_screen.dart  # ← AGREGAR CARD INGLÉS
│   │   └── settings/
│   │       └── settings_screen.dart  # ← LANGUAGE SWITCHER
│   ├── l10n/                    # ← CREAR i18n
│   │   ├── app_es.arb
│   │   └── app_en.arb
│   └── main.dart                # ← ONBOARDING LOGIC
│
├── content/
│   └── sql-marketing/
│       ├── question-bank-es.json  # ← YA EXISTE
│       └── question-bank-en.json  # ← YA EXISTE
│
├── android/
│   ├── app/build.gradle         # ← VERIFICAR SIGNING
│   └── key.properties           # ← VERIFICAR EXISTE
│
└── docs/
    └── MVP_LANZAMIENTO_LUNES_FINAL.md  # ← LEER COMPLETO
```

---

## DECISIONES YA TOMADAS (NO PREGUNTES)

1. **Inglés Técnico:** Placeholder "Coming Soon" (NO generar contenido ahora)
2. **Onboarding:** SÍ incluir 5 preguntas
3. **Pricing:** $9.99/mes con trial 7 días
4. **Languages:** EN + ES con switcher
5. **Platform:** Android first (iOS después)
6. **Payment:** Google Play Billing (NO Stripe)

---

## TROUBLESHOOTING RÁPIDO

**Build AAB falla por signing:**
```bash
# Generar keystore nuevo
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# android/key.properties
storePassword=TU_PASSWORD_AQUI
keyPassword=TU_PASSWORD_AQUI
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

**Google Play Billing no funciona:**
```dart
// pubspec.yaml
dependencies:
  in_app_purchase: ^3.1.11

// lib/services/subscription_service.dart
final InAppPurchase _iap = InAppPurchase.instance;
const String _productId = 'edaptia_premium_monthly';

Future<void> buySubscription() async {
  final response = await _iap.queryProductDetails({_productId});
  final product = response.productDetails.first;
  await _iap.buyNonConsumable(
    purchaseParam: PurchaseParam(productDetails: product),
  );
}
```

**Language switch no actualiza UI:**
```dart
// Usar flutter_phoenix para restart completo
// pubspec.yaml
dependencies:
  flutter_phoenix: ^1.1.1

// Después de cambiar idioma:
Phoenix.rebirth(context);
```

---

## CHECKLIST EJECUTABLE

### ✅ VIERNES:
- [ ] Play Store Developer account ($25)
- [ ] App en Console creada
- [ ] Google Play Billing configurado ($9.99/mes)
- [ ] OnboardingScreen.dart creado
- [ ] 5 preguntas implementadas
- [ ] Firestore integration
- [ ] Language switcher en Settings
- [ ] i18n setup (ES + EN)

### ✅ SÁBADO:
- [ ] AssessmentResultsScreen mejorado
- [ ] Confetti animation
- [ ] Percentil display
- [ ] Share button
- [ ] "Inglés Técnico Coming Soon" card
- [ ] 12+ screenshots (6 ES, 6 EN)
- [ ] Store listing completo
- [ ] AAB built & uploaded

### ✅ DOMINGO:
- [ ] Smoke test ES completo
- [ ] Smoke test EN completo
- [ ] Bugs P0 fixed
- [ ] Posts preparados
- [ ] Dashboard GA4 verificado

### ✅ LUNES:
- [ ] 🚀 LANZAR

---

## OUTPUT ESPERADO

Al final del domingo, debes tener:

1. **App funcionando en Play Store Internal Testing**
   - Onboarding 5 preguntas ✅
   - Language switcher ✅
   - "Tu nivel en 60s" ✅
   - Share button ✅
   - Google Play Billing ✅

2. **Assets completos**
   - 12+ screenshots
   - Store listing ES + EN
   - Feature graphic

3. **Tests pasando**
   - 0 crashes
   - Ambos idiomas funcionan
   - Paywall flow completo

4. **Listos para launch lunes 9am**

---

## TU MANTRA

> "NO preguntar. EJECUTAR. El plan está completo. TODO está definido. SOLO IMPLEMENTAR."

**Si tienes duda técnica:** Google, Stack Overflow, ChatGPT.
**Si tienes duda de decisión:** La respuesta está en este prompt. Re-leer.

---

## RECURSOS ADICIONALES

- Docs oficiales Flutter i18n: https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
- Google Play Billing: https://developer.android.com/google/play/billing
- In-App Purchase Flutter: https://pub.dev/packages/in_app_purchase
- Share Plus: https://pub.dev/packages/share_plus
- Confetti: https://pub.dev/packages/confetti

---

**¡ÉXITO! Nos vemos el lunes con la app en Production.** 🚀

---

**Última actualización:** 8 Nov 2025 16:00
