# AUDIT: ARQUITECTURA & CÓDIGO CRÍTICO

## 📊 SCORE: 4/10

## ✅ LO QUE ESTÁ BIEN
- `lib/main.dart:21` inicializa Firebase, Crashlytics, Remote Config y analytics antes de montar la app.
- `lib/core/router.dart:17` centraliza la navegación y fuerza `AuthGate`, manteniendo rutas limpias.
- `lib/services/local_outline_storage.dart:83` define un caché local con claves deduplicadas y migración legacy.

## 🔴 PROBLEMAS CRÍTICOS (Arreglar HOY)

### Vista de módulos monolítica
- **Ubicación:** lib/features/modules/outline/module_outline_view.dart:1
- **Impacto:** difícil de mantener; introduce bugs y re-renderizados costosos.
- **Detalle:** 2 140 líneas mezclando UI, networking, analytics y estado. Urgente dividir en controller + widgets especializados.

- **STATUS:** fixed - ModuleOutlineView ahora se apoya en ModuleOutlineController + module_outline_controller_actions.dart y widgets dedicados (ModuleCard, LessonCard, ModuleProgressIndicator, OutlineHeader, OutlineContent). Cada archivo <500 lineas.

### HomeView sobredimensionado
- **Ubicación:** lib/features/home/home_view.dart:1
- **Impacto:** bloquea mejoras en recomendaciones, almacenamiento y estados de carga.
- **Detalle:** 1 266 líneas que combinan lógica de negocio y UI. Separar servicios y componentes.
- **STATUS:** fixed - `HomeController` extrae la lógica (loadRecents/loadRecommendations/analytics) y la vista se divide en widgets (_RecommendationsSection, _RecentOutlineCard); home_view.dart quedó <700 líneas.

### Servicio CourseApiService hiperacoplado
- **Ubicación:** lib/services/course_api_service.dart:16
- **Impacto:** baja testabilidad y alto riesgo de regresiones en outline/quiz/trending.
- **Detalle:** clase estática de 817 líneas con múltiples dominios y respuestas como `Map<String, dynamic>`. Refactorizar en servicios por responsabilidad.
- **STATUS:** fixed - se crearon `outline_service.dart`, `quiz_service.dart`, `trending_service.dart`, `search_service.dart` y modelos tipados (`OutlinePlan`, `PlacementQuizStart`, etc.); `CourseApiService` quedó como fachada delgada.
