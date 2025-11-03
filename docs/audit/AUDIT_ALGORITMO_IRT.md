# AUDIT: ALGORITMO IRT & CALIBRACIÓN

## 📊 SCORE: 5/10

## ✅ LO QUE ESTÁ BIEN
- `server/assessment.js:23` inicializa un almacén persistente (Firestore) y deja de depender de `Map()` en memoria.
- `server/assessment.js:255` aplica actualización 3PL (gradiente logístico + `ABILITY_UPDATE_STEP`) en lugar de deltas fijos ±0.6.
- `server/assessment.test.js` valida persistencia y ajustes de habilidad (correcto vs incorrecto).

## 🔴 PROBLEMAS CRÍTICOS (Arreglar HOY)

### Banco de ítems sigue siendo sintético
- **Ubicación:** server/assessment.js:830
- **Impacto:** sin 100 preguntas curadas/calibradas el motor sigue siendo ficticio; resultados no representan el dominio SQL.
- **Detalle:** reemplazar `buildQuestionBank` por dataset real con metadata de curación; cargarlo desde JSON/Firestore.

### Parámetros IRT idénticos por dificultad
- **Ubicación:** server/assessment.js:31 (`IRT_PARAMS_BY_DIFFICULTY`)
- **Impacto:** todos los ítems de una misma banda comparten `a/b/c`; no existe discriminación ni guessing real por pregunta.
- **Detalle:** almacenar parámetros por ítem (a, b, c) y persistirlos junto al banco; actualizar creación de preguntas para leerlos dinámicamente.

### Sin recalibración ni validación estadística
- **Ubicación:** pipeline inexistente
- **Impacto:** no hay rutina para recalcular theta/SE con datos reales, detectar ítems problemáticos ni ajustar bandas.
- **Detalle:** diseñar script de recalibración (MLE/EAP), simulaciones batch y métricas de fiabilidad antes de salir a beta pública.
