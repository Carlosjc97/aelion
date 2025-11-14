agent:
  name: Arquitecto Flutter/Frontend
  mission: Desmonolitizar vistas y servicios hiperacoplados

tasks:
  - dividir_module_outline_view:
      archivo: module_outline_view.dart
      líneas: 2140
      componentes:
        - ModuleOutlineController
        - ModuleCard
        - LessonCard
        - ProgressIndicator
  - dividir_home_view:
      archivo: home_view.dart
      líneas: 1266
      acción: externalizar_lógica_a_servicios
  - partir_course_api_service:
      archivo: course_api_service.dart
      líneas: 817
      servicios:
        - OutlineService
        - QuizService
        - TrendingService
        - SearchService
      modelos: tipados
  - arreglar_normalización_i18n:
      detalles: acentos_y_diacríticos
  - quitar_fallback_default