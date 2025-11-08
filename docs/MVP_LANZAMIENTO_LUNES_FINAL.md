# 🚀 MVP LANZAMIENTO LUNES - PLAN EJECUTABLE

> **Fecha Target:** Lunes 11 Nov 2025
> **Status:** DECISIONES FINALES TOMADAS
> **Executor:** IA Agent (este documento es input completo)

---

## ✅ DECISIONES FINALES CONFIRMADAS

### 1. Inglés Técnico: **PLACEHOLDER "Coming Soon"**
- NO generar contenido ahora
- Mostrar card en home: "Disponible Semana 2"
- Botón "Notify me"
- **Esfuerzo:** 30 min UI

### 2. Onboarding Questions: **SÍ INCLUIR**
- 5 preguntas antes de calibración:
  1. Rango de edad
  2. Temas de interés
  3. Escolaridad
  4. ¿Primera vez con SQL?
  5. ¿Quieres ser beta tester?
- **Esfuerzo:** 4 horas

### 3. Pricing: **$9.99/mes**
- Subscription mensual via Google Play Billing
- Trial 7 días incluido
- Acceso a todos los tracks futuros

### 4. Language: **EN + ES con switcher**
- Content ya existe:
  - `content/sql-marketing/question-bank-es.json` (100 preguntas)
  - `content/sql-marketing/question-bank-en.json` (100 preguntas)
- UI bilingüe con settings switcher

---

## 📦 ESTADO ACTUAL DEL PROYECTO

### ✅ LO QUE YA ESTÁ:

**Backend:**
- ✅ Firebase proyecto configurado
- ✅ Cloud Functions deployadas
- ✅ Assessment API (IRT algorithm) funcionando
- ✅ Firestore estructura multi-track
- ✅ Auth Firebase configurado
- ✅ Analytics GA4 integrado

**Content:**
- ✅ 100 preguntas SQL español (`question-bank-es.json`)
- ✅ 100 preguntas SQL inglés (`question-bank-en.json`)
- ✅ 6 módulos estructura (M1-M6)
- ✅ IRT params (a, b, c) para cada pregunta

**Flutter App:**
- ✅ Calibración IRT implementada
- ✅ Assessment flow E2E
- ✅ Paywall modal implementado
- ✅ M1 gratis, M2-M6 locked
- ✅ Analytics events (GA4)
- ✅ Crashlytics configurado

**Deployment:**
- ✅ Landing page `landing/index.html`
- ✅ DNS edaptia.io → Firebase configurado
- ✅ Firebase Hosting setup

### ❌ LO QUE FALTA (Implementar este fin de semana):

**Flutter UI (Viernes-Sábado):**
- [ ] Language switcher en Settings
- [ ] Onboarding 5 preguntas (nueva pantalla)
- [ ] "Tu nivel en 60s" reveal screen post-calibración
- [ ] Share button (LinkedIn/Twitter)
- [ ] "Inglés Técnico Coming Soon" card en home
- [ ] Localización strings (i18n ES/EN)

**Play Store (Sábado):**
- [ ] Crear cuenta desarrollador ($25)
- [ ] Configurar app en Google Play Console
- [ ] Google Play Billing ($9.99/mes subscription)
- [ ] Screenshots (6+ en ES, 6+ en EN)
- [ ] Store listing (descripción ES/EN)
- [ ] Build release AAB
- [ ] Upload a Internal Testing

**Testing (Domingo):**
- [ ] Smoke tests completos
- [ ] Verificar ambos idiomas
- [ ] Verificar paywall flow
- [ ] Fix bugs P0

---

## 🏗️ ARQUITECTURA TÉCNICA

### Stack:
```
Frontend: Flutter (Dart)
Backend: Firebase (Functions, Firestore, Auth, Storage)
Analytics: GA4 + Firebase Analytics
Crash Reporting: Firebase Crashlytics
Payment: Google Play Billing
Hosting: Firebase Hosting (landing page)
```

### Estructura de Archivos Clave:

```
aelion/
├── lib/
│   ├── features/
│   │   ├── assessment/          # Calibración IRT
│   │   ├── quiz/                # Assessment flow
│   │   ├── paywall/             # Paywall modal
│   │   └── home/                # Home screen
│   ├── services/
│   │   ├── api_service.dart     # Backend calls
│   │   ├── analytics_service.dart
│   │   └── auth_service.dart
│   └── main.dart
│
├── content/
│   └── sql-marketing/
│       ├── question-bank-es.json  # 100 preguntas español
│       └── question-bank-en.json  # 100 preguntas inglés
│
├── landing/
│   └── index.html               # Landing page
│
├── docs/
│   ├── TODO_MVP_5_DIAS.md       # Roadmap general
│   ├── LAUNCH_PLAN.md           # Estrategia launch
│   ├── PLAYSTORE_GUIDE.md       # Setup Play Store
│   ├── NAMECHEAP_DEPLOYMENT.md  # DNS config
│   └── MVP_LANZAMIENTO_LUNES_FINAL.md  # Este archivo
│
└── functions/
    └── src/
        └── index.ts             # Cloud Functions (outline, assessment)
```

---

## ⏰ TIMELINE EJECUTABLE - HORA POR HORA

### 🔴 VIERNES 8 NOV (8 horas)

**BLOQUE 1: Setup Play Store (2h - MAÑANA)**
```
[ ] 09:00-09:30 | Crear cuenta Google Play Developer ($25)
                 → https://play.google.com/console/signup

[ ] 09:30-10:00 | Crear app en Play Console
                 → Nombre: Edaptia
                 → Package: com.edaptia.aelion
                 → Idioma: Español (Spain) + English (US)

[ ] 10:00-11:00 | Configurar Google Play Billing
                 → Producto: Subscription
                 → ID: edaptia_premium_monthly
                 → Precio: $9.99 USD
                 → Trial: 7 días
```

**BLOQUE 2: Onboarding Screen (4h - TARDE)**
```
[ ] 14:00-15:00 | Crear OnboardingScreen.dart
                 → Ubicación: lib/features/onboarding/
                 → 5 pantallas secuenciales
                 → Guardar respuestas en Firestore

[ ] 15:00-16:00 | UI Questions (FormFields)
                 1. Edad: Dropdown (18-24, 25-34, 35-44, 45+)
                 2. Intereses: Multi-select chips
                 3. Escolaridad: Dropdown
                 4. SQL experience: Yes/No
                 5. Beta tester: Checkbox

[ ] 16:00-17:00 | Navigation logic
                 → main.dart: Mostrar onboarding si firstLaunch
                 → Guardar en local: hasCompletedOnboarding
                 → Skip button (can skip anytime)

[ ] 17:00-18:00 | Backend integration
                 → Firestore: users/{uid}/onboarding: {...}
                 → Analytics: track onboarding_completed
```

**BLOQUE 3: Language Switcher (2h - NOCHE)**
```
[ ] 19:00-19:30 | Setup i18n
                 → Agregar flutter_localizations
                 → Crear l10n/app_es.arb
                 → Crear l10n/app_en.arb

[ ] 19:30-20:30 | Settings screen
                 → Language selector: Español | English
                 → Guardar en SharedPreferences
                 → Restart app para aplicar

[ ] 20:30-21:00 | Traducir strings clave
                 → Home screen
                 → Assessment screen
                 → Paywall
                 → (No todo, solo MVP strings)
```

---

### 🟡 SÁBADO 9 NOV (10 horas)

**BLOQUE 1: "Tu nivel en 60s" Feature (3h - MAÑANA)**
```
[ ] 09:00-10:00 | AssessmentResultsScreen.dart
                 → Confetti animation
                 → Big card: "TU NIVEL: MID-LEVEL"
                 → Percentil: "Top 35% de 1,248 usuarios"

[ ] 10:00-11:00 | Stats calculation
                 → Calcular percentil desde theta (IRT)
                 → Usar distribución normal
                 → Mock total users = Firestore count

[ ] 11:00-12:00 | Share button
                 → share_plus package
                 → Text: "Soy {level} en SQL (Top {percentile}%)
                          en @Edaptia 🎯 edaptia.io"
                 → LinkedIn + Twitter intents
```

**BLOQUE 2: Play Store Assets (4h - TARDE)**
```
[ ] 14:00-15:00 | Screenshots Español (6+)
                 → Home screen
                 → Calibración
                 → Results screen
                 → M1 content
                 → Paywall
                 → Profile
                 → Usar simulator + screenshot tool

[ ] 15:00-16:00 | Screenshots English (6+)
                 → Switch language to EN
                 → Repeat screenshots

[ ] 16:00-17:00 | Graphic assets
                 → App icon: 512×512 (si no tienes, usar Figma/Canva)
                 → Feature graphic: 1024×500

[ ] 17:00-18:00 | Store listing
                 → Short description ES: (80 chars)
                   "Aprende SQL en 3 semanas. Adaptativo. Gratis módulo 1."
                 → Short description EN: (80 chars)
                   "Learn SQL in 3 weeks. Adaptive. Free module 1."
                 → Full description: Ver template abajo
```

