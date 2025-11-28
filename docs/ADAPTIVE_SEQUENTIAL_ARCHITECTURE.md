# Arquitectura Secuencial 2.0 – Edaptia
Versión 20 de noviembre de 2025  
Responsable: Equipo Ara / Claude Code / Tú

---

## 1. Por qué existe

Antes se intentaba generar TODO el curso en una sola llamada a OpenAI: 4‑12 módulos + checkpoints + mock. Resultado: 3 minutos de espera, timeouts en Cloud Functions y usuarios frustrados.  
La nueva arquitectura divide el viaje en micro-tareas que se resuelven en paralelo, se cachean y se entregan al usuario en el momento exacto. Así se obtiene feedback en <10 s y el contenido pesado se cocina de fondo.

---

## 2. Cómo se siente para el usuario

1. **Generar plan con IA** → inmediatamente aparece un skeleton con los slots de M1..Mx (5‑10 s).  
2. **Módulo 1 se abre** → la IA ya lo estaba generando; ves lecciones reales en ≈60 s.  
3. **Mientras estudias**, el backend prepara M2. Cuando lo desbloqueas, ya está caliente.  
4. **Cada checkpoint** recalibra el plan y alimenta los siguientes módulos.  
5. **Todo el tiempo** recibes mensajes claros si algo falla (sin códigos raros).

---

## 3. Flujo resumido

```mermaid
flowchart LR
    A[Quiz de colocación] --> B{placementQuizGrade}
    B -->|band + learnerState| C[/adaptiveSession/start/]
    C --> D[adaptiveModuleCount]
    C --> E[adaptiveModuleGenerate (M1)]
    E --> F{Usuario abre Módulo 1}
    F --> G[Prefetch M2]
    G --> H[Prefetch M3]
    F --> I[Checkpoint M1]
    I -->|new learnerState| G
```

- El front solo ve `/adaptiveSession/...`. Por dentro, Cloud Functions llama a los endpoints clásicos (`adaptiveModuleCount`, `adaptiveModuleGenerate`, etc.) y persiste todo en Firestore.

---

## 4. Componentes clave

| Componente | Rol | Persistencia |
|------------|-----|--------------|
| `placementQuizStartLive` | Genera el quiz + guarda `quiz_session` | Firestore `quiz_sessions` |
| `placementQuizGrade` | Devuelve banda, score y `competencyMap` | Firestore `adaptive_sessions/{userId}` |
| `adaptiveSession/start` (wrapper nuevo) | Orquesta módulo count + prefetch de M1 | Firestore `adaptive_sessions` |
| `adaptiveModuleCount` | Devuelve `moduleCount` + `rationale` en 5‑10 s | Guardado en la sesión |
| `adaptiveModuleGenerate` | Genera un módulo completo (8‑20 lecciones) | Cachea JSON en Storage + metadatos en Firestore |
| `adaptiveCheckpointQuiz` | Crea mini-quiz por módulo | Misma sesión |
| `adaptiveEvaluateCheckpoint` | Ajusta `learnerState` y desencadena el siguiente módulo | Firestore |
| Heath Scheduler (Cloud Function programada) | Prefetch + limpia sesiones viejas | Firestore / Storage |

> Nota: Los endpoints históricos siguen existiendo, pero el cliente solo habla con `adaptiveSession/*`. Esto evita que un cambio en el front deje módulos a medio generar.

---

## 5. Estados y datos que se arrastran

| Campo | Fuente | Uso |
|-------|--------|-----|
| `band` | `placementQuizGrade` | Decide nivel inicial y temperatura de prompts |
| `learnerState` (skills 0‑1) | Quiz + checkpoints | Alimenta prompts de módulos, boosters y checkpoints |
| `moduleCount` | `adaptiveModuleCount` | Skeleton UI + progress bar |
| `moduleStatus[n]` | Prefetch service | Informa si M1..Mx están en `pending/generating/ready` |
| `focusSkills` | Checkpoint + heurísticas | Inyectado en prompt de cada módulo |
| `locale/preferredLanguage` | Quiz + settings | Informa prompts y UI |

Cada vez que generamos algo, actualizamos este documento en Firestore. Cualquier función puede reconstruir el contexto leyendo un único registro.

---

## 6. Estrategia “Disruptiva” (lo que entusiasma)

1. **Doble disparo al terminar el quiz**  
   - `adaptiveModuleCount` → respuesta ligera para dibujar el plan.  
   - `adaptiveModuleGenerate` para M1 → inicia de inmediato.  
   Esto ocurre en paralelo, sin esperar al usuario.

2. **Prefetch en cadena**  
   - Cuando M1 termina, Cloud Functions (Heath) lanza M2 en background.  
   - Si el usuario llega antes de que termine, se muestra el loader; si llega después, lo abre al instante.  
   - Cada checkpoint desencadena un “prefetch + recalibración” del siguiente.

3. **Cache inteligente**  
   - Respuestas de generación se guardan en Storage con un hash del prompt.  
   - Si otro usuario pide “SQL para marketing – banda basic”, reutilizamos resultados siempre que la ventana de frescura (24 h) no haya expirado.

