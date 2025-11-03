# AUDIT: SEGURIDAD

## 📊 SCORE: 7/10

## ✅ LO QUE ESTÁ BIEN
- `.env` con llaves productivas eliminado; el repo depende ahora de configuraciones externas/Secret Manager.
- `functions/src/index.ts:20-236` obliga `ALLOWED_ORIGINS` y corta origenes no autorizados con respuesta 403.
- `server/server.js:18-70` replica la whitelist de CORS (env `SERVER_ALLOWED_ORIGINS`) y devuelve `forbidden_origin` cuando el origen no está permitido.
- `server/security.js:18-39` falla el arranque si `ASSESSMENT_HMAC_KEYS` no está definido (solo permite fallback en tests).
- `firestore.rules` continúa cerrando Firestore a cualquier acceso directo desde clientes.

## 🔴 PROBLEMAS CRÍTICOS (Arreglar HOY)

### Gestión de secretos sin proceso formal
- **Ubicación:** pipeline de despliegue (Functions + servidor)
- **Impacto:** riesgo de volver a introducir llaves en texto plano o quedar sin rotación oportuna.
- **Detalle:** documentar y automatizar carga en Secret Manager/Firebase Config, incluir validación en CI y playbook de rotación.

### Políticas de auditoría y monitoreo inexistentes
- **Ubicación:** operaciones
- **Impacto:** sin alertas ni trazabilidad, cualquier intrusión o abuso del motor IRT/Functions pasará desapercibido.
- **Detalle:** configurar alertas (Cloud Monitoring, GCP Audit Logs) y reglas de detección para 5xx, intentos fallidos de firma HMAC y patrones de abuso en `/assessment`.
