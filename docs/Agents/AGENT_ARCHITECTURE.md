Rol: Arquitecto Flutter/Frontend.
Misión: Desmonolitizar vistas y servicios hiperacoplados.

Tareas:

Dividir module_outline_view.dart (2,140 líneas) en: ModuleOutlineController, ModuleCard, LessonCard, ProgressIndicator.

- [x] Dividir home_view.dart (1,266 líneas) y externalizar lógica a servicios (HomeController + widgets desacoplados).

- [x] Partir course_api_service.dart (817 líneas) en OutlineService, QuizService, TrendingService y SearchService con modelos tipados (`OutlinePlan`, `PlacementQuizStart`, etc.).

Arreglar normalización i18n (acentos/diacríticos).

Quitar fallback “Default Topic” → CTA guiada.

“Premium sin bloqueo”: bloquear acciones y mostrar paywall claro (aunque no cobremos).

Salidas:

lib/features/modules/... refactor, cada archivo <500 líneas.

lib/services/*Service.dart con modelos fuertes.
