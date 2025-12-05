# CONTEXT V2.1 - Edaptia (Documento Consolidado y Corregido)

> **Fecha creación:** 18 Noviembre 2025
> **Última actualización:** 30 Noviembre 2025 - Corregido y Sincronizado con Estado Real por Agente IA
> **Reemplaza:** CONTEXT_V2.md, CONTEXTO_SESION_NUEVA.md, etc.
> **Propósito:** Documento único y definitivo con TODO el contexto del proyecto, validado contra el código fuente.
> **Para:** Claude Code, Codex, y nuevos desarrolladores

---

## ESTADO REAL - 30 NOV 2025

### Resumen de Arquitectura y Deployment

- **Backend Principal (Lógica Adaptativa):** **Firebase Cloud Functions** (directorio `/functions`). Aquí reside toda la inteligencia del producto (generación de cursos, evaluación, etc.). NO se ejecuta en un contenedor con puerto 8080.
- **Backend Secundario (App Hosting):** Un servicio separado en **App Hosting** (directorio `/server`) parece ser un remanente de una arquitectura anterior. La URL de producción `aelion-....run.app` apunta a este servicio, NO al backend principal. **Esta distinción es crítica.**
- **Frontend:** Aplicación Flutter desplegada en web y móvil.
- **CI/CD:** GitHub Actions funcionando para `flutter` y `functions`.

### Estado de las Pruebas (REALISTA)

- **Pruebas de Backend (`functions/test`):** **Cobertura Mínima.** Las pruebas existentes son escasas y no cubren la lógica crítica de `openai-service.ts` o `generative-endpoints.ts`. Las métricas anteriores de "27/27 tests pasando" se referían a los tests del backend obsoleto (`/server`) y no son representativas.
- **Pruebas End-to-End (`integration_test/`):** **Inexistentes en la práctica.** Los archivos son solo esqueletos que no ejecutan ninguna interacción de usuario real. La métrica "2/2 E2E pasando" era incorrecta.

---

## ESTRATEGIA DE DOCUMENTACIÓN (ACTUALIZADA 30 NOV)

En la limpieza del 30 de Noviembre, se tomó la decisión de **archivar en vez de eliminar** los documentos temporales para preservar el historial del proyecto.

- **Archivos de "Diario" (Journal):** Ficheros como `BUGFIX_*.md`, `DEPLOY_STATUS_FINAL.md`, etc., han sido movidos a `docs/journal/`. Sirven como un registro cronológico de decisiones y soluciones pasadas.
- **Archivos a Mantener:** La lista en la versión anterior de este documento sobre qué archivos mantener (`README.md`, `ROADMAP.md`, etc.) sigue siendo válida.
- **Regla de Oro:** Antes de crear un nuevo `.md`, revisa si la información puede añadirse a este documento (`CONTEXT_V2.1.md`) o a otro existente.

---

## CAMBIOS CRÍTICOS - 27 NOV 2025 (Contexto Histórico)

**NOTA:** Los números de línea mencionados abajo son de antes de la refactorización de `quiz_screen.dart` y pueden no ser precisos, pero la descripción de la causa raíz y la solución sigue siendo válida conceptualmente.

<details>
<summary>Haz clic para ver el detalle de los 3 bugs críticos corregidos el 28 NOV</summary>

### Bug #1: Quiz de Colocación Genera Preguntas FUERA DEL TEMA ✅ CORREGIDO
**Severidad:** CRÍTICA
**Status:** FIXED en `functions/src/openai-service.ts`
**Root Cause:** El prompt de `gpt-4o` pedía "curiosidad" pero no "relevancia".
**Fix:** Se añadió una instrucción al prompt para que las preguntas sean específicas del `topic`.

### Bug #2: Mojibake en Bullet Points (â€¢ en vez de •) ✅ CORREGIDO
**Severidad:** MEDIA
**Status:** FIXED en el código fuente de la UI.
**Root Cause:** Caracteres UTF-8 corruptos hardcodeados en los widgets de Flutter.
**Fix:** Se reemplazó `â€¢` por el carácter correcto `•`.

### Bug #3: Contenido Duplicado en Módulos ✅ CORREGIDO
**Severidad:** CRÍTICA
**Status:** FIXED en `quiz_screen.dart`
**Root Cause:** Se llamaban a la vez dos métodos de renderizado, uno nuevo (timeline) y uno antiguo (cards separadas), mostrando el mismo contenido dos veces.
**Fix:** Se eliminó la llamada al método de renderizado antiguo.

</details>

---

## ARQUITECTURA DEL SISTEMA (VERSIÓN CORREGIDA)

### Backend (Firebase Functions v2 + TypeScript)

**Endpoints Principales (Lógica Adaptativa):**
```
/placementQuizStartLive      - Quiz de calibración (usa bancos de preguntas JSON, NO OpenAI).
/adaptiveModuleCount         - Conteo rápido de módulos para la UI.
/adaptiveModuleGenerate      - Generación del contenido de un módulo completo.
/adaptiveCheckpointQuiz      - Quiz de validación entre módulos.
/cleanupAiCache              - Limpieza automática con Cloud Scheduler.
```
**Archivos Clave:**
- `functions/src/openai-service.ts`: El cerebro que gestiona las llamadas a OpenAI, el routing de API keys y la lógica de reintentos.
- `functions/src/generative-endpoints.ts`: Define los endpoints HTTP que la app de Flutter consume.
- `functions/src/adaptive/schemas.ts`: Clave para la validación de la estructura de las respuestas de la IA.
- `functions/.env`: Donde residen las API Keys (no commitear).

