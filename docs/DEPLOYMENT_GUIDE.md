# Guía de Deployment - Edaptia
> **Fecha:** 2025-01-03
> **Status:** Ready for Production

---

## ✅ PUNTO 1: Configurar Secretos (COMPLETADO)

Ya completaste este paso:
- `OPENAI_API_KEY` → versión 4 ✅
- `ASSESSMENT_HMAC_KEYS` → versión 1 ✅

---

## 🔧 PUNTO 2: Verificar Secretos

Verifica que los secretos existan y sean accesibles:

```bash
# Opción A: Usando el script
node scripts/secrets-manager.js verify

# Opción B: Manual con gcloud
gcloud secrets versions access latest --secret="OPENAI_API_KEY"
gcloud secrets versions access latest --secret="ASSESSMENT_HMAC_KEYS"
```

**Salida esperada:**
```
✓ OPENAI_API_KEY exists
✓ ASSESSMENT_HMAC_KEYS exists
✓ All required secrets are configured
```

**Si falla:**
- Verifica que estés autenticado: `gcloud auth list`
- Verifica el proyecto: `gcloud config get-value project` (debe ser `edaptia`)
- Verifica permisos: necesitas rol `Secret Manager Secret Accessor`

---

## 📊 PUNTO 3: Desplegar Alertas de Cloud Monitoring

### Paso 3.1: Revisar las políticas de alertas

```bash
# Ver el archivo de configuración
cat infrastructure/monitoring/alerts.yaml
```

Este archivo define 4 alertas:
1. High Error Rate (5xx > 5%)
2. Authentication Failures (> 50/min)
3. Rate Limit Violations (> 100/min)
4. HMAC Signature Failures (> 50/min)

### Paso 3.2: Crear las alertas

**IMPORTANTE:** Cloud Monitoring Alert Policies requieren configuración manual o API. El archivo YAML es referencia.

#### Opción A: Crear via Cloud Console (RECOMENDADO)

1. Ve a Cloud Console: https://console.cloud.google.com/monitoring/alerting?project=edaptia
2. Click en **"Create Policy"**
3. Para cada alerta en `infrastructure/monitoring/alerts.yaml`:

**Alerta 1: High Error Rate**
- Nombre: `Edaptia - High Error Rate (5xx)`
- Condición:
  - Resource type: `Cloud Run Revision` (si usas Cloud Run) o `GCE VM Instance`
  - Metric: `logging.googleapis.com/user/errors` o filtro de logs
  - Filter: `severity="ERROR" AND httpRequest.status>=500`
  - Threshold: `count > 5% of requests in 5 minutes`
- Notification: Email a tu equipo
- Documentation: Ver `infrastructure/monitoring/alerts.yaml` línea 6-15

**Alerta 2: Authentication Failures**
- Nombre: `Edaptia - Authentication Failures`
- Condición:
  - Metric: `logging.googleapis.com/user/auth_failures`
  - Filter: `jsonPayload.event="auth_failure"`
  - Threshold: `count > 50 in 1 minute`

**Alerta 3: Rate Limit Violations**
- Nombre: `Edaptia - Rate Limit Violations`
- Condición:
  - Metric: `logging.googleapis.com/user/rate_limit_violations`
  - Filter: `httpRequest.status=429`
  - Threshold: `count > 100 in 1 minute`

**Alerta 4: HMAC Signature Failures**
- Nombre: `Edaptia - HMAC Failures`
- Condición:
  - Metric: `logging.googleapis.com/user/hmac_failures`
  - Filter: `jsonPayload.error="invalid_signature"`
  - Threshold: `count > 50 in 1 minute`

#### Opción B: Saltar por ahora (puede configurarse después)

Si no tienes tráfico en producción todavía, puedes posponer las alertas y configurarlas cuando tengas métricas reales.

**Para continuar sin alertas:**
```bash
echo "⚠️ Alertas pendientes - configurar después del primer deploy"
```

---

## 📈 PUNTO 4: Desplegar Dashboard

### Paso 4.1: Crear dashboard via Cloud Console

