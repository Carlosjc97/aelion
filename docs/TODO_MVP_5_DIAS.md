# 🚀 PLAN MVP: LANZAR EN 5 DÍAS

> **Principio:** Código feo que funciona > Código perfecto sin usuarios
> **Objetivo:** Trial start rate ≥ 6% en los primeros 100 usuarios

---

## ⏰ DÍA 1: CONTENIDO (HOY)

### 🎯 Objetivo: Banco completo de preguntas SQL

**Entregables:**
- [x] 100 preguntas SQL para Marketing en JSON
- [x] 6 módulos estructurados (SELECT → Window Functions)
- [x] Parámetros IRT (a,b,c) aproximados por pregunta
- [x] Mock exam (10 preguntas subset)
- [x] Tags por módulo y dificultad

**Archivos a crear:**
```
content/sql-marketing/question-bank.json
content/sql-marketing/modules.json
content/sql-marketing/mock-exam.json
```

**Criterio de éxito:**
- ✅ Puedes importar el JSON en server/assessment.js sin errores
- ✅ Distribución: 80% multiple choice / 10% V/F / 10% multi-select
- ✅ Ejemplos LATAM (Mercado Libre, Rappi, etc.)

---

## ⏰ DÍA 2: INTEGRACIÓN

### 🎯 Objetivo: Flujo E2E funcional

**Entregables:**
- [x] Banco cargado en server/assessment.js (reemplazar sintético)
- [x] Assessment flow E2E funcionando con banco SQL real
- [x] IRT adaptativo funcionando (validado con test)
- [ ] Plan generado basado en nivel detectado (pendiente /outline)
- [ ] Gates (6-10 preguntas por bloque) funcionando (backend listo, falta UI)
- [ ] Mock exam disponible (pendiente)

**Archivos a modificar:**
```
server/assessment.js (buildQuestionBank → loadFromJSON)
functions/src/index.ts (outline handler)
lib/features/assessment/* (UI calibración)
```

**Criterio de éxito:**
- ✅ Usuario completa calibración → ve plan adaptado a su nivel
- ✅ Usuario completa M1 → gate decide si avanza o repite
- ✅ Mock exam carga correctamente

**Testing:**
```bash
# Smoke test manual
1. Abrir app
2. "Generar plan con IA"
3. Completar calibración (10 preguntas)
4. Ver plan generado
5. Completar M1
6. Verificar gate
7. Abrir Mock (debe mostrar paywall)
```

---

## ⏰ DÍA 3: PAYWALL

### 🎯 Objetivo: Monetización funcional

**Entregables:**
- [ ] Paywall modal UI (diseño simple)
- [ ] M1 gratis (desbloqueado siempre)
- [ ] M2-M6 bloqueados (mostrar candado)
- [ ] Mock bloqueado
- [ ] PDF bloqueado
- [ ] 3 CTAs:
  - Post-calibración: "Desbloquear plan completo"
  - Al abrir M2: "Continuar con Premium"
  - Al abrir Mock: "Acceder a examen de práctica"
- [ ] RevenueCat básico (trial 7 días)

**Archivos a crear:**
```
lib/features/paywall/paywall_modal.dart
lib/features/paywall/paywall_controller.dart
lib/services/entitlements_service.dart (mock para MVP)
```

**Criterio de éxito:**
- ✅ Usuario ve paywall después de calibración
- ✅ Usuario puede iniciar trial (mock, sin cobro real)
- ✅ M1 funciona sin premium
- ✅ M2-M6 muestran candado
- ✅ Mock bloqueado hasta premium

**Testing:**
```bash
# User flow
1. Completar calibración → Ver paywall
2. Hacer M1 gratis → Funciona
3. Intentar M2 → Paywall
4. Iniciar trial (mock) → Desbloquea todo
5. Abrir Mock → Funciona
```

---

## ⏰ DÍA 4: POLISH MÍNIMO

### 🎯 Objetivo: App estable para testing interno

**Entregables:**
- [ ] Smoke tests manuales (checklist completo)
- [ ] GA4 eventos críticos:
  - `calibration_start`
  - `calibration_complete`
  - `paywall_shown`
  - `trial_start`
  - `module_complete`
  - `mock_start`
- [ ] Crashlytics configurado
- [ ] README actualizado con screenshots
- [ ] Landing page mínima (1 página HTML)

