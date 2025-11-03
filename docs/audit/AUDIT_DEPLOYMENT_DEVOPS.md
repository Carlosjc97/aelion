# AUDIT: DEPLOYMENT & DEVOPS

## 📊 SCORE: 5/10

## ✅ LO QUE ESTÁ BIEN
- `.github/workflows/ci.yml:18` aplica concurrency y cachea dependencias.
- `tool/ci.sh:1` permite ejecutar el pipeline local rápidamente.
- `firebase.json:34` configura emuladores multi-servicio para pruebas locales.

## 🔴 PROBLEMAS CRÍTICOS (Arreglar HOY)

### Deploy de Functions incompleto
- **Ubicación:** functions/package.json:15
- **Impacto:** `npm run deploy` publica solo `outline`, dejando `placementQuiz*`, `trackSearch`, `trending` fuera.
- **Detalle:** actualizar script y/o usar `firebase deploy --only functions`.

### Servidor IRT sin estrategia de despliegue
- **Ubicación:** server/package.json:1
- **Impacto:** no hay infra ni pipelines; difícil escalar/monitorear el core adaptativo.
- **Detalle:** definir entorno (Cloud Run/App Engine), build, variables y health checks.

### CI ignora carpeta server
- **Ubicación:** .github/workflows/ci.yml:24
- **Impacto:** cambios en `server/` no se lint/testean automáticamente.
- **Detalle:** añadir job Node (lint/test) o migrar lógica a Functions para una sola superficie.