**BLOQUE 3: Build & Upload (3h - NOCHE)**
```
[ ] 19:00-19:30 | Configurar signing keys
                 → Verificar android/key.properties existe
                 → Si no, generar keystore

[ ] 19:30-20:30 | Build release AAB
                 → flutter build appbundle --release
                 → Verificar output: build/app/outputs/bundle/release/app-release.aab
                 → Size check: < 50MB

[ ] 20:30-21:00 | Upload a Play Store
                 → Internal Testing track
                 → Upload AAB
                 → Esperar validación (5-30 min)

[ ] 21:00-22:00 | Create tester list
                 → 20-30 emails
                 → Enviar invitaciones Internal Testing
```

---

### 🟢 DOMINGO 10 NOV (6 horas)

**BLOQUE 1: Internal Testing (3h - MAÑANA)**
```
[ ] 09:00-10:00 | Install en tu device
                 → Aceptar invitación Internal Testing
                 → Install desde Play Store
                 → Smoke test básico

[ ] 10:00-11:00 | Test completo ES
                 → Onboarding 5 questions
                 → Calibración SQL
                 → Ver "Tu nivel en 60s"
                 → M1 funciona
                 → M2 muestra paywall
                 → Iniciar trial ($9.99/mes)
                 → Share button

[ ] 11:00-12:00 | Test completo EN
                 → Settings → Switch to English
                 → Repetir flujo completo
                 → Verificar traducciones
```

**BLOQUE 2: Bug Fixing (2h - TARDE)**
```
[ ] 14:00-15:00 | Fix bugs P0 (si hay)
                 → Crashes
                 → Paywall no funciona
                 → Language switch bugs

[ ] 15:00-16:00 | Re-build & upload
                 → Nueva versión si bugs críticos
                 → Update Internal Testing
```

**BLOQUE 3: Launch Prep (1h - TARDE)**
```
[ ] 16:00-16:30 | Preparar posts LinkedIn/Twitter
                 → Ver templates en LAUNCH_PLAN.md
                 → Agregar screenshots
                 → Schedule para mañana 9am

[ ] 16:30-17:00 | Dashboard GA4 check
                 → Verificar events llegando
                 → Configurar alertas
```

---

### 🚀 LUNES 11 NOV (3 horas)

**BLOQUE 1: Launch (MAÑANA)**
```
[ ] 09:00-09:30 | Mover Internal → Closed Testing
                 → Play Console: Promote to Closed Testing
                 → Expandir lista a 50-100 testers

[ ] 09:30-10:00 | Posts en redes
                 → LinkedIn post (template abajo)
                 → Twitter thread
                 → Compartir en grupos LATAM

[ ] 10:00-11:00 | Email a waitlist (si hay)
                 → Subject: "Edaptia Beta ya disponible 🚀"
                 → Link Play Store
                 → CTA: "Instala ahora"
```

**BLOQUE 2: Monitor (TODO EL DÍA)**
```
[ ] 11:00-13:00 | Dashboard monitoring
                 → GA4: Installs, calibrations, trials
                 → Crashlytics: 0 crashes esperados
                 → Play Console: Reviews/ratings

[ ] 14:00-18:00 | Responder usuarios
                 → Preguntas en Play Store
                 → Emails de beta testers
                 → Bugs reportados → Priorizar P0/P1
```

---

## 📝 TEMPLATES & ASSETS

### Store Listing Full Description (Español):

```
Edaptia: Aprende SQL en 3 semanas, no en 3 meses

¿Quieres dominar SQL para entrevistas técnicas o mejorar en tu trabajo?

Edaptia usa aprendizaje adaptativo (algoritmo IRT) para personalizar el contenido exactamente a tu nivel.

✅ QUÉ INCLUYE:
• Evaluación inicial que detecta tu nivel actual
• Plan personalizado de 6 módulos (SELECT, JOINs, Agregaciones, Funciones, Subconsultas, Window Functions)
• 100 preguntas SQL curadas para Marketing Analytics
• Contenido en español + inglés
• Módulo 1 GRATIS (sin tarjeta)
• Mock exam para practicar entrevistas

🎯 PARA QUIÉN:
• Marketing Analysts que necesitan SQL
• Developers aprendiendo SQL
• Cualquiera preparándose para entrevista SQL

💰 PRECIO:
• Módulo 1: Gratis
• Premium: $9.99/mes (acceso completo)
• Trial 7 días incluido

🚀 PRÓXIMAMENTE:
• Inglés Técnico para Devs (GRATIS)
• Python para Analistas
• Excel Avanzado

Descarga ahora y descubre tu nivel SQL en 60 segundos.
```