4. **Prompts con narrativa viva**  
   - Todos los prompts describen escenarios globales, invites reales (LATAM, startups, etc.).  
   - Se enviarán en inglés para reducir coste y ganar consistencia; la traducción al usuario la hace el front (o el prompt incluye `language = es`).  
   - El doc de prompts vive en `functions/src/openai-service.ts` y se mantiene versionado.

5. **Mensajes humanos**  
   - “Estamos armando tu módulo con ejemplos de Growth en CDMX. Tardará ~1 minuto.”  
   - “Detectamos que te costó `joins`. El siguiente módulo refuerza ese tema.”  
   Nada de errores JSON o `OPENAI_API_KEY not configured` en la UI.

---

## 7. Errores y cómo reintentamos

| Falla | Acción automática | Mensaje al usuario |
|-------|------------------|--------------------|
| Timeout generando módulo | Reintenta hasta 3 veces con backoff | “Estamos tardando más de lo normal, seguimos trabajando en tu módulo.” |
| 401 OpenAI | Cambia de key según hint → si persiste, alerta ops | “Necesitamos regenerar el contenido. Vuelve en 2 minutos.” |
| Cloud Firestore unavailable | Reintenta silenciosamente | “Sincronizando tu progreso...” |
| Skeleton sin contenido >90 s | Marca módulo como `error` y ofrece reintentar | “No pudimos generar M2, ¿reintentamos?” |

Todos los eventos críticos se loguean en `openai_usage` con `endpoint`, `tokens`, `key_type`. Puedes monitorear en BigQuery.

---

## 8. Checklist para cualquier desarrollador nuevo

1. Leer `docs/Context_edaptia.md` → visión general.  
2. Revisar este archivo para entender cómo fluye el contenido.  
3. Explorar `functions/src/openai-service.ts` (prompts y lógica).  
4. Ver `lib/features/quiz/quiz_screen.dart` → `_bootstrap` maneja skeleton + módulos.  
5. Lanzar `firebase functions:log --only placementQuizStartLive` para confirmar que las keys están vivas.  
6. Ejecutar `flutter run`, completar un quiz y verificar tiempos (<10 s skeleton, <90 s módulo).  
7. Si algo se rompe, actualizar el estado en `docs/RESUMEN_PARA_USUARIO.md`.

---

## 9. Roadmap de Implementación (3 Fases)

### **Fase 1: MVP Secuencial (Semana 1 - P0 Critical)**
**Objetivo**: Skeleton en <10s, M1 en <90s. Usuario ve progreso inmediato.

**Tareas**:
1. ✅ **Endpoints base ya existen**:
   - `adaptiveModuleCount` (retorna en 5-10s)
   - `adaptiveModuleGenerate` (genera módulo completo)
   - `placementQuizGrade` (calcula band + learnerState)

2. 🔨 **Crear wrapper `/adaptiveSession/start`** (`functions/src/index.ts`):
   ```typescript
   // Orquesta:
   // - Llamar adaptiveModuleCount (rápido)
   // - Inicializar moduleStatus en Firestore
   // - Disparar adaptiveModuleGenerate(M1) en background (NO esperar)
   // - Retornar skeleton inmediatamente
   ```

3. 🔨 **Agregar tracking de `moduleStatus` en Firestore**:
   ```typescript
   adaptive_sessions/{userId}/ {
     moduleStatus: {
       "1": "ready",      // Ya generado
       "2": "generating", // En proceso
       "3": "pending",    // No iniciado
       "4": "error"       // Falló, reintentar
     }
   }
   ```

4. 🔨 **Flutter: UI skeleton + loader storytelling** (`lib/features/quiz/quiz_screen.dart`):
   - Mostrar estructura del curso (M1..Mx) en <10s
   - Loader para M1: "Armando tu módulo con ejemplos de [industria]. ~60s"
   - Polling cada 5s para actualizar `moduleStatus`
   - Si error, botón "Reintentar" que llama a `adaptiveModuleGenerate` nuevamente

**Entregables**:
- Usuario ve skeleton inmediatamente post-quiz
- M1 se genera en background, no bloquea UI
- Si tarda >90s, usuario ve mensaje claro (no timeout genérico)

**Esfuerzo**: 4-5 días | **Prioridad**: P0

---

### **Fase 2: Prefetch Inteligente (Semana 2-3 - P1 High)**
**Objetivo**: M2 listo cuando usuario termina M1. Experiencia fluida sin esperas.

**Tareas**:
1. 🔨 **Prefetch con Firestore Triggers** (NO Cloud Scheduler inicialmente):
   ```typescript
   // functions/src/index.ts
   export const onModuleStatusChange = onDocumentWritten(
     "adaptive_sessions/{userId}",
     async (event) => {
       const moduleStatus = event.data.after.get("moduleStatus");

       // Si M1 === "ready" && M2 === "pending" && usuario abrió M1
       if (userOpenedModule(1) && moduleStatus["2"] === "pending") {
         // Generar M2 en background
         await adaptiveModuleGenerateInternal({ moduleId: 2, ... });
       }
     }
   );
   ```

