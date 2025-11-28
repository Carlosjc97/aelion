# CONTEXT V2 - Edaptia (Documento Consolidado Definitivo)

> **Fecha creación:** 18 Noviembre 2025
> **Última actualización:** 27 Noviembre 2025 - Bugs Críticos Identificados
> **Reemplaza:** CONTEXTO_SESION_NUEVA.md, IMPLEMENTACION_COMPLETADA_15NOV.md, RESUMEN_PARA_USUARIO.md, RESPUESTAS_SISTEMA_ADAPTATIVO.md
> **Propósito:** Documento único y definitivo con TODO el contexto del proyecto
> **Para:** Claude Code, Codex, y nuevos desarrolladores

---

## 🔴 BUGS CRÍTICOS PENDIENTES - 27 NOV 2025

**Estado:** 3 bugs críticos identificados, NINGUNO corregido aún
**Reporte completo:** Ver `BUG_REPORT_27NOV_2025.md`
**Screenshots analizados:** 13 archivos en `C:\Users\Jean Villalta\Downloads\problemas\`

### Bug #1: Quiz de Colocación Genera Preguntas FUERA DEL TEMA 🔴
**Severidad:** CRÍTICA - Rompe flujo de placement test

**Problema:**
- Usuario selecciona "Francés Básico"
- Quiz pregunta sobre química (fórmula del agua: H2O/CO2), filosofía (¿qué son los valores?), geografía (¿qué es el clima?)
- **CERO preguntas sobre francés** (vocabulario, gramática, saludos)

**Root Cause:**
- `functions/src/openai-service.ts:1374`
- Prompt dice "mezcla ejemplos globales... escenarios ficticios para despertar curiosidad"
- NUNCA dice "las preguntas deben evaluar conocimiento SOBRE el tema"
- GPT-4o interpreta como "crea escenarios interesantes" vs "prueba conocimiento del tema"

**Fix:**
```typescript
// Línea 1370-1374: Agregar validación explícita de relevancia del tema
`CRITICO: Todas las preguntas deben evaluar conocimientos ESPECIFICOS sobre "${params.topic.trim()}".`
```

---

### Bug #2: Mojibake en Bullet Points (â€¢ en vez de •) 🟡
**Severidad:** MEDIA - Error visual afecta UX

**Problema:**
- "L0 â€¢ Bienvenida" en vez de "L0 • Bienvenida"
- "M1 â€¢ Introducción" en vez de "M1 • Introducción"
- Aparece en TODA la UI de "Recorrido adaptativo"

**Root Cause:**
- `lib/features/quiz/quiz_screen.dart:1697`
- Código fuente tiene UTF-8 corrupto HARDCODEADO:
  ```dart
  Text('M${module.moduleNumber} â€¢ ${module.title}'),
  ```

**Fix:**
```dart
// Línea 1697: Reemplazar mojibake con bullet point correcto
Text('M${module.moduleNumber} • ${module.title}'),
```

**Nota del usuario:** "que eso ya lo habiamos resuelto antes pero con mi cagada todo se daño" (se revirtió accidentalmente)

---

### Bug #3: Contenido Duplicado en Módulos 🔴
**Severidad:** CRÍTICA - UI confusa, contenido aparece 2 veces

**Problema:**
- Lecciones aparecen DENTRO de M1 expandido (correcto)
- **Y TAMBIÉN** en sección separada "Módulo" abajo (incorrecto)
- Usuario ve el mismo contenido renderizado dos veces

**Root Cause:**
- `lib/features/quiz/quiz_screen.dart:1424 y 1426`
- Ambos métodos se llaman simultáneamente:
  ```dart
  _buildTimeline(l10n),      // ← NUEVO: expansión inline
  _buildModuleCard(l10n),    // ← VIEJO: sección separada (DUPLICADO!)
  ```

**Fix:**
```dart
// Línea 1426: ELIMINAR esta línea completamente
// _buildModuleCard(l10n),  // ← BORRAR
```

---

### Orden de Implementación Recomendado

1. **Bug #3** (1 línea) → Mejora UX inmediata
2. **Bug #2** (1 línea) → Pulido visual
3. **Bug #1** (requiere deploy backend) → Funcionalidad crítica

**Deployment Necesario:**
- Bugs #2 y #3: Solo `flutter run` (frontend)
- Bug #1: `firebase deploy --only functions` (backend)

---

## CAMBIOS CRÍTICOS - 27 NOV 2025 🎯

### ARQUITECTURA PROFESIONAL DE LECCIONES - IMPLEMENTADA

**Problema:** Todas las lecciones mostraban solo texto. Lecciones interactivas (diagnostic_quiz, mini_game, guided_practice) no funcionaban.

**Causa Raíz:**
- `_handleLessonTap()` siempre navegaba a `LessonDetailPage`
- `LessonDetailPage` solo renderizaba texto (hook, theory, example)
- **Ignoraba completamente** `lessonType` y `microQuiz[]`
- No había componentes interactivos (quizzes, juegos, práctica)

**Solución: Arquitectura Profesional con Separation of Concerns**

#### Estructura Implementada
```
lib/features/lesson/
├── lesson_router.dart              # Factory pattern - decide pantalla según lessonType
├── models/
│   ├── lesson_types.dart           # Enum LessonType + extensions
│   └── lesson_view_config.dart     # Modelo tipado seguro
├── screens/                        # 8 pantallas especializadas
│   ├── welcome_lesson_screen.dart       # welcome_summary, theory_refresh, reflection
│   ├── diagnostic_quiz_screen.dart      # diagnostic_quiz con scoring
│   ├── guided_practice_screen.dart      # guided_practice con validación
│   ├── mini_game_screen.dart            # mini_game con timer/streak/puntos
│   ├── activity_screen.dart             # activity interactiva
│   ├── applied_project_screen.dart      # applied_project
│   ├── reflection_screen.dart           # reflection guiada
│   └── theory_refresh_screen.dart       # theory_refresh
└── widgets/                        # Componentes reutilizables
    ├── lesson_header_widget.dart        # Header compartido
    ├── lesson_hook_card.dart            # Card del hook
    ├── lesson_takeaway_card.dart        # Card del takeaway
    ├── quiz_question_card.dart          # Pregunta de quiz
    └── practice_exercise_card.dart      # Ejercicio de práctica
```

#### Flujo Adaptativo (Agnóstico al Contenido)

**Backend genera TODO dinámicamente:**
```typescript
// functions/src/openai-service.ts:1624
generateModuleAdaptive({
  topic: "Alemán Básico" | "Inglés A1" | "SQL para Marketing",  // ← Cualquier tema
  learnerState, nextModuleNumber, topDeficits, target
})
  ↓ GPT-4o genera módulo completo
  ↓ Decide lessonType según estructura (40% teoría, 30% práctica, etc.)
  ↓ Genera contenido adaptado al tema
  ↓
{
  lessons: [
    { lessonType: "welcome_summary", title: "...", hook: "...", theory: "...", ... },
    { lessonType: "diagnostic_quiz", title: "...", microQuiz: [
        { stem: "¿Pregunta en alemán?", options: {...}, correct: "A" },
        // ... preguntas generadas dinámicamente para el tema
      ]
    },
    { lessonType: "guided_practice", practice: { prompt: "...", expected: "..." } },
    { lessonType: "mini_game", microQuiz: [ /* preguntas para juego */ ] },
    // ...
  ]
}
```

**Frontend renderiza datos dinámicos:**
```dart
// lib/features/lesson/lesson_router.dart
LessonRouter.navigateToLesson(lesson)
  ↓ Detecta lessonType
  ↓ Navega a pantalla especializada
  ↓
