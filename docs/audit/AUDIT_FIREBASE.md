# AUDIT: INTEGRACION FIREBASE

## dY"S SCORE: 6/10

## PUNTOS POSITIVOS
- `functions/src/index.ts` valida payloads con Zod y usa Firestore/Storage reales para generar outlines.
- `firestore.rules` mantiene la base cerrada (`allow read, write: if false`).

## PROBLEMAS Y ESTADO

### Falta indice para trending
- **Ubicacion:** firestore.indexes.json
- **STATUS:** fixed - añadido indice compuesto `lang ASC, ts DESC` para la coleccion `trending`.

### Pipeline de outline demo
- **Ubicacion:** functions/src/index.ts
- **STATUS:** fixed - el handler `outline` consulta Firestore/Storage y, en su defecto, combina plantillas curadas + LLM con progreso y TTL.

### Rate limit colisiona usuarios anonimos
- **Ubicacion:** functions/src/index.ts
- **STATUS:** fixed - `enforceRateLimit` usa fingerprint (IP + UA + idioma) y aplica limites separados para anon/auth en outline y trending.

### Pendiente: metricas de coste Firebase
- **Ubicacion:** docs/agents/AGENT_FIREBASE_PERF.md
- **Impacto:** sin tracking de coste/performance en agregados.
- **Detalle:** definir coleccion `analytics_costs`, cron y alertas.
- **STATUS:** partial - handlers `/outline` y `/trending` registran muestras en `analytics_costs` con latencia/contadores; faltan dashboards y alertas de presupuesto.

