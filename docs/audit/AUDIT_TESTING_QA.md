# AUDIT: TESTING & QA

## 📊 SCORE: 6/10

## ✅ LO QUE ESTÁ BIEN
- `test/a11y_semantics_test.dart:14` mantiene cobertura de accesibilidad en el flujo de login.
- `server/assessment.test.js` añade pruebas para persistencia y updates 3PL del motor adaptativo.
- `.github/workflows/ci.yml:18` sigue ejecutando `flutter analyze` y `flutter test` en cada push.

## 🔴 PROBLEMAS CRÍTICOS (Arreglar HOY)

### [partial] Functions sin cobertura real
- **Ubicación:** functions/test/outline.test.mjs
- **STATUS:** partial - pruebas unitarias básicas para helper y métricas; siguen pendientes los flujos end-to-end con emulador/Supertest.

### E2E Flutter sigue deshabilitado
- **Ubicación:** integration_test/app_flow_test.dart:18
- **Impacto:** el test está marcado con `skip`, no valida onboarding completo.
- **Detalle:** configurar entorno staging (API Base) y habilitarlo en CI antes de beta.

### CI no ejecuta tests del servidor
- **Ubicación:** .github/workflows/ci.yml
- **Impacto:** `npm test` dentro de `server/` no corre en CI; las nuevas pruebas pueden fallar sin detectarse.
- **Detalle:** añadir job Node para `server` o ampliar el pipeline existente con paso `npm --prefix server test`.