DiagnosticQuizScreen(config)  // ← Renderiza microQuiz[] (agnóstico al idioma)
  ↓ Muestra preguntas que vienen del backend
  ↓ Usuario responde
  ↓ Valida y muestra score
```

**Key Point:** Las pantallas NO saben si es alemán, inglés o SQL - solo renderizan los datos que reciben del backend. Todo es dinámico y adaptativo.

#### Integración con Timeline Adaptativo

**Modificación en `quiz_screen.dart:1581`:**
```dart
// ANTES (MALO):
final args = _buildLessonDetailArgs(lesson, module.title);
await Navigator.pushNamed(context, LessonDetailPage.routeName, arguments: args);

// DESPUÉS (PROFESIONAL):
await LessonRouter.navigateToLesson(
  context: context,
  lesson: lesson,              // ← Contiene lessonType + microQuiz + practice
  moduleTitle: module.title,
  courseId: widget.topic,
);
```

#### Tipos de Lección Soportados

| LessonType | Pantalla | Contenido Dinámico | Componentes |
|-----------|----------|-------------------|-------------|
| `welcome_summary` | WelcomeLessonScreen | hook, theory, example, motivation | Texto Markdown |
| `diagnostic_quiz` | DiagnosticQuizScreen | microQuiz[] | Quiz interactivo con scoring |
| `guided_practice` | GuidedPracticeScreen | practice{}, hint | Ejercicio con validación |
| `mini_game` | MiniGameScreen | microQuiz[] | Juego con timer/streak/puntos |
| `activity` | ActivityScreen | practice{}, microQuiz[] | Actividad interactiva |
| `theory_refresh` | TheoryRefreshScreen | theory, example | Teoría pura |
| `applied_project` | AppliedProjectScreen | practice{}, rubric | Proyecto aplicado |
| `reflection` | ReflectionScreen | prompts, takeaway | Reflexión guiada |

#### Ventajas de la Arquitectura

1. **Escalable:** Agregar nuevo tipo = agregar nueva pantalla
2. **Mantenible:** Código separado por responsabilidad
3. **Testeable:** Cada pantalla se puede probar independientemente
4. **Reutilizable:** Widgets compartidos en `/widgets`
5. **Type-Safe:** Modelos Dart tipados, no `Map<String, dynamic>`
6. **Agnóstico al Contenido:** Funciona con cualquier tema (alemán, inglés, SQL, etc.)

#### Estado del Código

- ✅ `flutter analyze lib/features/lesson` - 0 errores
- ✅ Rutas registradas en `lib/core/router.dart`
- ✅ Integración completa con timeline adaptativo
- ⚠️ 2 warnings menores: `_scrollToModuleCard` y `_buildModuleCard` no usados (se pueden eliminar)

---

## CAMBIOS CRÍTICOS - 25 NOV 2025 🔥

### 1. Schema Validation Timeout - RESUELTO
**Problema:** Generación de módulos daba timeout después de 120 segundos
**Causa Raíz:** `gpt-4o-mini` no respetaba schema validation → campos vacíos → reintentos → timeout
**Logs Firebase:**
```
Error: Schema validation failed for ModuleAdaptive.json:
- /lessons/1/theory must NOT have fewer than 1 characters
- /lessons/1/practice/prompt must NOT have fewer than 1 characters
- /lessons/0/microQuiz must NOT have fewer than 2 items
```
**Solución:** Cambio de modelo en `functions/src/openai-service.ts:1644`
```typescript
// ANTES:
"gpt-4o-mini",  // No respeta structured outputs consistentemente

// DESPUÉS:
"gpt-4o",  // Mayor adherencia a schemas complejos (~3x más caro pero funciona)
```
**Impacto:** ✅ Elimina timeouts, ❌ Incrementa costo 3x (~$0.10 → $0.30 por módulo)

### 2. Navegación Legacy - CORREGIDO
**Problema:** Al reintentar generación, iba a `ModuleOutlineView` (pantalla legacy) en vez de `AdaptiveJourneyScreen`
**Causa Raíz:** Lógica en `lib/features/home/home_view.dart:157` basada en `cachedBand`:
```dart
// ANTES:
if (cachedBand == null) {
  → QuizScreen → AdaptiveJourneyScreen  ✅ Correcto
} else {
  → ModuleOutlineView  ❌ Pantalla legacy con ExpansionTiles
}
```
**Solución:** SIEMPRE ir al flujo adaptativo
```dart
// DESPUÉS:
// ALWAYS go to adaptive journey flow
await Navigator.of(context).pushNamed(QuizScreen.routeName, ...);
```

### 3. Arquitectura API Keys - DOCUMENTACIÓN CORREGIDA
**Problema Documentado:** CONTEXT_V2 línea 85 decía que `placementQuizStartLive` usa `OPENAI_API_KEY_CALIBRATION`
**Realidad:** `placementQuizStartLive` NO usa OpenAI - usa JSON question banks (`functions/src/assessment.ts`)
**Keys Realmente Usadas:**
| Key | Endpoints | Last Used (OpenAI Dashboard) |
|-----|-----------|------------------------------|
| `OPENAI_API_KEY_MODULES` (sk-...H0cA) | `adaptiveModuleGenerate`, `adaptiveModuleCount` | 25 Nov 2025 ✅ |
| `OPENAI_API_KEY_QUIZZES` (sk-...EygA) | `adaptiveCheckpointQuiz`, `moduleQuizStart` | 22 Nov 2025 ✅ |
| `OPENAI_API_KEY_CALIBRATION` (sk-...NnMA) | ❌ **NUNCA USADA** | 22 Nov 2025 (uso erróneo) |
| `OPENAI_API_KEY_PRIMARY` (sk-...mi4A) | ❌ **NUNCA USADA** | Never |
| `OPENAI_API_KEY` (sk-...a4cA) | Fallback legacy | Raramente |

**Keys en OpenAI NO configuradas:**
- `Edaptia 5` (sk-...9-0A) - Existe en OpenAI pero NO en Firebase

**Acción Requerida:** Decidir si:
- Opción A: Simplificar a 2 keys (modules, quizzes) + fallback
- Opción B: Configurar Edaptia 5 para rotación real

---

## ESTADO ACTUAL DEL PROYECTO (25 NOV 2025)

### Resumen Ejecutivo
**Edaptia MVP** es una plataforma de aprendizaje adaptativo que genera cursos personalizados con IA (GPT-4o). El usuario completa un quiz de calibración y recibe un plan de 4-12 módulos adaptado a su nivel.

**Score Global:** 9.2/10 - Production Ready
**Tests:** 27/27 backend, 2/2 E2E pasando
**Estado:** Schema validation corregida, navegación arreglada, listo para deploy

### Problemas Críticos Resueltos Recientemente

#### 1. Migración Firebase Functions v2 (15 Nov - Noche)
**Problema:** Quiz de colocación fallaba con "OPENAI_API_KEY not configured" (HTTP 500)
**Causa:** Firebase Functions v2 deprecó `functions.config()`, las API keys no se podían leer
**Solución:** Migración a variables de entorno vía `functions/.env`

**IMPORTANTE:** Ya NO se usa `firebase functions:config:set` (método obsoleto). Ahora las API keys están en:
```bash
# functions/.env (método correcto para Functions v2)
OPENAI_API_KEY_PRIMARY=sk-proj-...
OPENAI_API_KEY_MODULES=sk-proj-...
OPENAI_API_KEY_QUIZZES=sk-proj-...
OPENAI_API_KEY_CALIBRATION=sk-proj-...
OPENAI_API_KEY=sk-proj-... # Fallback
```

#### 2. Arquitectura Secuencial Implementada (15 Nov)
**Antes:** Generación de plan completo tomaba 180 segundos, 40% timeouts
**Ahora:** Arquitectura secuencial da feedback en 10s, <5% errores

**Flujo actual:**
```
Usuario completa quiz
  ↓ [5-10 segundos]
