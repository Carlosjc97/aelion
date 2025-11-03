## Cambios propuestos

- `lib/l10n/app_es.arb`: Se agregaron las traducciones pendientes del quiz y outline para eliminar advertencias de l10n y alinear la UI en español.
- `lib/services/course_api_service.dart` (sin cambios funcionales directos, cubierto por pruebas): Las nuevas pruebas aseguran los rangos de bandas y la correspondencia banda-profundidad.
- `lib/services/recent_outlines_storage.dart`: Cubierto por pruebas unitarias para validar deduplicacion y limite de historial.
- `test/services/placement_band_test.dart`: Nueva bateria que cubre bandas 0-49/50-79/80-100 y mapping profundidad.
- `test/services/recent_outlines_storage_test.dart`: Verifica `upsert` con promocion y recorte a maximo de 5 historiales.
- `test/features/quiz/quiz_flow_test.dart`: Escenario end-to-end con mocks que recorre inicio -> preguntas -> resultado y confirma la navegacion a ModuleOutlineView cuando se solicita regeneracion.
- `test/features/quiz/quiz_navigation_test.dart`: Garantiza que los `Key` (`quiz-start`, `quiz-next`, `quiz-submit`, `quiz-result-done`) existen y funcionan durante el flujo de preguntas.
- `README.md`: Nueva seccion "Quiz de colocacion" con comandos de prueba en PowerShell, notas de CORS y politica de costos/regeneracion.

## Motivacion

- Reducir la deuda de pruebas solicitada en la seccion C: validar bandas de puntuacion, historial de outlines y flujos de quiz.
- Eliminar los 13 warnings de localizacion asegurando paridad en español.
- Documentar claramente el quiz de colocacion, comandos de QA y la politica de costos para el equipo de pruebas y operaciones.

## Como probar

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
```

```powershell
cd functions
npm ci
npm run build
cd ..
firebase deploy --only functions
```

```powershell
$URL_START = "https://us-east4-aelion-c90d2.cloudfunctions.net/placementQuizStart"
$startBody = @{ topic = "Historia de Roma"; lang = "es" } | ConvertTo-Json -Compress
$start = Invoke-RestMethod -Method POST -Uri $URL_START -ContentType "application/json" -Body $startBody
$start | ConvertTo-Json -Depth 10

$URL_GRADE = "https://us-east4-aelion-c90d2.cloudfunctions.net/placementQuizGrade"
$answers = $start.questions | ForEach-Object { @{ id = $_.id; choiceIndex = 0 } }
$gradeBody = @{ quizId = $start.quizId; answers = $answers } | ConvertTo-Json -Compress
Invoke-RestMethod -Method POST -Uri $URL_GRADE -ContentType "application/json" -Body $gradeBody
```
- Instrumentación analytics_costs: `functions/src/index.ts` registra latencia/counters e índices; añadido `npm run test` + pruebas node.
- Refactor Home/Course services: `lib/features/home/home_controller.dart`, `lib/features/home/home_view.dart`, `lib/services/course/**/*.dart`.

