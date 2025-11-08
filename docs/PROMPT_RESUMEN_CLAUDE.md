# 🤖 PROMPT RESUMEN - Para Claude (Nueva Sesión)

> **Uso:** Cuando abras nueva terminal de Claude Code sin contexto, copia y pega esto.

---

## PROYECTO: EDAPTIA MVP

**Qué es:** App móvil Android de aprendizaje SQL adaptativo para LATAM.

**Stack:** Flutter + Firebase (Functions, Firestore, Auth, Analytics, Crashlytics)

**Diferenciador:** Contenido técnico en español + IRT precision + "Inglés Técnico para Devs" gratis.

**Target Launch:** Lunes 11 Nov 2025 (Play Store Internal Testing)

---

## ESTADO ACTUAL

### ✅ COMPLETADO (9.0/10):

**Backend (100%):**
- Firebase completo: Functions, Firestore multi-track, Auth, GA4, Crashlytics
- Assessment API con IRT algorithm deployado
- Cloud Run server: https://assessment-api-110324120650.us-central1.run.app

**Content (100%):**
- `content/sql-marketing/question-bank-es.json` (100 preguntas SQL español)
- `content/sql-marketing/question-bank-en.json` (100 preguntas SQL inglés)
- Ambos archivos alineados (IDs, módulos, IRT params coinciden)

**App Flutter (80%):**
- Calibración IRT ✅
- Assessment flow E2E ✅
- Paywall (M1 gratis, M2-M6 locked) ✅
- Analytics GA4 ✅
- Crashlytics ✅

**Deployment:**
- Landing page `landing/index.html` ✅
- DNS edaptia.io → Firebase Hosting ✅

### ⏳ EN PROGRESO (Fin de semana):

**Features Finales:**
- [ ] Onboarding 5 preguntas (edad, intereses, escolaridad, SQL exp, beta tester)
- [ ] Language switcher (EN ↔ ES) en Settings
- [ ] "Tu nivel en 60s" reveal screen post-calibración
- [ ] Share button (LinkedIn/Twitter)
- [ ] "Inglés Técnico Coming Soon" card en home

**Play Store:**
- [ ] Cuenta Developer creada ($25)
- [ ] App configurada en Google Play Console
- [ ] Google Play Billing setup ($9.99/mes subscription)
- [ ] Screenshots (6+ ES, 6+ EN)
- [ ] Build AAB + upload Internal Testing

---

## DECISIONES FINALES TOMADAS

### Pricing: **$9.99/mes**
- Subscription mensual Google Play Billing
- Trial 7 días
- Acceso a todos tracks futuros

### Languages: **EN + ES con switcher**
- Content existe en ambos idiomas
- i18n setup con flutter_localizations
- Settings → cambiar idioma

### Inglés Técnico: **Placeholder "Coming Soon"**
- NO generar contenido ahora
- Card en home con "Notify me" button
- Disponible Semana 2

### Onboarding: **SÍ incluir**
- 5 preguntas antes de calibración
- Guardar en Firestore + Analytics
- Opción de skip

### Platform: **Android first**
- Play Store Internal Testing
- iOS en Fase 2

---

## ARQUITECTURA

```
aelion/
├── lib/
│   ├── features/
│   │   ├── onboarding/          # ← CREAR (fin de semana)
│   │   ├── assessment/
│   │   │   ├── quiz_screen.dart
│   │   │   └── assessment_results_screen.dart  # ← ACTUALIZAR
│   │   ├── paywall/
│   │   ├── home/
│   │   └── settings/            # ← LANGUAGE SWITCHER
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── analytics_service.dart
│   │   └── auth_service.dart
│   ├── l10n/                    # ← CREAR i18n
│   └── main.dart
│
├── content/
│   └── sql-marketing/
│       ├── question-bank-es.json  (100 preguntas ✅)
│       └── question-bank-en.json  (100 preguntas ✅)
│
├── landing/
│   └── index.html
│
├── docs/
│   ├── MVP_LANZAMIENTO_LUNES_FINAL.md  ← PLAN EJECUTABLE
│   ├── PROMPT_PARA_IA_EJECUTORA.md    ← PARA OTRA IA
│   ├── PROMPT_RESUMEN_CLAUDE.md       ← ESTE ARCHIVO
│   ├── TODO_MVP_5_DIAS.md
│   ├── LAUNCH_PLAN.md
│   ├── PLAYSTORE_GUIDE.md
│   └── audit/
│       └── AUDIT_SUMMARY.md
│
└── functions/
    └── src/
        └── index.ts
```

---

## TIMELINE RESTANTE

### 🔴 VIERNES 8 NOV (8h):
- Play Store setup
- Onboarding screen
- Language switcher

### 🟡 SÁBADO 9 NOV (10h):
- "Tu nivel en 60s" feature
- Screenshots
- Build AAB + upload

### 🟢 DOMINGO 10 NOV (6h):
- Internal testing
- Bug fixing
- Launch prep

### 🚀 LUNES 11 NOV:
- LANZAR

---

## CONTEXTO IMPORTANTE

### Conversación Previa:
- Usuario cuestionó ideas de "biblioteca tech" y "repositorio" → **Rechazadas** (scope creep)
- Usuario pidió ser más crítico y no complacer → **Aceptado**
- Analizamos competidor Primer (genérico) vs Edaptia (vertical)
- Decidimos NO hacer multi-track on-demand (demasiado complejo)
- Decidimos NO agregar foto detection (Mes 4+)

