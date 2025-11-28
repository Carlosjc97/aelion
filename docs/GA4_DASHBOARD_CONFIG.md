# GA4 Dashboard Configuration - Edaptia MVP

> **Objetivo:** Monitor mÃ©tricas crÃ­ticas para los primeros 100 usuarios
> **Fecha:** 2025-11-04

---

## ðŸŽ¯ MÃ©tricas CrÃ­ticas (MVP)

### **Funnel Principal**
```
100 usuarios â†’ CalibraciÃ³n â†’ Paywall â†’ Trial â†’ M1 Complete
```

**Targets (primeros 7 dÃ­as):**
- Calibration completion rate: â‰¥ 70%
- Trial start rate: â‰¥ 6%
- M1 completion rate: â‰¥ 60%
- Crash-free rate: â‰¥ 99%
- D7 retention: â‰¥ 12%

---

## ðŸ“Š Eventos GA4 Implementados

### **Core Events**
```javascript
// 1. Paywall Events
paywall_viewed {
  placement: 'post_calibration' | 'module_locked' | 'mock_locked',
  schema_ver: 'v1',
  app_version: string,
  platform: 'android' | 'ios',
  lang: string
}

trial_start {
  trigger: 'post_calibration' | 'module_locked' | 'mock_locked',
  trial_days: 7,
  schema_ver: 'v1',
  app_version: string
}

// 2. Module Events
module_started {
  module_id: 'M1' | 'M2' | ... | 'M6',
  topic: 'SQL',
  band: 'beginner' | 'intermediate' | 'advanced',
  lesson_count: number,
  schema_ver: 'v1'
}

module_completed {
  module_id: string,
  topic: string,
  band: string,
  lesson_count: number,
  duration_s: number,  // Clamped to 8 hours max
  schema_ver: 'v1'
}

// 3. User Identification
user_identified {
  provider: 'guest' | 'google',
  lang: string,
  is_guest: boolean,
  schema_ver: 'v1'
}

// 4. Notifications
notification_opt_in {
  status: 'granted' | 'denied',
  schema_ver: 'v1'
}

// 5. Purchase (Mock)
purchase_completed {
  plan: string,
  price_usd: number,
  schema_ver: 'v1'
}
```

### **Context Properties (All Events)**
```javascript
{
  schema_ver: 'v1',
  app_version: '1.0.0+1',
  platform: 'android' | 'ios' | 'web',
  build_type: 'debug' | 'release',
  lang: 'es' | 'en',
  country: string,
  install_source: string,
  experiment_variant: 'none' | JSON
}
```

---

## ðŸ”§ ConfiguraciÃ³n en Firebase Console

### **Paso 1: Crear Dashboard Custom**

1. Ir a **Firebase Console** â†’ Analytics â†’ Dashboard
2. Click "Create custom report"
3. Nombre: "MVP 5 DÃAS - Core Metrics"

### **Paso 2: Agregar Cards**

#### **Card 1: Funnel de ConversiÃ³n**
```
Type: Funnel
Events:
  1. user_identified
  2. paywall_viewed (placement = 'post_calibration')
  3. trial_start
  4. module_started (module_id = 'M1')
  5. module_completed (module_id = 'M1')

Dimensions: None
Filters: None
Time range: Last 7 days
```

#### **Card 2: Trial Start Rate**
```
Type: Metric
Metric: trial_start (count)
Breakdown: trigger
Time range: Last 7 days
Comparison: Previous period
```

#### **Card 3: Paywall Performance**
```
Type: Table
Rows: placement
Metrics:
  - paywall_viewed (count)
  - trial_start (count)
  - Conversion rate (calculated)
Time range: Last 7 days
```

#### **Card 4: Module Completion**
```
Type: Bar chart
X-axis: module_id
Y-axis: module_completed (count)
Breakdown: band (beginner/intermediate/advanced)
Time range: Last 7 days
```

#### **Card 5: User Segments**
```
Type: Pie chart
Dimension: band
Metric: user_identified (count)
Time range: Last 7 days
```

#### **Card 6: Platform Distribution**
```
Type: Pie chart
Dimension: platform
Metric: user_identified (count)
Time range: Last 7 days
```

---

## ðŸ“ˆ Queries Ãštiles (BigQuery)

### **Query 1: Trial Conversion Rate por Trigger**
```sql
WITH paywall_views AS (
  SELECT
    user_pseudo_id,
    event_timestamp,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'placement') AS placement
  FROM `Edaptia-c90d2.analytics_*.events_*`
  WHERE event_name = 'paywall_viewed'
    AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
      AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
),
trial_starts AS (
  SELECT
    user_pseudo_id,
    event_timestamp,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'trigger') AS trigger
  FROM `Edaptia-c90d2.analytics_*.events_*`
  WHERE event_name = 'trial_start'
    AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
      AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
)
SELECT
  pv.placement,
  COUNT(DISTINCT pv.user_pseudo_id) AS paywall_views,
  COUNT(DISTINCT ts.user_pseudo_id) AS trial_starts,
  SAFE_DIVIDE(COUNT(DISTINCT ts.user_pseudo_id), COUNT(DISTINCT pv.user_pseudo_id)) * 100 AS conversion_rate_pct
FROM paywall_views pv
LEFT JOIN trial_starts ts
  ON pv.user_pseudo_id = ts.user_pseudo_id
  AND pv.placement = ts.trigger
  AND ts.event_timestamp > pv.event_timestamp
  AND ts.event_timestamp < TIMESTAMP_ADD(pv.event_timestamp, INTERVAL 1 HOUR)
GROUP BY pv.placement
ORDER BY conversion_rate_pct DESC;
```

