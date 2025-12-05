# Refactorización: AdaptiveJourneyScreen

## Cambios Realizados

### Archivos Creados
- `lib/features/adaptive_journey/adaptive_journey_screen.dart` (863 líneas)
- `lib/features/adaptive_journey/widgets/module_tile.dart` (176 líneas)
- `lib/features/adaptive_journey/widgets/lesson_card.dart` (105 líneas)
- `lib/features/adaptive_journey/models/module_tile_state.dart` (16 líneas)

### Archivos Modificados
- `lib/features/quiz/quiz_screen.dart` (2,021 → 776 líneas, -62%)
- `lib/core/router.dart` (nuevo import y ruta protegida)
- `lib/features/home/home_view.dart` (import actualizado para AdaptiveJourney)

### Verificaciones
- `flutter analyze`: 0 issues
- `flutter build apk --debug`: éxito
- Imports actualizados y sin referencias rotas detectadas
- Estructura de archivos validada manualmente

## Próximos Pasos Recomendados
1. Migrar el estado de AdaptiveJourney a un gestor (p. ej. Riverpod) para aislar lógica.
2. Descomponer widgets grandes (LearnerState, Checkpoint, Booster) en componentes reutilizables.
3. Agregar pruebas unitarias/widget para el flujo adaptativo y la navegación recién expuesta por router.
