# AUDIT SUMMARY — EDAPTIA MVP (BRUTAL REVIEW)

## 🧭 Overview General
- Los mínimos de seguridad ya están cubiertos (secrets fuera del repo, CORS estricto en Functions y servidor, HMAC obligatorio), pero el producto sigue sin contenido real ni monetización.
- `/outline` continúa devolviendo un mock; sin contenido curado no hay propuesta de valor.
- El motor IRT ahora persiste sesiones y usa gradiente 3PL, pero aún depende de un banco sintético sin calibración real.
- Stripe sigue sin implementarse; el paywall sólo muestra un banner.
- Cache local de outlines ahora comprime (gzip) y depura entradas >14 días, reduciendo riesgo de SharedPreferences.
- HomeView se seccionó en `HomeController`, widgets de recomendaciones y tarjetas de recientes; menos de 700 líneas.
- CourseApiService quedó como fachada sobre servicios tipados (Outline/Quiz/Trending/Search).
- `analytics_costs` almacena latencia y consumo estimado de `/outline` y `/trending` (pendiente armar dashboards/alertas).
- Se añadieron pruebas del servidor, pero Functions y los E2E continúan sin cobertura ni ejecución en CI.

## 📊 Score por Área
```
Arquitectura & Código: ████░░░░░░ 4/10
Algoritmo IRT        : █████░░░░░ 5/10
Firebase Integración : █████░░░░░ 5/10
Seguridad            : ███████░░░ 7/10
Stripe & Monetización: █░░░░░░░░░ 1/10
UX/UI & Flows        : ████░░░░░░ 4/10
Performance          : ████░░░░░░ 4/10
Testing & QA         : ██████░░░░ 6/10
Documentación        : ████░░░░░░ 4/10
Deployment & DevOps  : █████░░░░░ 5/10
```

## 🚨 Top 10 Problemas Más Críticos
1. **`/outline` sigue entregando contenido demo** — `functions/src/index.ts:784`
2. **Stripe/monetización inexistente** — `pubspec.yaml` / `functions/package.json`
3. **[fixed] ModuleOutlineView modularizada** - lib/features/modules/outline/module_outline_view.dart:1
4. **Banco de ítems IRT sintético** — `server/assessment.js:830`
5. **Parámetros IRT estáticos por dificultad** — `server/assessment.js:31`
6. **Rate limiting colisiona usuarios anónimos** — `functions/src/index.ts:484`
7. **Documentos maestros ausentes** — `docs/`
8. **Gestión de secretos sin proceso formal** — pipeline de despliegue
9. **Functions sin suite de tests** — `functions/src/index.test.ts`
10. **E2E Flutter desactivado** — `integration_test/app_flow_test.dart:18`

## ⚡ Quick Wins (alto impacto / bajo esfuerzo)
1. Documentar y automatizar la carga/rotación de secretos (Secret Manager + CI).
2. Montar pruebas de `/outline` y `/placementQuiz*` usando el emulador de Firestore.
3. Rehabilitar el test E2E apuntando a un entorno de staging controlado.
4. Instrumentar alertas (Cloud Monitoring) para 5xx/HMAC fallidos.

## 🛣️ Roadmap Priorizado de Fixes
### Fase 0 — Hoy
- [DONE] Sustituir `generateDemoOutline` por pipeline curado + LLM (Firestore/Storage + plantillas).
- Definir y versionar el banco SQL de 100 preguntas con parámetros (a, b, c) por ítem.
- Clonar la política de CORS en el servidor Express o aislarlo detrás de un gateway.
- Publicar los 5 documentos maestros en `docs/`.

### Fase 1 — Próxima semana
- Integrar Stripe (checkout + webhooks) y bloquear lecciones premium.
- Refactorizar `ModuleOutlineView` y `HomeView` en componentes mantenibles.
- Montar suite de Functions y ampliar el workflow con `npm --prefix server test`.

### Fase 2 — 3-4 semanas
- Pipeline de recalibración IRT (EAP/MLE, simulaciones, métricas de fiabilidad).
- Agregaciones `trending` programadas y optimización de caching.
- Beta con 50 usuarios y observabilidad PostHog/Sentry cerrando feedback diario.

## ✅ Checklist de Acción
- [x] `/outline` sirviendo contenido real (curado + LLM).
- [ ] Banco IRT (100 preguntas) con parámetros (a, b, c) cargado.
- [ ] Stripe y paywall bloqueando premium correctamente.
- [ ] Tests automatizados para Functions y servidor integrados en CI.
- [ ] Documentos maestros publicados en `docs/`.
- [ ] CORS restrictivo tanto en Functions como en el servidor Express.

## 🚧 Pendientes inmediatos
- Automate la rotación/carga de secretos: integrar Secret Manager/Firebase Config y añadir validaciones en CI antes de desplegar.
- Sustituir `generateDemoOutline` por contenido curado + LLM híbrido (datos reales, cache y validación de calidad).
- Añadir suite de pruebas para Cloud Functions (emulador Firestore + Supertest) y reactivar los E2E de Flutter en CI.

## 📚 Recursos
- Firebase Functions Testing: https://firebase.google.com/docs/functions/unit-testing
- Stripe Flutter SDK: https://pub.dev/packages/flutter_stripe
- Cloud Run deployment: https://cloud.google.com/run/docs/deploying
- IRT (3PL) essentials: https://www.frontiersin.org/articles/10.3389/feduc.2019.00075
- SharedPreferences límites: https://docs.flutter.dev/cookbook/persistence/key-value
- Node Test Runner: https://nodejs.org/api/test.html
- Secret Manager (Firebase Functions): https://firebase.google.com/docs/functions/config-env

## 🧭 Próximos Pasos Sugeridos
1. Conectar contenido curado + outlines reales y cerrar el dataset SQL (preguntas/lecciones).
2. Implementar Stripe end-to-end y bloquear premium antes de la beta.
3. Publicar documentos maestros y definir playbook de secretos.
4. Expandir pruebas (Functions + E2E) y activar los pasos en CI.
5. Diseñar la beta cerrada con telemetría y plan de iteraciones semanales.
