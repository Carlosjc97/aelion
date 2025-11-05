# Smoke Test Checklist - MVP 5 DÍAS

> **Versión:** 1.0
> **Fecha:** 2025-11-04
> **Objetivo:** Validar flujo E2E antes de lanzamiento

---

## ✅ Pre-requisitos

- [ ] App instalada en emulador/device
- [ ] Internet connection activa
- [ ] Firebase Auth funcionando
- [ ] Assessment API respondiendo (https://assessment-api-110324120650.us-central1.run.app/health)

---

## 🎯 FLUJO PRINCIPAL (Happy Path)

### 1. App Launch
- [ ] App abre sin crash
- [ ] Home screen se carga correctamente
- [ ] No hay errores en consola

### 2. Calibración (Placement Quiz)
- [ ] Tap "Generar plan con IA" funciona
- [ ] Quiz se carga (10 preguntas)
- [ ] Puede responder cada pregunta
- [ ] Progress indicator actualiza
- [ ] "Submit" funciona
- [ ] Resultado se muestra correctamente
- [ ] **Score detectado** (Beginner/Intermediate/Advanced)

**Evento GA4 esperado:** `calibration_complete`

### 3. Paywall (Post-Calibration)
- [ ] **Paywall modal aparece** después del quiz
- [ ] Título: "Desbloquear plan completo"
- [ ] Benefits list visible (4 items)
- [ ] CTA: "Empezar prueba gratis (7 días)"
- [ ] Botón "Tal vez después" funciona
- [ ] Fine print visible

**Evento GA4 esperado:** `paywall_viewed` (placement: 'post_calibration')

**Acción:** Tap "Tal vez después" (para validar flujo sin trial)

### 4. Plan Generado (Module Outline)
- [ ] Navega a outline screen
- [ ] Snackbar: "Plan creado correctamente"
- [ ] **6 módulos visibles** (M1-M6)
- [ ] M1 tiene título "Fundamentos SELECT" o similar
- [ ] **M1 NO tiene candado** (lock icon ausente)
- [ ] **M2-M6 tienen candado** (lock icon visible)
- [ ] Expandir M1 muestra lecciones
- [ ] Lecciones de M1 NO tienen candado

### 5. M1 - Módulo Gratis (Funcional)
- [ ] Tap en una lección de M1
- [ ] **NO aparece paywall**
- [ ] Navega a lesson detail screen
- [ ] Content se muestra correctamente
- [ ] Markdown renderiza bien
- [ ] Back button funciona

**Evento GA4 esperado:** `module_started` (module_id: 'M1')

### 6. M2-M6 - Módulos Bloqueados
- [ ] Expandir M2
- [ ] Lecciones de M2 tienen candado
- [ ] Tap en lección de M2
- [ ] **Paywall aparece**
- [ ] Título: "Continuar con Premium"
- [ ] Subtitle correcto

**Evento GA4 esperado:** `paywall_viewed` (placement: 'module_locked')

**Acción:** Tap "Empezar prueba gratis (7 días)"

### 7. Trial Start
- [ ] Paywall se cierra
- [ ] **Lock icons desaparecen** de M2-M6
- [ ] Refresh UI visible (setState funcionó)
- [ ] Tap en lección de M2 ahora funciona
- [ ] **NO aparece paywall**
- [ ] Navega a lesson detail

**Evento GA4 esperado:** `trial_start` (NO implementado todavía - DÍA 4)

### 8. Progreso guardado
- [ ] Completar una lección
- [ ] Back a outline
- [ ] Progress indicator actualiza
- [ ] Close app completamente
- [ ] Reabrir app
- [ ] Navegar al mismo curso
- [ ] **Progreso persiste**

---

## 🔥 FLUJO ALTERNATIVO (Edge Cases)

### 9. Sin Internet
- [ ] Desactivar internet
- [ ] Intentar generar plan
- [ ] Error message claro
- [ ] App NO crashea
- [ ] Reactivar internet
- [ ] Retry funciona

### 10. Back Button Stress Test
- [ ] En calibración: Back button funciona
- [ ] En paywall: Back button NO disponible (barrierDismissible: false)
- [ ] En outline: Back button funciona
- [ ] En lesson: Back button funciona
- [ ] No hay navigation stack corruption

### 11. Trial Expiration (Manual)
- [ ] Iniciar trial
- [ ] Abrir DevTools / Flutter Inspector
- [ ] Modificar `_trialStartedAt` a hace 8 días (mock)
- [ ] Restart app
- [ ] **Locks reaparecen** en M2-M6
- [ ] Paywall funciona de nuevo

---

## 📊 GA4 EVENTOS CRÍTICOS

**Eventos que DEBEN estar llegando a GA4:**

```
✅ paywall_viewed (placement: 'post_calibration')
✅ paywall_viewed (placement: 'module_locked')
✅ module_started (module_id: 'M1', topic: 'SQL')
✅ module_completed (si se completa M1)
⚠️ calibration_start (verificar si existe)
⚠️ calibration_complete (verificar si existe)
⚠️ trial_start (NO implementado - agregar en DÍA 4)
```

**Cómo validar:**
1. Abrir Firebase Console → Analytics → DebugView
2. Ejecutar flujo en emulador
3. Verificar que eventos aparezcan en real-time
4. Validar properties: `placement`, `module_id`, `topic`

---

## ❌ CRITERIOS DE FALLO

**Bloquea lanzamiento:**
- ❌ App crashea en cualquier paso
- ❌ Calibración no completa
- ❌ Paywall no aparece
- ❌ M1 muestra paywall (DEBE ser gratis)
- ❌ Trial no desbloquea M2-M6
- ❌ Progreso no persiste

**No bloquea lanzamiento (fix en DÍA 5):**
- ⚠️ Animaciones no smooth
- ⚠️ Loading states faltantes
- ⚠️ Algunos eventos GA4 faltantes
- ⚠️ UI no perfecta

---

## ✅ CRITERIO DE ÉXITO MVP

**Mínimo aceptable:**
- ✅ 10/11 checks del Happy Path pasando
- ✅ 0 crashes en flujo principal
- ✅ M1 funciona sin premium
- ✅ Trial desbloquea contenido
- ✅ 3 eventos GA4 core llegando

**Ideal:**
- ✅ 15/15 checks totales pasando
- ✅ Edge cases cubiertos
- ✅ Todos los eventos GA4 funcionando

---

## 📝 REPORTE DE BUGS

**Template para reportar:**
```
## Bug: [Título corto]

**Severity:** [Blocker / High / Medium / Low]

**Steps to reproduce:**
1.
2.
3.

**Expected:**
[Qué debería pasar]

**Actual:**
[Qué está pasando]

**Screenshots/Logs:**
[Adjuntar si es posible]

**Device:**
- OS: [Android 13 / iOS 16]
- Device: [Pixel 5 / iPhone 14]
- App version: [1.0.0+1]
```

---

**Última actualización:** 2025-11-04
**Próxima revisión:** DÍA 5 (antes de lanzamiento)