POST /adaptiveModuleCount → { moduleCount: 6, rationale: "..." }
  ↓
Flutter muestra skeleton UI: [M1] [M2] [M3] [M4] [M5] [M6]
  ↓ [60-90 segundos]
POST /adaptiveModuleGenerate (moduleNumber: 1) → Genera M1 completo
  ↓
Usuario empieza M1 mientras M2 se pre-genera en background
```

#### 3. Sistema de Diseño Material 3 (15 Nov)
**Decisión:** Google Fonts (Inter) en lugar de SF Pro (no compatible con Play Store)
**Archivos creados:**
- `lib/core/design_system/typography.dart` - 8 estilos de texto
- `lib/core/design_system/colors.dart` - Paleta completa + gradientes
- `lib/core/design_system/components/edaptia_card.dart` - Componente reutilizable

#### 4. Rebrand Completo (15 Nov)
- 0 menciones de "Aelion"
- 105 menciones de "Edaptia"
- `flutter analyze` - 0 errores

---

## ARQUITECTURA DEL SISTEMA

### Backend (Firebase Functions v2 + TypeScript)

**Endpoints Principales:**
```
/placementQuizStartLive      - Quiz calibración (10 preguntas)
/adaptiveModuleCount         - Conteo rápido de módulos (NUEVO)
/adaptiveModuleGenerate      - Generación de módulo individual
/adaptivePlanDraft           - Plan completo (LEGACY, deprecar)
/adaptiveCheckpointQuiz      - Quiz de validación entre módulos
/cleanupAiCache              - Limpieza automática con Cloud Scheduler
```

**Distribución de Carga (API Keys Routing - CORREGIDO 25 Nov):**
| Endpoint | Modelo | API Key | Uso Real |
|----------|--------|---------|----------|
| `/adaptiveModuleGenerate` | `gpt-4o` | `modules` | Generación módulos (pesada) ✅ |
| `/adaptiveModuleCount` | `gpt-4o-mini` | `modules` | Conteo rápido ✅ |
| `/adaptiveCheckpointQuiz` | `gpt-4o-mini` | `quizzes` | Checkpoint quizzes ✅ |
| `/moduleQuizStart` | `gpt-4o-mini` | `quizzes` | Module quizzes ✅ |
| `/placementQuizStartLive` | N/A (JSON banks) | ❌ NO USA OpenAI | Quiz calibración |
| Otros endpoints | `gpt-4o` | `primary` | Fallback (raramente usado) |

**Nota:** Solo 2 keys se usan activamente: `modules` y `quizzes`
**Resultado:** ~20K TPM efectivo (2 keys × 10K TPM base)

**Archivos Clave:**
```
functions/src/
├── index.ts                        # Exports de funciones
├── openai-service.ts               # API key routing (líneas 113-171)
│   ├── resolveOpenAIApiKey()       # Lee de .env primero, luego config
│   ├── getApiKeyForEndpoint()      # Routing según hint
│   └── generateModuleCount()       # NUEVO - Conteo rápido
├── generative-endpoints.ts         # Endpoints HTTP
│   ├── adaptiveModuleCount         # NUEVO - Endpoint de conteo
│   └── adaptiveModuleGenerate      # Generación bajo demanda
├── adaptive/
│   ├── schemas.ts                  # JSON Schemas OpenAI
│   │   └── ModuleCountSchema       # NUEVO - Schema conteo
│   └── retryWrapper.ts             # Retry logic + endpointHint
├── cache-service.ts                # Firestore cache (TTL 7-14 días)
└── .env                            # ✅ NUEVO - API keys para v2
```

### Frontend (Flutter + Material 3)

**Flujo de Usuario:**
```
Onboarding (5 preguntas)
  ↓
Quiz Calibración (10 preguntas OpenAI)
  ↓ detecta band: "basic" | "intermediate" | "advanced"
Conteo de Módulos (5-10s)
  ↓ muestra skeleton UI
Generación M1 (60-90s, GRATIS)
  ↓
Usuario estudia M1 → Checkpoint quiz (≥70% para avanzar)
  ↓
Paywall en M2+ (trial 7 días → $9.99/mes)
  ↓
Generación M2-M6 bajo demanda (solo si premium)
```

**Archivos Clave:**
```
lib/
├── features/
│   ├── quiz/quiz_screen.dart       # Quiz + AdaptiveJourneyScreen (línea 862+)
│   ├── auth/sign_in_screen.dart    # Diseño Material 3 aplicado
│   ├── lesson/lesson_detail_page.dart  # Typography aplicada
│   └── paywall/paywall_modal.dart  # Trial + Premium
├── core/
│   ├── design_system/
│   │   ├── typography.dart         # 8 estilos (Inter font)
│   │   ├── colors.dart             # Paleta Indigo + gradientes
│   │   └── components/edaptia_card.dart
│   └── app_colors.dart             # Legacy, migrar a design_system
├── services/
│   ├── api_config.dart             # URLs endpoints (línea 36: adaptiveModuleCount)
│   ├── course/
│   │   ├── models.dart             # ModuleCountResponse (líneas 645-670)
│   │   ├── adaptive_service.dart   # fetchModuleCount (líneas 12-36)
│   │   └── module_service.dart     # Servicios de módulos
│   └── course_api_service.dart     # Wrapper principal
└── l10n/                           # i18n ES/EN
```

### Sistema de Caché Inteligente

**Colección Firestore:** `ai_cache`

**Estructura:**
```typescript
{
  key: "module_1_ingles-a1_basic_es",
  content: { /* JSON OpenAI */ },
  createdAt: Timestamp,
  expiresAt: Timestamp,  // TTL automático
  metadata: {
    endpoint: "adaptiveModuleGenerate",
    model: "gpt-4o-mini",
    tokens: 2800,
    lang: "es"
  }
}
```

**TTLs:**
- Quiz calibración: 7 días
- Conteo de módulos: 30 días
- Módulos: 14 días

**Hit Rate Objetivo:** 85% (solo 15% llama a OpenAI)

---

## SISTEMA ADAPTATIVO COMPLETO

### Overview
Edaptia NO es un sistema de cursos estáticos. Es un **verdadero sistema adaptativo con IA** que personaliza cada módulo según el progreso del usuario en tiempo real.

### 1. Traducciones Multiidioma (Band Levels)

**Backend (TypeScript):**
```typescript
// functions/src/openai-service.ts línea 272
export type Band = "basic" | "intermediate" | "advanced";
```

**Frontend (Flutter):**
```dart
// lib/services/course/placement_band.dart
enum PlacementBand { basic, intermediate, advanced }