### LinkedIn Post (Lunes 9am):

```
🚀 Lanzamos Edaptia en Beta (Android)

Hace 5 días no existía. Hoy está en Play Store.

¿Qué es Edaptia?

La primera app de aprendizaje SQL adaptativo diseñada para LATAM.

✅ Evalúa tu nivel actual (60 segundos)
✅ Genera plan personalizado (6 módulos)
✅ Contenido en español + inglés
✅ M1 gratis. Premium $9.99/mes

¿Por qué lo construí?

DataCamp es excelente pero:
• Todo en inglés
• $400/año
• No adaptativo

Edaptia:
• Español + inglés
• $10/mes
• IRT precision (adapta dificultad en tiempo real)

Beta Android: [LINK PLAY STORE]

Busco 100 early adopters.
¿Quieres aprender SQL o conoces a alguien?

Comenta "SQL" y te envío el link 👇

#SQL #LATAM #EdTech #AppDevelopment
```

---

## 🐛 TROUBLESHOOTING COMÚN

### Build AAB falla:

```bash
# Error: Signing config no encontrado
# Fix:
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Configurar android/key.properties:
storePassword=tu_password
keyPassword=tu_password
keyAlias=upload
storeFile=C:/path/to/upload-keystore.jks
```

### Language switch no funciona:

```dart
// Verificar MaterialApp tiene localizationsDelegates
MaterialApp(
  locale: _currentLocale, // Cambiar aquí
  localizationsDelegates: [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en'),
    Locale('es'),
  ],
);
```

### Google Play Billing setup:

```dart
// pubspec.yaml
dependencies:
  in_app_purchase: ^3.1.11

// lib/services/subscription_service.dart
import 'package:in_app_purchase/in_app_purchase.dart';

final InAppPurchase _iap = InAppPurchase.instance;

Future<void> buySubscription() async {
  final ProductDetailsResponse response = await _iap.queryProductDetails(
    {'edaptia_premium_monthly'},
  );

  final ProductDetails product = response.productDetails.first;

  final PurchaseParam param = PurchaseParam(
    productDetails: product,
  );

  await _iap.buyNonConsumable(purchaseParam: param);
}
```

---

## ✅ CHECKLIST FINAL PRE-LAUNCH

**Viernes EOD:**
- [ ] Play Store account activa
- [ ] Google Play Billing configurado
- [ ] Onboarding 5 questions funcionando
- [ ] Language switcher funcionando

**Sábado EOD:**
- [ ] "Tu nivel en 60s" implementado
- [ ] Share button funciona
- [ ] Screenshots subidas (12+)
- [ ] AAB uploaded a Internal Testing

**Domingo EOD:**
- [ ] Smoke test completo (ES + EN) ✅
- [ ] 0 bugs P0
- [ ] Posts preparados
- [ ] Testers invitados

**Lunes 9am:**
- [ ] 🚀 LANZAR

---

## 🎯 MÉTRICAS DE ÉXITO (Primera Semana)

```
DÍA 1 (Lunes):
✅ 20+ installs
✅ 10+ calibraciones completadas
✅ 2+ trial starts (10% conversion)
✅ 0 crashes

DÍA 7 (Domingo):
✅ 100+ installs
✅ 50+ calibraciones completadas
✅ 6+ trial starts (6% conversion)
✅ 99% crash-free rate
✅ 40%+ D7 retention
```

---

## 📞 CONTACTO & SOPORTE

**Si algo se bloquea:**

1. Revisar Crashlytics
2. Revisar logs Play Console
3. Google: "flutter [error message]"
4. Stack Overflow
5. ChatGPT/Claude para debugging

**Archivos de referencia:**
- `docs/PLAYSTORE_GUIDE.md` - Setup detallado Play Store
- `docs/LAUNCH_PLAN.md` - Estrategia completa launch
- `docs/TODO_MVP_5_DIAS.md` - Roadmap general

---

**ESTE DOCUMENTO ES TU BIBLIA PARA EL FIN DE SEMANA.**

**TODO está aquí. NO preguntes. EJECUTA.** 🚀

---

**Última actualización:** 8 Nov 2025 15:30
**Próxima revisión:** Lunes 11 Nov post-launch