### **Query 2: M1 Completion Funnel**
```sql
WITH users AS (
  SELECT DISTINCT user_pseudo_id
  FROM `Edaptia-c90d2.analytics_*.events_*`
  WHERE event_name = 'user_identified'
    AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
      AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
),
m1_started AS (
  SELECT DISTINCT user_pseudo_id
  FROM `Edaptia-c90d2.analytics_*.events_*`
  WHERE event_name = 'module_started'
    AND (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'module_id') = 'M1'
    AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
      AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
),
m1_completed AS (
  SELECT DISTINCT user_pseudo_id
  FROM `Edaptia-c90d2.analytics_*.events_*`
  WHERE event_name = 'module_completed'
    AND (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'module_id') = 'M1'
    AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
      AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
)
SELECT
  'Total Users' AS stage,
  COUNT(*) AS count,
  100.0 AS percentage
FROM users
UNION ALL
SELECT
  'M1 Started',
  COUNT(*),
  SAFE_DIVIDE(COUNT(*), (SELECT COUNT(*) FROM users)) * 100
FROM m1_started
UNION ALL
SELECT
  'M1 Completed',
  COUNT(*),
  SAFE_DIVIDE(COUNT(*), (SELECT COUNT(*) FROM users)) * 100
FROM m1_completed;
```

### **Query 3: D7 Retention**
```sql
WITH cohort AS (
  SELECT
    user_pseudo_id,
    MIN(DATE(TIMESTAMP_MICROS(event_timestamp))) AS cohort_date
  FROM `Edaptia-c90d2.analytics_*.events_*`
  WHERE event_name = 'user_identified'
    AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 14 DAY))
      AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
  GROUP BY user_pseudo_id
),
activity AS (
  SELECT DISTINCT
    user_pseudo_id,
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS activity_date
  FROM `Edaptia-c90d2.analytics_*.events_*`
  WHERE _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 14 DAY))
      AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
)
SELECT
  c.cohort_date,
  COUNT(DISTINCT c.user_pseudo_id) AS cohort_size,
  COUNT(DISTINCT CASE
    WHEN DATE_DIFF(a.activity_date, c.cohort_date, DAY) = 7 THEN a.user_pseudo_id
  END) AS d7_retained,
  SAFE_DIVIDE(
    COUNT(DISTINCT CASE WHEN DATE_DIFF(a.activity_date, c.cohort_date, DAY) = 7 THEN a.user_pseudo_id END),
    COUNT(DISTINCT c.user_pseudo_id)
  ) * 100 AS d7_retention_pct
FROM cohort c
LEFT JOIN activity a ON c.user_pseudo_id = a.user_pseudo_id
WHERE c.cohort_date <= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY c.cohort_date
ORDER BY c.cohort_date DESC;
```

---

## ðŸš¨ Alertas Sugeridas

### **Alerta 1: Trial Start Rate Bajo**
```
Condition: trial_start (count) / paywall_viewed (count) < 0.06
Timeframe: Last 24 hours
Notification: Email + Slack
Action: Revisar paywall copy/UX
```

### **Alerta 2: Crash Spike**
```
Condition: crash_count > 5 en 1 hora
Timeframe: Real-time
Notification: Email + SMS
Action: Rollback inmediato
```

### **Alerta 3: M1 Completion Drop**
```
Condition: module_completed (M1) / module_started (M1) < 0.60
Timeframe: Last 3 days
Notification: Email
Action: Revisar contenido M1
```

---

## ðŸ“± DebugView (Testing)

**Activar DebugView para testing:**

### Android
```bash
adb shell setprop debug.firebase.analytics.app com.Edaptia.app
```

### iOS
```bash
# En Xcode: Edit Scheme â†’ Run â†’ Arguments â†’ Launch Arguments
-FIRAnalyticsDebugEnabled
```

**Validar eventos:**
1. Abrir Firebase Console â†’ Analytics â†’ DebugView
2. Ejecutar flujo en emulador/device
3. Verificar eventos aparecen en real-time
4. Validar properties correctas

---

## ðŸŽ¯ KPIs Semanales (Primeros 30 dÃ­as)

| MÃ©trica | Target | CrÃ­tico |
|---------|--------|---------|
| Trial start rate | â‰¥ 6% | SÃ­ |
| Calibration completion | â‰¥ 70% | SÃ­ |
| M1 completion | â‰¥ 60% | SÃ­ |
| Crash-free rate | â‰¥ 99% | SÃ­ |
| D7 retention | â‰¥ 12% | No |
| Avg session duration | â‰¥ 15 min | No |
| M2-M6 unlock rate | â‰¥ 30% | No |

---

**Ãšltima actualizaciÃ³n:** 2025-11-04
**Owner:** Analytics Team
**PrÃ³xima revisiÃ³n:** DÃ­a 7 post-launch