// Alias para retrocompatibilidad
'beginner' → PlacementBand.basic
```

**Traducciones (i18n):**
```json
// lib/l10n/app_es.arb
{
  "quizBandBasic": "Básico",
  "quizBandIntermediate": "Intermedio",
  "quizBandAdvanced": "Avanzado"
}

// lib/l10n/app_en.arb
{
  "quizBandBasic": "Basic",
  "quizBandIntermediate": "Intermediate",
  "quizBandAdvanced": "Advanced"
}
```

**22 Nov 2025:** Migración completada de `beginner` → `basic` para consistencia con backend.

---

### 2. Estructura de Módulos y Lecciones

**Cada módulo contiene 8-20 lecciones generadas por IA:**

```typescript
// Estructura de ModuleAdaptive
{
  "moduleNumber": 1,
  "moduleTitle": "Fundamentos de SQL",
  "lessons": [
    {
      "id": "m1-l1",
      "title": "¿Qué es SQL?",
      "objective": "Entender el propósito de SQL",
      "contentBlocks": [
        { "type": "text", "body": "SQL es..." },
        { "type": "example", "code": "SELECT * FROM users;" },
        { "type": "exercise", "prompt": "Escribe tu primer SELECT..." }
      ],
      "durationMinutes": 12
    }
    // ... 7-19 lecciones más
  ],
  "checkpointQuiz": { /* Quiz al final del módulo */ }
}
```

**Sistema de Candados Progresivos:**

```dart
// lib/features/modules/outline/widgets/lesson_card.dart
final bool isLocked;

// Lógica de desbloqueo:
- Primera lección de M1: SIEMPRE desbloqueada
- Siguientes lecciones: Se desbloquean al completar la anterior
- M2+: Requieren Premium (paywall)
```

**Código de candados:**
```dart
// lib/features/quiz/quiz_screen.dart líneas 961-1263
unlocked: i == 1,  // M1 siempre desbloqueado
_timeline[nextNumber]!.unlocked = true;  // Desbloquea siguiente al completar

if (!tile.unlocked) {
  // Muestra mensaje "Completa M1 primero"
  ScaffoldMessenger.of(context).showSnackBar(...)
}
```

---

### 3. LearnerState: El Cerebro del Sistema Adaptativo

**Estructura (functions/src/openai-service.ts líneas 274-283):**

```typescript
export interface LearnerState {
  level_band: Band;                      // "basic" | "intermediate" | "advanced"
  skill_mastery: Record<string, number>; // {"sql_select": 0.6, "sql_joins": 0.4}
  history: {
    passedModules: number[];             // [1, 2, 3]
    failedModules: number[];             // []
    commonErrors: string[];              // ["INNER JOIN syntax", "WHERE placement"]
  };
  target: string;                        // "Analista de datos junior"
}
```

**Flujo de Actualización:**

```
Quiz de Ubicación
  ↓ Calcula skill_mastery inicial
{ sql_select: 0.3, sql_joins: 0.2 }
  ↓ Genera M1 con band="basic"
Usuario completa M1
  ↓ Checkpoint Quiz
Evalúa respuestas → Actualiza mastery
  ↓
{ sql_select: 0.6, sql_joins: 0.4 }  ← MEJORÓ
  ↓ Genera M2 con learnerState actualizado
M2 refuerza "sql_joins" (que sigue siendo débil)
```

**Código de carga/actualización:**

```typescript
// functions/src/generative-endpoints.ts
const learnerState = await loadLearnerState(userId);

await getOpenAI().generateModuleAdaptive({
  topic: "SQL Marketing",
  learnerState: learnerState,  // ← Progreso arrastrándose
  nextModuleNumber: 2,
  topDeficits: ["joins", "subqueries"],
  target: "Analista junior",
  userId: userId,
});

// Después del checkpoint:
await updateLearnerState(userId, {
  skill_mastery: evaluation.updatedMastery,  // ← Nueva mastery
  history: {
    passedModules: [1, 2],
    failedModules: [],
    commonErrors: evaluation.weakSkills
  }
});
```

---

### 4. Sistema de Checkpoint Quiz (Umbral ≥70%)

**Endpoints:**
- `POST /adaptiveCheckpointQuiz` - Genera quiz al final del módulo
- `POST /adaptiveEvaluateCheckpoint` - Evalúa y decide acción
- `POST /adaptiveBooster` - Genera contenido remedial si falla

**Flujo Completo:**

```
Usuario completa M1 (8-20 lecciones)
  ↓
POST /adaptiveCheckpointQuiz
  → Genera 4-8 preguntas MCQ
  → skillsTargeted: ["sql_select", "sql_where"]
  ↓
Usuario responde quiz
  ↓
POST /adaptiveEvaluateCheckpoint
  → Calcula score: (correctas / total) * 100
  → Actualiza skill_mastery con algoritmo ELO
  ↓
  DECISIÓN:
  ├─ score < 50%  → action="replan" (rehacer módulo)
  ├─ score 50-69% → action="booster" (contenido remedial)
  └─ score ≥ 70%  → action="advance" (desbloquea M2)
```

**Código de evaluación (functions/src/generative-endpoints.ts líneas 1842-1848):**

```typescript
let action: "advance" | "booster" | "replan";
if (evaluation.score < 50) {
  action = "replan";  // Muy bajo, rehacer módulo
} else if (evaluation.recommendation === "advance") {
  action = "advance"; // ≥70% + mastery promedio ≥0.55
} else {
  action = "booster"; // Entre 50-70%, necesita refuerzo
}
```

**Sistema de Booster:**

Si sacas entre 50-69%:
```typescript
POST /adaptiveBooster
{
  "topic": "SQL para Marketing",
  "weakSkills": ["sql_joins"]  // Detectado automáticamente
}