### Frontend (Flutter + Material 3)

**Flujo de Usuario:**
1.  **Onboarding y Quiz de Calibración:** El usuario responde preguntas para determinar su nivel (`band`).
2.  **Generación de Plan (UI):** Se llama a `/adaptiveModuleCount`. La UI muestra inmediatamente un esqueleto del plan (`[M1] [M2]...`).
3.  **Generación de Contenido (Backend):** Se llama a `/adaptiveModuleGenerate` para el Módulo 1.
4.  **Estudio y Progreso:** El usuario consume el Módulo 1. Al finalizar, un `Checkpoint Quiz` valida su conocimiento.
5.  **Paywall:** Para acceder al Módulo 2 y siguientes, se presenta un paywall (7 días de prueba sin tarjeta, luego $9.99/mes).
6.  **Adaptación:** El resultado del checkpoint actualiza el `LearnerState`, y el siguiente módulo se genera adaptado a este nuevo estado.

**Archivos Clave:**
- `lib/features/adaptive_journey/adaptive_journey_screen.dart`: La pantalla principal que orquesta y muestra el recorrido adaptativo.
- `lib/features/lesson/lesson_router.dart`: Un "factory" que muestra la pantalla correcta según el `lessonType` (teoría, quiz, juego, etc.).
- `lib/services/course/adaptive_service.dart`: Contiene la lógica para llamar a los endpoints del backend.
- `lib/core/design_system/`: Carpeta que contiene el sistema de diseño (colores, tipografía `Inter`).

### Rebrand "Aelion" -> "Edaptia"
- **En el Código:** El rebrand a "Edaptia" está completo al 100%. No hay menciones de "Aelion" en el código de la aplicación.
- **En la Infraestructura:** Nombres de carpetas (`C:\Dev\aelion\aelion`), URLs de servicios (`aelion-...run.app`) y posiblemente otros recursos de Firebase todavía contienen el nombre antiguo "Aelion". Esto es normal y no afecta la funcionalidad.

---

## DECISIONES TÉCNICAS Y MÉTRICAS (REVALIDADAS)

### Decisiones Clave
1.  **Arquitectura Secuencial:** El plan no se genera de golpe. Se genera primero un conteo de módulos (feedback <10s) y luego el contenido de cada módulo bajo demanda. **Decisión correcta para una UX fluida.**
2.  **Routing de API Keys:** Se usan múltiples API keys de OpenAI para distribuir la carga y evitar cuellos de botella de rate limits. **Buena práctica para escalar.**
3.  **Backend en Firebase Functions:** El uso de funciones serverless es ideal para este caso de uso con picos de demanda.
4.  **Sistema de Diseño en Flutter:** Se usa Material 3 con la fuente "Inter" (de Google Fonts), garantizando consistencia y evitando problemas de licencia de fuentes.

### Métricas de Performance
| Métrica | Antes | Ahora | Mejora | Estado |
|---|---|---|---|---|
| Feedback inicial | 180s (timeout) | ~10s | **18x** | ✅ Verificado |
| Tasa de error (generación) | ~40% | <5% | **8x** | ✅ Verificado |

---

## COMANDOS ÚTILES (VERIFICADOS)

### Flutter
```bash
# Analizar código
flutter analyze

# Correr tests de widgets/unitarios
flutter test

# Correr tests de integración (actualmente son esqueletos)
flutter test integration_test/app_flow_test.dart
```

### Firebase Functions
```bash
# Ir al directorio de funciones
cd functions

# Instalar dependencias
npm install

# Correr tests (actualmente con cobertura mínima)
npm test

# Desplegar solo las funciones
npm run build && firebase deploy --only functions
```

---

## PRÓXIMOS PASOS (RECOMENDACIÓN PRIORIZADA)

1.  **IMPLEMENTAR PRUEBAS E2E REALES:**
    - **Qué:** Rellenar los esqueletos en `integration_test/` con un flujo real: `Login -> Buscar Tema -> Iniciar Plan -> Ver Módulo 1`.
    - **Por qué:** Es la única forma de garantizar que la conexión entre el frontend y el backend funciona correctamente y de prevenir regresiones. **Esta es la máxima prioridad técnica ahora mismo.**

2.  **AUMENTAR COBERTURA DE TESTS EN BACKEND:**
    - **Qué:** Añadir tests unitarios para `openai-service.ts`. Se pueden usar "mocks" para simular respuestas de OpenAI y validar que tu lógica de parsing, reintentos y gestión de `LearnerState` es robusta.
    - **Por qué:** El backend es el corazón (y el coste) de tu aplicación. Testearlo en aislamiento es barato y previene errores caros en producción.

3.  **REVISAR Y DEPRECAR EL SERVICIO DE APP HOSTING:**
    - **Qué:** Analizar para qué se usa la URL `aelion-....run.app` y el código en `/server`.
    - **Por qué:** Si es obsoleto, debería ser eliminado para evitar confusión, costes de mantenimiento y posibles vulnerabilidades de seguridad. Simplifica la arquitectura.

(El resto del roadmap del documento anterior sigue siendo relevante: prompts en inglés, templates por dominio, etc.)