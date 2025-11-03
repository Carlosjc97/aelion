# TODO Backlog - Estado pendiente

## Arquitectura Flutter
- [x] Refactorizar `HomeView` (controlador + widgets, recomendaciones delegadas en `HomeController`).
- [x] Dividir `course_api_service.dart` en Outline/Quiz/Trending/Search Services con modelos tipados (`OutlinePlan`, `PlacementQuizStart`, etc.).

## Firebase & Performance
- [x] Outline pipeline real (Firestore/Storage + fallback curado/LLM).
- [x] Índice compuesto `trending(lang ASC, ts DESC)`.
- [x] Rate limiting diferenciado anon/auth usando fingerprint.
- [x] Limitar/comprimir cache en `local_outline_storage` (gzip + sanitizado + retención 14 días) y evaluar mover histórico a Storage.
- [ ] Métricas de coste/latencia (colección `analytics_costs` ya creada; pendientes dashboards y alertas presupuestarias).

## Contenido / Pedagogía
- [ ] Banco de 100 preguntas SQL con parámetros (a,b,c) por ítem.
- [ ] Documentos maestros (`PROMPT_GENERATOR.md`, `MODULE_STRUCTURE.md`, `MOCK_EXAM.json`, `PDF_CHEATSHEET.md`, `MASTER_EXECUTION_PLAN.md`).

## Monetización / UX
- [ ] Gating premium en Flutter (paywall modal, bandera `premium=false`).
- [ ] Integración Play Billing + checklist.

## QA / DevOps
- [ ] Montar suite de Functions + workflow CI (`npm --prefix functions run build/test`).
- [ ] Reactivar integration tests y cobertura e2e.
- [ ] Documentar runbook + README con capturas / flujo completo.

## Observabilidad
- [ ] Instrumentar métricas PostHog/Sentry definitivas (funnel, performance outline).
- [ ] Alertas Cloud Monitoring para 5xx/HMAC/latencia outline.