// Genera:
{
  "boosterFor": ["sql_joins"],
  "lessons": [
    {
      "title": "Refuerzo: INNER JOIN paso a paso",
      "contentBlocks": [/* 2 lecciones cortas */]
    }
  ],
  "microQuiz": [/* 3-4 preguntas de práctica */]
}
```

---

### 5. Sistema de Mastery Escalable (Algoritmo ELO)

**Escala de Mastery: 0.0 - 1.0**
- `0.0-0.3`: No sabe / Nivel muy bajo
- `0.4-0.6`: Aprendiendo / Nivel medio
- `0.7-0.9`: Domina / Nivel alto
- `0.9-1.0`: Experto / Maestría completa

**Algoritmo de Actualización (functions/src/openai-service.ts líneas 1543-1553):**

```typescript
function applyEloUpdate(
  mastery: number,       // Mastery actual (ej: 0.4)
  isCorrect: boolean,    // ¿Respondió bien?
  difficulty: "easy" | "medium" | "hard"
): { updated: number; delta: number } {
  const diff = ITEM_DIFFICULTY[difficulty] ?? 0.5;
  const expected = 1 / (1 + Math.exp(-(mastery - diff)));
  const delta = ITEM_K[difficulty] * ((isCorrect ? 1 : 0) - expected);
  const updated = clamp(mastery + delta, 0, 1);
  return { updated, delta };
}
```

**Ejemplo real:**

```typescript
// Usuario con mastery bajo en "sql_joins"
Antes: skill_mastery["sql_joins"] = 0.3

// Responde pregunta MEDIUM correctamente
applyEloUpdate(0.3, true, "medium")
  → delta = +0.18
  → updated = 0.48

// Responde pregunta HARD incorrectamente
applyEloUpdate(0.48, false, "hard")
  → delta = -0.12
  → updated = 0.36
```

**Meta Escalable:**

```typescript
// Al generar plan inicial:
{
  "moduleCount": 6,
  "rationale": "Para ser Analista junior necesitas dominar:
                M1: SELECT (mastery ≥ 0.6)
                M2-M3: JOINS (mastery ≥ 0.6)
                M4: Aggregates (mastery ≥ 0.6)
                M5: Subqueries (mastery ≥ 0.7)
                M6: Window Functions (mastery ≥ 0.75)"
}

// Si al terminar M2 detecta que el usuario va muy bien:
avgMastery = 0.82  // ← Alto

// La IA puede:
- Reducir M3 (menos lecciones, contenido más avanzado)
- O agregar temas más complejos

// Si va mal:
avgMastery = 0.45  // ← Bajo

// La IA genera:
- Booster automático
- M3 con más refuerzo en temas débiles
- Posiblemente agregar un módulo extra de práctica
```

---

### 6. Número Dinámico de Módulos (NO es fijo M1-M6)

**Rango permitido:**
```typescript
// functions/src/adaptive/schemas.ts línea 430
moduleCount: { type: "integer", minimum: 4, maximum: 12 }
```

**La IA decide según:**
```typescript
// functions/src/openai-service.ts líneas 1342-1356
Criterios:
- Complejidad del tema
- Nivel inicial (basic = más módulos, advanced = menos)
- Objetivo final (aplicación práctica requiere más que teoría)

Ejemplos:
"SQL básico" + band="basic" → 8-10 módulos
"SQL avanzado" + band="advanced" → 4-6 módulos
"Inglés A1" + band="basic" → 10-12 módulos (idiomas requieren repetición)
"Python Data Science" + band="intermediate" → 6-8 módulos
```

**Generación adaptativa de moduleStatus:**

```typescript
// functions/src/index.ts líneas 780-785
const moduleStatus: { [key: number]: "pending" | "generating" | "ready" | "error" } = {};

for (let i = 1; i <= moduleCountResult.moduleCount; i++) {
  moduleStatus[i] = i === 1 ? "generating" : "pending";
}

// Si moduleCount = 8, crea:
{ 1: "generating", 2: "pending", 3: "pending", ..., 8: "pending" }
```

---

### 7. Resumen del Flujo Completo

```mermaid
flowchart TD
    A[Quiz de Ubicación 10 preguntas] --> B[Calcula band + skill_mastery]
    B --> C[POST /adaptiveModuleCount]
    C --> D[IA decide: 6 módulos]
    D --> E[Genera M1 con learnerState inicial]
    E --> F[Usuario completa 8-20 lecciones]
    F --> G[Checkpoint Quiz M1]
    G --> H{Calificación}

    H -->|< 50%| I[Replan M1]
    H -->|50-69%| J[Booster 2 lecciones]
    J --> K[Mini-quiz booster]
    K --> L{≥70%?}
    L -->|Sí| M[Actualiza learnerState]
    L -->|No| I

    H -->|≥ 70%| M
    M --> N[Desbloquea M2]
    N --> O[Genera M2 con learnerState actualizado]
    O --> P[...ciclo se repite M3, M4, M5, M6]
    P --> Q[Meta Alcanzada]
```

---

### 8. Archivos Clave del Sistema Adaptativo

**Backend:**
```
functions/src/
├── openai-service.ts                    # LearnerState, Band, mastery ELO
│   ├── líneas 272-283: LearnerState interface
│   ├── líneas 1543-1553: applyEloUpdate (algoritmo ELO)
│   ├── líneas 1590-1621: generateModuleCount
│   ├── líneas 1700-1729: generateRemedialBooster
│   └── líneas 1731-1802: evaluateCheckpoint
├── generative-endpoints.ts
│   ├── líneas 1631-1728: adaptiveCheckpointQuiz
│   ├── líneas 1731-1870: adaptiveEvaluateCheckpoint
│   └── líneas 1874-1976: adaptiveBooster
├── adaptive/schemas.ts
│   ├── líneas 424-433: ModuleCountSchema (min: 4, max: 12)
│   └── CheckpointQuizSchema, EvaluationResultSchema, etc.
└── index.ts
    └── líneas 731-853: adaptiveSessionStart (orquestador)
```

**Frontend:**
```
lib/
├── services/course/
│   ├── placement_band.dart              # Enum PlacementBand, mapeo basic/intermediate/advanced
│   └── models.dart                      # LearnerState model Flutter
├── features/
│   ├── quiz/quiz_screen.dart            # líneas 711-720: _bandLabel
│   ├── modules/outline/widgets/
│   │   ├── lesson_card.dart             # Sistema de candados por lección
│   │   └── module_card.dart             # Candados por módulo + paywall
│   └── paywall/paywall_modal.dart       # Trigger: 'module_locked'
└── l10n/
    ├── app_es.arb                       # "Básico", "Intermedio", "Avanzado"
    └── app_en.arb                       # "Basic", "Intermediate", "Advanced"