2. 🔨 **Condición crítica de engagement**:
   - **SOLO generar M+1 si usuario abrió módulo anterior**
   - Rastrear `lastOpenedModule` en Firestore
   - Evitar precalentar cursos abandonados (ahorro de costos)

3. 🔨 **Recalibración post-checkpoint**:
   - Actualizar `adaptiveEvaluateCheckpoint` para marcar siguiente módulo como "prefetching"
   - Trigger de Firestore pickea y regenera con nuevo `learnerState`

4. 🔨 **Timeout monitor** (Cloud Function programada cada 5 min):
   - Buscar módulos en "generating" por >10 minutos
   - Marcar como "error" y notificar ops
   - **Nota**: Esto SÍ requiere Cloud Scheduler, pero es opcional para MVP

**Entregables**:
- M2 listo cuando usuario completa M1
- Checkpoints ajustan contenido de módulos siguientes en tiempo real
- No se desperdician tokens OpenAI en cursos abandonados

**Esfuerzo**: 3-4 días | **Prioridad**: P1

---

### **Fase 3: Cache Sharing + Analytics (Semana 4+ - P2 Medium)**
**Objetivo**: Reducir costos 60-80% en contenido popular. Métricas para optimizar.

**Tareas**:
1. 🔨 **Storage caching layer**:
   ```typescript
   // Hash = SHA256(prompt + band + locale + PROMPT_VERSION)
   // Antes de llamar OpenAI:
   const cacheKey = `gs://aelion-cache/${hash}.json`;
   const cached = await storage.bucket().file(cacheKey).exists();
   if (cached && createdAt < 24h) return cached;

   // Guardar + timestamp
   await storage.bucket().file(cacheKey).save(result);
   ```

2. 🔨 **Prompt versioning**:
   - Incluir `PROMPT_VERSION = "2025-11-21"` en hash
   - Invalidar cache automáticamente cuando se actualicen prompts

3. 🔨 **Métricas en `openai_usage`**:
   - Agregar campo `cache_hit: boolean`
   - Dashboard BigQuery: % cache hit rate, tokens ahorrados

4. 🔨 **Analytics dashboard**:
   - Tiempo hasta skeleton (<10s ✅)
   - Tiempo hasta M1 ready (<90s ✅)
   - % sesiones donde M2 ready antes de que usuario llegue
   - Tasa de abandono por módulo

**Entregables**:
- Módulos populares (SQL básico, Inglés A1) se reutilizan entre usuarios
- Dashboard para monitorear performance
- Costos OpenAI reducidos drásticamente

**Esfuerzo**: 5-6 días | **Prioridad**: P2 (solo si ya hay >100 usuarios/día)

---

## 10. Decisiones de Arquitectura Clave

### **¿Cloud Scheduler o Firestore Triggers?**
**Decisión**: Empezar con **Firestore Triggers** para prefetch.

**Razones**:
- Cloud Scheduler = costo adicional (free tier solo 3 jobs)
- Triggers reaccionan en tiempo real a cambios de estado (más eficiente)
- Si escala mal, migrar a Scheduler en Fase 3

**Excepción**: Timeout monitor SÍ usa Cloud Scheduler (polling cada 5 min).

### **¿Prefetch de cuántos módulos?**
**Decisión**: Solo **M+1** (siguiente módulo).

**Razones**:
- Balance costo/beneficio óptimo
- Reduce tokens desperdiciados en cursos abandonados
- Si usuario vuela los módulos, el trigger de Firestore mantiene M+2 cerca

### **¿Cache desde MVP?**
**Decisión**: **NO**. Cache solo en Fase 3.

**Razones**:
- Complejidad innecesaria para <100 usuarios
- Riesgo de stale content si bugs en prompts
- Métricas primero, optimización después

---

## 11. Checklist de Integración

Antes de marcar cada fase como "completa", verificar:

**Fase 1**:
- [ ] `/adaptiveSession/start` retorna en <10s
- [ ] Skeleton UI se muestra inmediatamente post-quiz
- [ ] M1 aparece en <90s desde inicio de generación
- [ ] Loader muestra mensaje storytelling (no "Loading...")
- [ ] Error messages son humanos ("Reintentando...", no "500 Internal Server Error")

**Fase 2**:
- [ ] M2 inicia generación solo si usuario abrió M1
- [ ] Checkpoint recalibra `learnerState` y regenera siguiente módulo
- [ ] No hay módulos "stuck" en "generating" >10 min (timeout monitor)
- [ ] Logs muestran `prefetch triggered by user engagement`

**Fase 3**:
- [ ] Cache hit rate >60% para módulos populares
- [ ] Dashboard muestra "Time to skeleton" promedio <10s
- [ ] Tokens OpenAI consumidos bajaron 50%+ mes a mes
- [ ] Prompt updates invalidan cache (no stale content)

---

La meta es que cualquier persona que abra esta app diga: *"Wow, se nota que me están creando algo a medida y lo hacen rápido."* Si en algún paso no se siente así, vuelves a este documento, detectas el cuello de botella y lo resuelves. No más monolitos lentos. #VamosPorEl10/10
+++++