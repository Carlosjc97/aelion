# AUDIT ADAPTIVE FLOW

## Estado actual
- placementQuizStart genera fallback porque openai_usage se rechaza (moduleNumber undefined) y Firestore devuelve error.
- El backend ya valida con CalibrationQuizSchema, pero aún debemos asegurarnos de limpiar metadatos antes de escribir.
- El cache ai_cache vuelve a servir quizzes previos; sin invalidación no confirmamos que el usuario reciba datos nuevos.
- El flujo dependiente de LearnerState, racha y módulos adaptativos sufre si se repiten fallos y se consumen tokens extra.

## Acciones a seguir
1. Saneamiento obligatorio de logOpenAiUsage y revisión de los campos que guarda (moduleNumber, band, etc.).
2. Invalidar manualmente la entrada cacheada cuando placementQuizStart sale por fallback para forzar nueva generación.
3. Mantener logs forenses 2e2 (Cloud Run + Firestore) para distinguir fallos de validación vs. fallos reales.
4. Reportar al equipo que la prioridad es asegurar que el primer quiz adaptativo se genera en vivo sin caer en el fallback.