### Filosofía:
> "Better done than perfect. Better shipped than optimized."

**Lanzar LUNES con MVP funcional > esperar features perfectas.**

### Pricing Logic:
- $4.99 es muy bajo (CAC no se cubre)
- $9.99 es sweet spot (70% más barato que DataCamp)
- $10/mes = ~$120/año (impulse buy territory)

### Multi-idioma:
- NO es "nice to have", es diferenciador clave
- DataCamp solo tiene inglés
- LATAM market necesita español
- Content ya traducido (100 preguntas EN + ES)

---

## RECURSOS CLAVE

### Documentos a Leer:
1. **`docs/MVP_LANZAMIENTO_LUNES_FINAL.md`** → Plan hora por hora ejecutable
2. **`docs/PROMPT_PARA_IA_EJECUTORA.md`** → Prompt completo para otra IA
3. **`docs/PLAYSTORE_GUIDE.md`** → Setup Play Store detallado
4. **`docs/LAUNCH_PLAN.md`** → Estrategia launch + posts templates

### Comandos Útiles:
```bash
# Verificar content alignment
node validate-alignment.cjs

# Build release
flutter build appbundle --release

# Deploy landing
firebase deploy --only hosting

# Git status
git status
# Branch: agent/audit-remediation
```

### Links:
- Landing: https://edaptia.io (DNS configurado)
- Assessment API: https://assessment-api-110324120650.us-central1.run.app
- Firebase Console: https://console.firebase.google.com
- Play Store Console: https://play.google.com/console

---

## TU ROL (Claude Code)

### Cuando usuario pida ayuda:

1. **Leer primero:**
   - `docs/MVP_LANZAMIENTO_LUNES_FINAL.md`
   - `docs/TODO_MVP_5_DIAS.md`

2. **NO complacer ciegamente:**
   - Cuestionar scope creep
   - Priorizar brutalmente
   - "¿Esto es bloqueante para lunes?"

3. **Ser crítico:**
   - Si idea es buena → Decir por qué
   - Si idea es mala → Decir por qué (sin miedo)
   - Si idea es interesante pero NO PARA AHORA → Decir "Mes 2-3"

4. **Actualizar .md:**
   - Después de cambios importantes, actualizar docs
   - Mantener TODO_MVP_5_DIAS.md sincronizado
   - Commit cambios importantes

---

## COMMITS RECIENTES

```
e95cbca feat: Web launch strategy - edaptia.io + waitlist
bc7174e docs: Update launch strategy - Play Store first (no Stripe/iOS)
83ef0e5 feat: MVP 5 DÍAS COMPLETADO - Launch Ready 🚀
4b66183 feat: DÍA 4 - Polish, GA4 events & post-calibration paywall
72df55b feat: Implement paywall UI and gating - DÍA 3 100%
```

**Branch actual:** `agent/audit-remediation`

---

## SCOPE CREEP A EVITAR

### ❌ NO implementar (aunque suenen cool):

1. **"Biblioteca tech comunitaria"** → Mes 3-4 (necesita usuarios primero)
2. **Curso on-demand para cualquier tema** → Mes 3-4 (complejo, caro)
3. **Foto → detectar problema** → Mes 4+ (computer vision, no MVP)
4. **Leaderboard complejo** → Semana 2 (nice-to-have)
5. **Badges/Gamification** → Semana 2-3
6. **Track "Inglés Técnico" completo** → Semana 2 (placeholder ahora)

### ✅ SÍ implementar (bloqueantes):

1. Onboarding 5 preguntas
2. Language switcher
3. "Tu nivel en 60s" reveal
4. Share button
5. Play Store setup + Google Play Billing
6. Build AAB + upload

---

## MÉTRICAS DE ÉXITO

### Primera Semana:
```
✅ 100+ installs
✅ 50+ calibraciones completadas
✅ 6+ trial starts (6% conversion)
✅ 99% crash-free rate
✅ 40%+ D7 retention
```

### Signals de PMF:
- Users completan M1 Y regresan para M2
- Comparten results en LinkedIn
- Dejan reviews positivas Play Store
- Trial → Pago conversion > 30%

---

## CONTACTO

**Proyecto:** Edaptia (antes Aelion)
**Owner:** Usuario (founder/developer)
**Working directory:** `C:\Dev\aelion\aelion`
**Platform:** Windows (Git Bash)

---

## QUICK START (Nueva Sesión)

```bash
# 1. Leer estado
cat docs/MVP_LANZAMIENTO_LUNES_FINAL.md

# 2. Verificar git
git status
git log --oneline -5

# 3. Verificar content
ls -lh content/sql-marketing/*.json

# 4. Verificar Flutter
flutter doctor
flutter pub get

# 5. Preguntar al usuario:
# "¿En qué estás trabajando ahora?"
# "¿Necesitas ayuda con alguna feature específica?"
```

---

## MANTRA

> "Lanzar LUNES es no negociable. Todo lo demás es flexible."

**Prioridad #1:** Features bloqueantes para lunes
**Prioridad #2:** Testing + debugging
**Prioridad #3:** Nice-to-have (postponer sin culpa)

---

**Este prompt te da 90% del contexto. Para detalles, lee los .md mencionados.** 🚀

---

**Última actualización:** 8 Nov 2025 16:30