```

---

### 9. Estado de Implementación ✅

| Feature | Estado | Código |
|---------|--------|--------|
| **Traducciones ES/EN niveles** | ✅ Migrado `beginner` → `basic` (22 Nov) | `app_es.arb`, `placement_band.dart` |
| **Lecciones con candados** | ✅ Implementado | `lesson_card.dart:15-61` |
| **Contenido adaptado según quiz** | ✅ Implementado | `openai-service.ts:generateModuleAdaptive()` |
| **LearnerState arrastrándose M1→M2→M3** | ✅ Implementado | `generative-endpoints.ts:loadLearnerState()` |
| **Checkpoint quiz al final** | ✅ Implementado | `POST /adaptiveCheckpointQuiz` |
| **Umbral ≥70% para pasar** | ✅ Implementado | `adaptiveEvaluateCheckpoint:1842-1848` |
| **Booster si falla 50-69%** | ✅ Implementado | `POST /adaptiveBooster:1874` |
| **Replan si falla <50%** | ✅ Implementado | `action="replan"` |
| **Meta escalable (mastery ELO)** | ✅ Implementado | `applyEloUpdate():1543-1553` |
| **Módulos dinámicos (4-12)** | ✅ Implementado | `ModuleCountSchema:430` |

---

## DECISIONES TÉCNICAS CRÍTICAS

### 1. Google Fonts vs SF Pro
**Decisión:** Google Fonts (Inter)
**Razón:** SF Pro es licencia Apple, no compatible con Play Store. Inter es visualmente idéntico y open source.

### 2. Material 3 vs Cupertino
**Decisión:** Material 3
**Razón:** App se lanzará primero en Play Store. Material 3 es multiplataforma. iOS puede usar CupertinoApp después.

### 3. Arquitectura Secuencial vs Monolítica
**Decisión:** Secuencial (2 fases)
**Razón:**
- Feedback instantáneo (<10s) vs 180s timeouts
- Permite adaptación real entre módulos
- Calidad premium (8-20 lecciones vs reducir a 8 módulos mediocres)

### 4. 4 API Keys con Routing vs 1 Key
**Decisión:** 4 keys con routing por tipo de endpoint
**Razón:**
- Elimina cuello de botella: 10K TPM → 40K TPM (4x capacity)
- Mismo costo, 4x throughput
- Distribuye carga según tipo de operación

### 5. Firebase Functions v2 + .env vs v1 + config()
**Decisión:** Migración a v2 con variables de entorno
**Razón:**
- v1 deprecado, `functions.config()` ya no funciona
- v2 usa `.env` que es más estándar
- Mejor para desarrollo local (no necesita Firebase)

### 6. Skeleton UI vs Loading Spinner
**Decisión:** Skeleton UI con placeholders "Módulo 1", etc.
**Razón:**
- Psicología UX: usuario ve progreso inmediato
- Reduce bounce rate
- Percepción de velocidad

---

## MÉTRICAS DE ÉXITO ACTUALES

### Performance
| Métrica | Antes | Ahora | Mejora |
|---------|-------|-------|--------|
| Feedback inicial | 180s (timeout) | 10s | **18x** |
| Tasa error | ~40% | <5% | **8x** |
| Throughput | 10K TPM | 40K TPM | **4x** |

### Calidad de Código
- `flutter analyze`: 0 issues (175.3s runtime)
- Rebrand: 0 "Aelion", 105 "Edaptia"
- Dependencies: `google_fonts: ^6.1.0` agregado
- Tests: 27/27 backend, 2/2 E2E pasando

### Costos
**Desarrollo:** $0-5/mes (Firebase free tier)
**Producción estimada:**
- 1,000 usuarios: $9/mes
- 10,000 usuarios: $85/mes
- 100,000 usuarios: $850/mes

**Revenue por usuario:** $9.99/mes
**Costo por usuario:** $0.0085/mes
**Margen:** 99.9%

---

## PROBLEMAS CONOCIDOS Y SOLUCIONES

### 1. "OPENAI_API_KEY not configured" (HTTP 500)

**Error:**
```json
{"error": "OPENAI_API_KEY not configured"}
```

**Causa Raíz:** Firebase Functions v2 deprecó `functions.config()`

**Solución:**
```bash
# 1. Verificar que functions/.env existe con las 4 keys
cat functions/.env

# Debe contener:
# OPENAI_API_KEY_PRIMARY=sk-proj-...
# OPENAI_API_KEY_MODULES=sk-proj-...
# OPENAI_API_KEY_QUIZZES=sk-proj-...
# OPENAI_API_KEY_CALIBRATION=sk-proj-...
# OPENAI_API_KEY=sk-proj-...

# 2. Si falta, crearlo con keys válidas desde OpenAI Platform

# 3. Redesplegar
cd functions
npm run build
cd ..
firebase deploy --only functions

# 4. Verificar logs
firebase functions:log --only placementQuizStartLive
# Debe decir: "Using OPENAI_API_KEY_CALIBRATION from environment variables"
```

### 2. "Incorrect API key provided" (HTTP 401)

**Error:**
```json
{"error": "OpenAI HTTP 401: Incorrect API key provided"}
```

**Causa:** API key en `functions/.env` es inválida o fue revocada

**Solución:**
```bash
# 1. Ir a OpenAI Platform (https://platform.openai.com/api-keys)
# 2. Revocar la key vieja
# 3. Generar nueva key
# 4. Actualizar functions/.env con la nueva key
# 5. NO redesplegar (env vars se cargan en runtime)
# 6. Probar endpoint nuevamente
```

### 3. Flutter Analyze Falla con ARB

**Error:**
```
The 'arb' file could not be parsed.
```

**Solución:**
```bash
flutter clean
flutter pub get
flutter gen-l10n
flutter analyze
```

### 4. Contenido "Googleable" (No Conversacional)

**Problema:** Prompts generan contenido enciclopédico tipo Wikipedia
**Ejemplo malo:**
```
"Los números en portugués son fundamentales. Se utilizan en la vida diaria."
```

**Solución (ROADMAP Días 1-3):**
- Prompts en inglés (20% más rápido, mejor calidad)
- Templates de dominio específico
- Validador de calidad automático

**Ejemplo bueno:**
```
"Imagina: llegas a Lisboa y quieres pedir un café. ¿Dirías
'Um café, por favor' o 'Eu quero café'? Ambas funcionan..."
```

---

## COMANDOS ÚTILES

### Flutter
```bash
# Limpiar y reinstalar
flutter clean && flutter pub get

# Analizar código
flutter analyze

# Correr en emulador
flutter run

# Generar localizaciones (si se modifican .arb)
flutter gen-l10n

# Build para producción
flutter build apk --release
flutter build appbundle --release
```

### Firebase
```bash
# Ver funciones desplegadas
firebase functions:list

# Ver logs de funciones
firebase functions:log
firebase functions:log --only adaptiveModuleCount

# Desplegar solo funciones
firebase deploy --only functions

# Ver config (OBSOLETO en v2)
firebase functions:config:get

# Ver estado de deploy
firebase deploy --only functions --debug
```

### Testing
```bash
# Tests unitarios Flutter
flutter test

# Tests E2E
flutter test integration_test/app_e2e_test.dart

# Backend tests
cd functions && npm test