**Smoke tests checklist:**
```
[ ] App abre sin crash
[ ] Calibración completa sin errores
[ ] Plan se genera correctamente
[ ] M1 funciona sin premium
[ ] M2 muestra paywall
[ ] Trial desbloquea contenido
[ ] Mock carga sin errores
[ ] Back button no rompe flujo
[ ] Progreso se guarda
[ ] Notificaciones D+1 (programadas)
```

**GA4 eventos:**
```javascript
// En cada pantalla crítica
analytics.logEvent('calibration_start', {
  track: 'sql-marketing',
  timestamp: Date.now()
});
```

**Landing page:**
```
- Título: "Aprende SQL en 3 semanas, no en 3 meses"
- Propuesta de valor (3 bullets)
- CTA: "Empieza gratis"
- Testimonios (si hay)
- Footer: Legal + contacto
```

**Criterio de éxito:**
- ✅ 20 usuarios internos completan flujo sin crash
- ✅ Eventos GA4 llegando correctamente
- ✅ Landing page funcional

---

## ⏰ DÍA 5: LANZAR 🚀

### 🎯 Objetivo: App en manos de usuarios reales

**Entregables:**
- [ ] TestFlight/Internal Track con 20 slots
- [ ] Dashboard GA4 con métricas críticas
- [ ] Crashlytics monitoreando 24/7
- [ ] Landing page live (dominio/subdomain)
- [ ] Plan de comunicación (¿dónde compartir?)

**Métricas a monitorear:**
```
Día 1-3:
- Calibration completion rate
- Paywall shown → Trial start
- M1 completion rate
- Crash-free rate

Día 4-7:
- D7 retention
- Trial → Pago (día 7)
- Mock completion rate
- Churn rate
```

**Canales de lanzamiento:**
```
1. Red personal (LinkedIn, Twitter)
2. Comunidades LATAM (Slack, Discord)
3. Product Hunt (si hay momentum)
4. Reddit (r/learnprogramming, r/datascience)
```

**Criterio de éxito:**
- ✅ 100 usuarios completan calibración
- ✅ Trial start rate ≥ 6%
- ✅ Crash-free rate ≥ 99%
- ✅ p95 loading < 10s

---

## ❌ LO QUE NO HACEMOS (por ahora)

### Refactors no urgentes:
- ❌ ModuleOutlineView (2140 líneas) → **DESPUÉS**
- ❌ Tests E2E completos → **DESPUÉS**
- ❌ Recalibración IRT perfecta → **DESPUÉS**
- ❌ Functions tests con emulador → **DESPUÉS**
- ❌ Performance <4s → **DESPUÉS**

### Features no críticas:
- ❌ Notificaciones T-12h → **DESPUÉS**
- ❌ PDF cheatsheet → **DESPUÉS** (puede ser M2-M6 desbloqueados)
- ❌ Múltiples tracks → **DESPUÉS**
- ❌ A/B testing paywall → **DESPUÉS** (1 versión primero)

### Polish no urgente:
- ❌ Animaciones fancy → **DESPUÉS**
- ❌ Dark mode → **DESPUÉS**
- ❌ Onboarding tutorial → **DESPUÉS**
- ❌ Gamificación → **DESPUÉS**

---

## 🎯 DEFINICIÓN DE ÉXITO MVP

### Métricas críticas (primeros 7 días):
```
✅ 100+ usuarios completaron calibración
✅ Trial start rate ≥ 6%
✅ Crash-free rate ≥ 99%
✅ D7 retention ≥ 12%
✅ M1 completion rate ≥ 60%
```

### Señales cualitativas:
- Usuarios reportan que el contenido es útil
- Nivel detectado por calibración se siente correcto
- Paywall timing no se siente agresivo
- App no se siente lenta

---

## 📞 CONTACTO Y ESCALATION

**Si algo se bloquea:**
1. ¿Puedo hacerlo más simple? → Hazlo
2. ¿Puedo mockearlo por ahora? → Mockéalo
3. ¿Es realmente bloqueante? → Si no, skip

**Principio guía:**
> "Mejor hecho que perfecto. Mejor lanzado que optimizado. Mejor con usuarios que sin ellos."

---

**Creado:** 2025-01-04
**Owner:** Equipo Edaptia
**Deadline:** DÍA 5 (LANZAR)
