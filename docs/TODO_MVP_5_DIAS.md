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

**D�A 2: INTEGRACI�N**  COMPLETADO 100% (2025-11-04)
- [x] Banco cargado en server/assessment.js
- [x] Assessment flow E2E funcionando
- [x] /outline endpoint con contenido SQL real  NUEVO
- [x] Tests de integracion pasando  NUEVO
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

## ⏰ DÍA 3: PAYWALL ✅ COMPLETADO (2025-11-04)

### 🎯 Objetivo: Monetización funcional

**Entregables:**
- [x] Paywall modal UI (diseño simple)
- [x] M1 gratis (desbloqueado siempre)
- [x] M2-M6 bloqueados (mostrar candado)
- [ ] Mock bloqueado (no implementado - DÍA 4)
- [ ] PDF bloqueado (no implementado - DÍA 4)
- [x] 3 CTAs (estructura creada):
  - Post-calibración: "Desbloquear plan completo" (modal listo, trigger pendiente)
  - Al abrir M2: "Continuar con Premium" ✅
  - Al abrir Mock: "Acceder a examen de práctica" (modal listo, trigger pendiente)
- [x] RevenueCat básico (trial 7 días - mock sin cobro real)

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

## ⏰ DÍA 4: POLISH MÍNIMO ✅ COMPLETADO (2025-11-04)

### 🎯 Objetivo: App estable para testing interno

**Entregables:**
- [x] Smoke tests manuales (checklist completo) ✅
- [x] GA4 eventos críticos implementados:
  - ✅ `paywall_viewed` (post_calibration, module_locked)
  - ✅ `trial_start` (trigger, trial_days)
  - ✅ `module_started` (module_id, topic)
  - ✅ `module_completed` (module_id, topic, duration_s)
  - ⚠️ `calibration_start` (no implementado - DÍA 5)
  - ⚠️ `calibration_complete` (no implementado - DÍA 5)
  - ⚠️ `mock_start` (mock exam no existe en UI)
- [x] README actualizado con paywall info ✅
- [x] Trigger post_calibration implementado ✅
- [ ] Crashlytics configurado (DÍA 5)
- [ ] Landing page mínima (DÍA 5)

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

## ⏰ DÍA 5: LANZAR 🚀 ⚠️ EN PROGRESO (Lunes 11 Nov 2025)

### 🎯 Objetivo: App en Play Store (Android)

**Entregables:**
- [x] TestFlight guide (referencia iOS - futuro) ✅
- [x] Dashboard GA4 con métricas críticas ✅ (Config documentada)
- [x] Crashlytics monitoreando 24/7 ✅ (Ya configurado)
- [x] Landing page (HTML responsive) ✅
- [x] Plan de comunicación completo ✅ (4 canales, timeline, templates)
- [ ] Play Store Internal Testing (Android) ⏳ FIN DE SEMANA
- [ ] Features finales MVP (onboarding, language switch, reveal) ⏳

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

## ⏰ FIN DE SEMANA (8-10 Nov) - FEATURES FINALES

### 🔴 CRÍTICO (Viernes-Sábado):
- [ ] Onboarding 5 preguntas (edad, intereses, escolaridad, SQL exp, beta tester)
- [ ] Language switcher (EN ↔ ES)
- [ ] "Tu nivel en 60s" reveal post-calibración
- [ ] Share button (LinkedIn/Twitter)
- [ ] Google Play Console setup + Google Play Billing ($9.99/mes)
- [ ] Build release AAB + upload Internal Testing

### 🟡 IMPORTANTE (Domingo):
- [ ] Smoke tests completos (ES + EN)
- [ ] Fix bugs P0
- [ ] Internal testing con 5-10 personas
- [ ] Screenshots Play Store (6+ ES, 6+ EN)

### ❌ NO PARA AHORA:
- ❌ Track "Inglés Técnico" contenido → Placeholder "Coming Soon"
- ❌ Leaderboard → Semana 2
- ❌ Curso on-demand → Mes 3-4
- ❌ Refactors → Post-PMF

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