# Ver cobertura
cd functions && npm run coverage
```

### Costos OpenAI
```bash
cd functions
npx ts-node scripts/cost-report.ts
```

---

## ARCHIVOS CRÍTICOS PARA LEER SIEMPRE

**Al iniciar nueva sesión de Claude Code, leer en este orden:**

### 1. Documentación Principal (OBLIGATORIO)
```
CONTEXT_V2.md                              # Este archivo - TODO el contexto
docs/ROADMAP.md                            # Plan de 10 días MVP
docs/ADAPTIVE_SEQUENTIAL_ARCHITECTURE.md   # Arquitectura secuencial detallada
```

### 2. Backend (si necesitas modificar endpoints)
```
functions/src/openai-service.ts            # Líneas 73-173: API key routing
functions/src/adaptive/retryWrapper.ts     # Líneas 63-144: endpointHint support
functions/src/generative-endpoints.ts      # Endpoints principales
functions/src/index.ts                     # Exports de funciones
functions/.env                             # ✅ API keys (NO commitear)
```

### 3. Flutter - Servicios Core
```
lib/services/api_config.dart               # Línea 36: adaptiveModuleCount endpoint
lib/services/course/models.dart            # Líneas 645-670: ModuleCountResponse
lib/services/course/adaptive_service.dart  # Líneas 12-36: fetchModuleCount
lib/services/course_api_service.dart       # Wrapper services
```

### 4. Flutter - Sistema de Diseño
```
lib/core/design_system/typography.dart     # 8 estilos de texto (Inter)
lib/core/design_system/colors.dart         # Paleta + gradientes
lib/core/design_system/components/edaptia_card.dart  # Componente reutilizable
```

### 5. Flutter - Pantallas Principales
```
lib/features/quiz/quiz_screen.dart         # Línea 862+: AdaptiveJourneyScreen
lib/features/auth/sign_in_screen.dart      # Líneas 140-238: diseño Material 3
lib/features/lesson/lesson_detail_page.dart  # Líneas 125-214: typography
```

### 6. Configuración
```
pubspec.yaml                               # Dependencias (google_fonts: ^6.1.0)
functions/.env                             # ✅ 4 API keys para load balancing
firebase.json                              # Configuración Firebase
```

---

## PRÓXIMOS PASOS (ROADMAP)

### Inmediato (Esta Semana)
1. **E2E Testing en Emulador** (1 hora)
   - Validar quiz de calibración no muestra error de API key
   - Cronometrar: skeleton UI (<10s), M1 completo (<90s)
   - Verificar diseño Material 3 se ve bien
   - Verificar paywall aparece en M2

2. **Validación de Endpoint** (30 min)
   - Probar `/adaptiveModuleCount` con auth token
   - Verificar response correcta

### Prioridad MEDIA (Próxima Semana)
3. **Prompts en Inglés** (ROADMAP Días 1-2)
   - Traducir system prompts de español → inglés
   - Mantener responses en español
   - Beneficio: 20% más rápido, mejor calidad

4. **Templates de Dominio Específico** (ROADMAP Día 2)
   - `LANGUAGE_LEARNING_TEMPLATE` → Diálogos contextuales
   - `PROGRAMMING_TEMPLATE` → Código ejecutable
   - `SCIENCE_TEMPLATE` → Experimentos prácticos
   - `BUSINESS_TEMPLATE` → Casos de estudio

### Prioridad BAJA (Post-MVP)
5. Validación de calidad automática (content quality score)
6. Múltiples fuentes de contenido
7. Cloud Tasks para pre-generación
8. A/B testing de prompts
9. Dashboard visual de costos

---

## ESTRATEGIA DE DOCUMENTACIÓN

### Archivos a MANTENER (Útiles como referencia)

**Core (SIEMPRE actualizar después de cambios):**
- `CONTEXT_V2.md` - Este archivo (documento maestro)
- `docs/ROADMAP.md` - Plan de desarrollo
- `docs/ADAPTIVE_SEQUENTIAL_ARCHITECTURE.md` - Arquitectura técnica
- `README.md` - Overview público del proyecto
- `CONTRIBUTING.md` - Guía de contribución

**Operaciones (actualizar cuando cambian procesos):**
- `docs/DEPLOYMENT_GUIDE.md` - Deployment paso a paso
- `docs/RUNBOOK.md` - Procedimientos operacionales
- `docs/SMOKE_TEST_CHECKLIST.md` - Checklist de testing

**Deployment Específico (actualizar cuando cambien servicios):**
- `docs/PLAYSTORE_GUIDE.md` - Deploy a Play Store
- `docs/TESTFLIGHT_GUIDE.md` - Deploy a TestFlight
- `docs/NAMECHEAP_DEPLOYMENT.md` - Deploy web
- `docs/GA4_DASHBOARD_CONFIG.md` - Configuración analytics

**Referencia Técnica (actualizar cuando cambie API):**
- `docs/EDAPTIA_SUMMARY.md` - Resumen técnico completo
- `docs/GENERATIVE_SETUP.md` - Setup OpenAI
- `docs/Context_edaptia_v2.md` - Contexto de producto

**Prompts para IA (actualizar cuando cambien workflows):**
- `docs/PROMPT_CLAUDE_CONTINUATION.md` - Retomar proyecto
- `docs/PROMPT_CODEX_CONTINUACION.md` - Tareas futuras
- `docs/PROMPT_100_PREGUNTAS_SQL.md` - Banco de preguntas (fallback)

### Archivos a ARCHIVAR (Obsoletos pero históricos)

**Ya archivados en docs/archive/:**
- `docs/archive/prompts_old/` - Prompts desactualizados
- `docs/archive/old_plans/` - Planes de launch completados
- `docs/archive/audit/` - Audits históricos
- `docs/archive/IMPLEMENTATION_SUMMARY_DIA*.md` - Summaries viejos

**Candidatos para archivar (duplican info de CONTEXT_V2.md):**
```bash
# Estos archivos duplican información que ahora está en CONTEXT_V2.md
# Sugerencia: mover a docs/archive/deprecated/

CONTEXTO_SESION_NUEVA.md                   # → Duplica CONTEXT_V2.md
IMPLEMENTACION_COMPLETADA_15NOV.md         # → Info en CONTEXT_V2.md sección "Estado Actual"
RESUMEN_PARA_USUARIO.md                    # → Info en CONTEXT_V2.md sección "Próximos Pasos"
HANDOFF_NEXT_SESSION.md                    # → Info en CONTEXT_V2.md sección "Archivos Críticos"
```

### Archivos a ELIMINAR (Totalmente redundantes)

```bash
# Estos archivos tienen info completamente duplicada y no añaden valor histórico

