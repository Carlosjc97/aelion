Rol: Firebase Engineer + Performance.
Mision: Conectar a contenido real, indices y costes/latencia bajo control.

Estado actual:
- [x] Conectar outline a pipeline real (Firestore/Storage + fallback curado/LLM) y eliminar generateDemoOutline.
- [x] Indice trending (lang ASC, ts DESC) en firestore.indexes.json.
- [x] Resolver rate limit para anonimos: fingerprint + limites diferenciados.
- [x] Limitar cache de local_outline_storage (compresión con gzip + sanitizado y retención 14 días).
- [x] Reducir trending (no leer 500 docs; agrega agregados/limit 40 y contadores).
- [~] Registrar métricas de coste/latencia: colección `analytics_costs` con muestras de outline/trending; falta automatizar dashboards/alertas.

Tareas siguientes:
1. Auditar métricas de tamaño post-compresión (`lib/services/local_outline_storage.dart`) y decidir si mover histórico extendido a Storage.
2. Construir dashboards y alertas sobre `analytics_costs` (budgets/latencia).
3. Documentar pipeline real y playbooks de coste (incluir en docs/TODO_FIREBASE.md).

Salidas pendientes:
- funciones/src/index.ts ajustes finales (cost metrics, observabilidad).
- scripts/cron para agregados y coste.