1. Ve a: https://console.cloud.google.com/monitoring/dashboards?project=edaptia
2. Click en **"Create Dashboard"**
3. Nombre: `Edaptia Security Dashboard`
4. Agregar widgets según `infrastructure/monitoring/dashboards.json`:

**Widget 1: Authentication Success Rate**
- Tipo: Line Chart
- Metric: `logging.googleapis.com/user/auth_success`
- Filter: `jsonPayload.event="auth_success"`
- Aggregation: Rate

**Widget 2: Rate Limiting Activity**
- Tipo: Scorecard
- Metric: `logging.googleapis.com/user/rate_limit_hits`
- Filter: `httpRequest.status=429`
- Aggregation: Count

**Widget 3: Error Rates por Endpoint**
- Tipo: Table
- Metric: `logging.googleapis.com/user/errors`
- Group by: `httpRequest.requestUrl`
- Aggregation: Count

**Widget 4: HMAC Validation Status**
- Tipo: Gauge
- Metric: `logging.googleapis.com/user/hmac_success_rate`
- Aggregation: Percentage

### Paso 4.2: Opción rápida - Saltar dashboard

El dashboard es útil pero no crítico para el deployment inicial:

```bash
echo "⚠️ Dashboard pendiente - usar Cloud Logging por ahora"
```

Puedes usar Cloud Logging directamente:
```bash
# Ver logs en tiempo real
gcloud logging tail --project=edaptia

# Filtrar errores
gcloud logging read "severity>=ERROR" --limit=50 --format=json
```

---

## 🚀 PUNTO 5: Deploy Express Server a Cloud Run

### Paso 5.1: Preparar el servidor

```bash
# 1. Cargar secretos localmente para testing
node scripts/secrets-manager.js load

# 2. Verificar que el .env se creó
cat .env

# Debería mostrar:
# OPENAI_API_KEY=sk-...
# ASSESSMENT_HMAC_KEYS=...
```

### Paso 5.2: Ejecutar tests localmente

```bash
cd server
npm test
```

**Salida esperada:**
```
✓ 27 tests passed
```

**Si falla algún test:**
- Verifica que `OPENAI_API_KEY` esté configurado
- Verifica que `ASSESSMENT_HMAC_KEYS` esté configurado
- Revisa los logs del test que falló

### Paso 5.3: Deploy a Cloud Run

```bash
cd server

# Deploy con gcloud
gcloud run deploy assessment-api \
  --source . \
  --region us-central1 \
  --allow-unauthenticated \
  --platform managed \
  --memory 512Mi \
  --timeout 60 \
  --max-instances 10 \
  --set-env-vars NODE_ENV=production \
  --set-secrets OPENAI_API_KEY=OPENAI_API_KEY:latest,ASSESSMENT_HMAC_KEYS=ASSESSMENT_HMAC_KEYS:latest
```

**IMPORTANTE:** El flag `--set-secrets` conecta Cloud Run con Secret Manager directamente. NO necesitas el archivo `.env` en producción.

**Salida esperada:**
```
Deploying container to Cloud Run service [assessment-api]...
✓ Deploying... Done.
  ✓ Creating Revision...
  ✓ Routing traffic...
Done.
Service [assessment-api] revision [assessment-api-00001-abc] has been deployed
Service URL: https://assessment-api-XXXXXXXXXX-uc.a.run.app
```

### Paso 5.4: Copiar la URL del servicio

**IMPORTANTE:** Guarda la Service URL que aparece al final. La necesitarás para el siguiente paso.

Ejemplo:
```
https://assessment-api-abc123-uc.a.run.app
```

---

## ✅ PUNTO 6: Verificar Deployment

### Paso 6.1: Health Check

Usa la URL del paso anterior:

```bash
# Reemplaza <SERVICE_URL> con tu URL real
curl https://assessment-api-XXXXXXXXXX-uc.a.run.app/health
```

**Salida esperada:**
```json
{"ok":true}
```

**Si falla:**
- Error 404: Verifica la URL
- Error 500: Revisa logs: `gcloud run logs read assessment-api --limit=50`
- Timeout: Verifica que el servicio esté iniciado: `gcloud run services list`

### Paso 6.2: Test de autenticación

Necesitas un token de Firebase válido. Desde tu app Flutter en modo debug:

```dart
// En tu app, obtén el token
final user = FirebaseAuth.instance.currentUser;
final token = await user?.getIdToken();
print('Token: $token');
```

Luego prueba el endpoint:

```bash
# Reemplaza <TOKEN> con el token real y <SERVICE_URL> con tu URL
curl -X POST https://assessment-api-XXXXXXXXXX-uc.a.run.app/assessment/start \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "X-Timestamp: $(date +%s)000" \
  -H "X-Signature: test" \
  -d '{
    "topicId": "javascript-basics",
    "maxQuestions": 20
  }'
```

**Si todo está bien:**
- Recibirás un `sessionId`
- Verás logs en Cloud Logging

**Si falla con 401:**
- El token expiró (obtén uno nuevo)
- Firebase Auth no está configurado correctamente

**Si falla con 403:**
- La firma HMAC es inválida (esto es esperado con `"X-Signature: test"`)
- Para un test real, usa el cliente Flutter que ya calcula la firma correctamente

### Paso 6.3: Actualizar configuración de la app Flutter

Ahora que tienes la URL de producción, actualízala en tu app:

```bash
# Edita el archivo de configuración
code lib/core/config/app_config.dart
```

Busca la línea con `baseUrl` y actualízala:

```dart
// Antes (local)
static const String assessmentApiUrl = 'http://localhost:8787';

// Después (producción)
static const String assessmentApiUrl = 'https://assessment-api-XXXXXXXXXX-uc.a.run.app';
```

**MEJOR OPCIÓN:** Usa variables de entorno para diferentes builds:

```dart
class AppConfig {
  static const String assessmentApiUrl =
    String.fromEnvironment('ASSESSMENT_API_URL',
      defaultValue: 'http://localhost:8787');
}
```

Luego compila con:
```bash
flutter build web --dart-define=ASSESSMENT_API_URL=https://assessment-api-xxx.run.app
```

### Paso 6.4: Verificar logs

```bash
# Ver logs del servidor
gcloud run logs read assessment-api --limit=50 --format=json

# Filtrar solo errores
gcloud run logs read assessment-api --limit=50 | grep ERROR

# Seguir logs en tiempo real
gcloud run logs tail assessment-api
```

---

## 🎉 DEPLOYMENT COMPLETO

Si llegaste aquí, tu servidor está en producción con:
- ✅ Autenticación Firebase
- ✅ Secretos seguros en Secret Manager
- ✅ HMAC + Rate Limiting
- ✅ Logs estructurados
- ✅ Health checks

---

## 🔄 PRÓXIMOS PASOS OPCIONALES

### Configurar dominio personalizado

```bash
gcloud run domain-mappings create \
  --service assessment-api \
  --domain api.edaptia.com \
  --region us-central1
```

### Configurar CORS para producción

Edita `server/server.js` línea 45:

```javascript
// Cambiar de:
origin: true

// A:
origin: ['https://edaptia.web.app', 'https://edaptia.com']
```

Luego redeploy:
```bash
gcloud run deploy assessment-api --source .
```

### Configurar CI/CD automático

Crea `.github/workflows/deploy-production.yml`:

```yaml
name: Deploy to Production

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}
      - name: Deploy to Cloud Run
        run: |
          gcloud run deploy assessment-api \
            --source ./server \
            --region us-central1
```

---

## 📞 TROUBLESHOOTING

### Error: "Secret not found"

```bash
# Listar secretos disponibles
gcloud secrets list

# Verificar permisos
gcloud secrets get-iam-policy OPENAI_API_KEY
```

### Error: "Service account does not have permission"

```bash
# Dar permisos al service account de Cloud Run
PROJECT_NUMBER=$(gcloud projects describe edaptia --format='value(projectNumber)')
gcloud secrets add-iam-policy-binding OPENAI_API_KEY \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding ASSESSMENT_HMAC_KEYS \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

### Error: "Build failed"

```bash
# Ver logs del build
gcloud builds log $(gcloud builds list --limit=1 --format='value(id)')

# Forzar rebuild
gcloud run deploy assessment-api --source . --no-cache
```

---

**¿Listo para deployar? Empieza con el PUNTO 2 y sigue la guía paso a paso.**