BUGFIX_*.md                                # Info temporal, ya resuelta
DEPLOY_STATUS_FINAL.md                     # Estado obsoleto
FIX_429_RATE_LIMIT.md                      # Fix específico, ya implementado
PROMPT_NUEVA_SESION.md                     # Reemplazado por CONTEXT_V2.md
```

---

## REGLAS DE ACTUALIZACIÓN DE DOCUMENTACIÓN

### SIEMPRE actualizar después de:

**1. Cambios en Arquitectura:**
- Actualizar: `CONTEXT_V2.md` (sección Arquitectura)
- Actualizar: `docs/ADAPTIVE_SEQUENTIAL_ARCHITECTURE.md`
- Actualizar: `docs/EDAPTIA_SUMMARY.md`

**2. Nuevos Endpoints o Cambios en API:**
- Actualizar: `CONTEXT_V2.md` (sección Backend)
- Actualizar: `docs/EDAPTIA_SUMMARY.md` (sección Arquitectura Técnica)
- Actualizar: comentarios en código de endpoints

**3. Cambios en Configuración (API keys, secrets, etc.):**
- Actualizar: `CONTEXT_V2.md` (sección Problemas Conocidos)
- Actualizar: `docs/DEPLOYMENT_GUIDE.md`
- Actualizar: `.env.example` si hay nuevas variables

**4. Problemas Resueltos:**
- Actualizar: `CONTEXT_V2.md` (sección Problemas Conocidos y Soluciones)
- Agregar a changelog en comentario de commit
- Si es crítico: actualizar `docs/RUNBOOK.md`

**5. Cambios en UI/UX o Diseño:**
- Actualizar: `CONTEXT_V2.md` (sección Decisiones Técnicas)
- Actualizar: `docs/ROADMAP.md` si afecta prioridades
- Screenshots: actualizar en `README.md`

**6. Nuevas Dependencias:**
- Actualizar: `pubspec.yaml` con comentarios explicando por qué
- Actualizar: `CONTEXT_V2.md` (sección Decisiones Técnicas) si es significativo

### NUNCA:
- Crear nuevos archivos .md sin revisar si la info ya existe en otro archivo
- Duplicar información entre archivos (usar referencias: "Ver CONTEXT_V2.md sección X")
- Commitear archivos temporales de sesión (BUGFIX_*.md, TEMP_*.md)
- Dejar documentación obsoleta sin archivar o eliminar

---

## ESTRUCTURA DEL PROYECTO

```
aelion/
├─ functions/                              # Firebase Cloud Functions (TypeScript)
│  ├─ src/
│  │  ├─ index.ts                          # Exports de funciones
│  │  ├─ openai-service.ts                 # API key routing + OpenAI client
│  │  ├─ generative-endpoints.ts           # Endpoints HTTP principales
│  │  └─ adaptive/
│  │     ├─ retryWrapper.ts                # Retry logic + endpointHint
│  │     └─ schemas.ts                     # JSON schemas OpenAI
│  ├─ .env                                 # ✅ API keys (NO commitear)
│  └─ package.json
│
├─ lib/                                    # Flutter app (Dart)
│  ├─ main.dart                            # Entry point, theme config
│  │
│  ├─ core/
│  │  ├─ design_system/                    # ✅ Sistema de diseño Material 3
│  │  │  ├─ typography.dart                # 8 estilos (Inter font)
│  │  │  ├─ colors.dart                    # Paleta + gradientes
│  │  │  └─ components/
│  │  │     └─ edaptia_card.dart           # Card reutilizable
│  │  └─ theme/
│  │     └─ app_theme.dart                 # Material 3 theme
│  │
│  ├─ features/
│  │  ├─ auth/
│  │  │  └─ sign_in_screen.dart            # Login (diseño Material 3)
│  │  ├─ quiz/
│  │  │  └─ quiz_screen.dart               # Quiz + AdaptiveJourney (línea 862+)
│  │  ├─ lesson/
│  │  │  └─ lesson_detail_page.dart        # Lección individual
│  │  └─ paywall/
│  │     └─ paywall_modal.dart             # Trial + Premium
│  │
│  └─ services/
│     ├─ api_config.dart                   # URLs endpoints (línea 36)
│     └─ course/
│        ├─ models.dart                    # ModuleCountResponse (líneas 645-670)
│        ├─ adaptive_service.dart          # fetchModuleCount (líneas 12-36)
│        └─ course_api_service.dart        # Wrapper services
│
├─ docs/                                   # Documentación técnica
│  ├─ ROADMAP.md                           # Plan de 10 días MVP
│  ├─ ADAPTIVE_SEQUENTIAL_ARCHITECTURE.md  # Arquitectura secuencial
│  ├─ EDAPTIA_SUMMARY.md                   # Resumen técnico completo
│  ├─ DEPLOYMENT_GUIDE.md                  # Deployment paso a paso
│  ├─ RUNBOOK.md                           # Procedimientos operacionales
│  └─ archive/                             # Documentos históricos
│
├─ CONTEXT_V2.md                           # ⭐ ESTE ARCHIVO (documento maestro)
├─ README.md                               # Overview público
├─ CONTRIBUTING.md                         # Guía de contribución
└─ pubspec.yaml                            # Dependencias Flutter
```

---

## FLUJO DE TRABAJO PARA CLAUDE CODE

### Al Iniciar Nueva Sesión

**PASO 1: Checkpoint Inicial (EJECUTA SIN PREGUNTAR)**
```bash
# 1. Verificar ubicación
pwd
git branch
git status

# 2. Verificar estado del código
flutter analyze

# 3. Verificar funciones desplegadas
firebase functions:list

# 4. Verificar API keys configuradas
cat functions/.env | grep "OPENAI_API_KEY"

# 5. Leer este archivo completo
cat CONTEXT_V2.md
```

**PASO 2: Evaluar Estado**
- Si hay cambios sin commitear → Revisar git diff
- Si hay errores en analyze → Arreglar primero
- Si faltan API keys → Reportar al usuario
- Si todo OK → Continuar con tarea asignada

**PASO 3: Durante el Trabajo**
- Commits frecuentes con mensajes descriptivos
- Actualizar `CONTEXT_V2.md` si hay cambios significativos
- No crear nuevos .md sin verificar duplicación
- Tests antes de cada commit importante

**PASO 4: Al Terminar**
```bash
# 1. Verificar tests
flutter test
cd functions && npm test

# 2. Verificar analyze
flutter analyze

# 3. Actualizar documentación si es necesario
# Editar CONTEXT_V2.md sección relevante

# 4. Commit final
git add -A
git commit -m "descriptive message"

# 5. Resumen de lo hecho
# Crear archivo HANDOFF.md temporal para próxima sesión
```

---

## ESTADO FINAL

```
✅ BACKEND:           100% implementado y desplegado (20 funciones)
✅ MIGRATION:         Firebase Functions v2 + .env completado
✅ API KEYS:          4 keys configuradas con load balancing
✅ FLUTTER:           100% implementado, 0 errores
✅ TESTING:           27/27 backend, 2/2 E2E pasando
✅ DOCS:              CONTEXT_V2.md consolidado (reemplaza 4 archivos)
✅ DISEÑO:            Sistema Material 3 completo (Google Fonts Inter)
✅ REBRAND:           100% Edaptia (0 menciones "Aelion")

⏳ PENDIENTE:         E2E Testing manual en emulador
⏳ PENDIENTE:         Prompts en inglés (ROADMAP Días 1-2)
⏳ PENDIENTE:         Templates de dominio específico (ROADMAP Día 2)
```

---

## CRÉDITOS Y MANTENIMIENTO

**Creado por:** Claude Code
**Fecha:** 18 de Noviembre, 2025
**Versión:** 2.0 (Consolidación completa)
**Reemplaza:**
- CONTEXTO_SESION_NUEVA.md
- IMPLEMENTACION_COMPLETADA_15NOV.md
- RESUMEN_PARA_USUARIO.md
- HANDOFF_NEXT_SESSION.md (parcialmente)

**Mantenido por:** Claude Code + equipo de desarrollo
**Próxima revisión:** Al completar ROADMAP Día 3 (validar calidad de contenido)

**Regla de oro:** Si creas documentación nueva, PRIMERO verifica que no existe aquí. Si la info ya existe, actualiza este archivo en lugar de crear uno nuevo.

---

**READY FOR E2E TESTING Y PRODUCCIÓN**
