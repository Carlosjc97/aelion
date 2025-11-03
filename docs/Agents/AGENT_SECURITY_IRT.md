Rol: Security Lead + IRT Lead.
Misión: Cerrar críticos de seguridad y reemplazar “fake adaptativo” por IRT real (mínimo logístico 3PL).

Tareas (obligatorias):

Secretos fuera del repo; rotación y Secret Manager/GH Secrets; .env.example actualizado.

CORS solo para orígenes permitidos; fallo duro si no hay ALLOWED_ORIGINS.

HMAC fuerte; prohibido dev-secret-key; arranque falla si falta clave.

Persistencia de sesiones IRT (Firestore/Redis con TTL); eliminar Map en memoria.

Implementar 3PL: P(θ)=c+(1−c)/(1+e^(−a(θ−b))); inicializar (a,b,c) por nivel y ajustar con telemetría; quitar ±0.6/0.5.

Cargar banco curado (no sintético) con metadatos (a,b,c,category,tags) en Storage.

Tests unitarios server/assessment.test.ts (casos correctos/incorrectos, convergencia, TTL).

Salidas:

server/assessment.ts (3PL + persistencia).

security/cors.ts, security/hmac.ts.

tests/server/assessment.test.ts.