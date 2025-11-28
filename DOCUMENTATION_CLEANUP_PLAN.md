# Plan de Limpieza de Documentación - Edaptia

> **Fecha:** 18 Noviembre 2025
> **Objetivo:** Reducir duplicación y mantener docs actualizados
> **Estado:** PROPUESTA (Pendiente de aprobación)

---

## RESUMEN EJECUTIVO

**Problema:**
- 43+ archivos .md en el proyecto
- Información duplicada entre múltiples archivos
- Consumo innecesario de tokens en sesiones de IA
- Confusión sobre qué archivo leer para obtener contexto actual

**Solución:**
- **CONTEXT_V2.md** como documento maestro único
- Archivar archivos obsoletos pero históricos
- Eliminar archivos totalmente redundantes
- Establecer reglas claras de mantenimiento

**Resultado esperado:**
- 43 archivos → 15 archivos activos (-65%)
- Reducción de ~70% en tokens consumidos al leer contexto
- Fuente única de verdad para estado del proyecto

---

## ARCHIVOS A MANTENER (15 archivos)

### Core Documentation (SIEMPRE actualizar)

1. **CONTEXT_V2.md** ⭐ NUEVO - Documento maestro
   - **Por qué:** Reemplaza 4 archivos, fuente única de verdad
   - **Actualizar cuando:** Cualquier cambio significativo en arquitectura, API, o decisiones técnicas
   - **Responsable:** Claude Code + desarrolladores

2. **README.md**
   - **Por qué:** Overview público del proyecto, primera impresión
   - **Actualizar cuando:** Cambios en stack, features principales, o instrucciones de setup
   - **Responsable:** Team lead

3. **CONTRIBUTING.md**
   - **Por qué:** Guía de contribución, flujo de trabajo
   - **Actualizar cuando:** Cambios en proceso de desarrollo, CI/CD, o standards
   - **Responsable:** Team lead

### Technical Documentation (Actualizar según cambios)

4. **docs/ROADMAP.md**
   - **Por qué:** Plan de desarrollo, prioridades claras
   - **Actualizar cuando:** Completar fases, cambiar prioridades
   - **Responsable:** Product Manager + Claude Code

5. **docs/ADAPTIVE_SEQUENTIAL_ARCHITECTURE.md**
   - **Por qué:** Arquitectura técnica detallada, referencia para developers
   - **Actualizar cuando:** Cambios en flujo de generación o endpoints
   - **Responsable:** Backend developers

6. **docs/EDAPTIA_SUMMARY.md**
   - **Por qué:** Resumen técnico completo, visión de alto nivel
   - **Actualizar cuando:** Cambios en stack, arquitectura, o métricas
   - **Responsable:** Tech lead

### Operational Guides (Actualizar según procesos)

7. **docs/DEPLOYMENT_GUIDE.md**
   - **Por qué:** Procedimientos de deployment, crucial para producción
   - **Actualizar cuando:** Cambios en proceso de deploy o configuración
   - **Responsable:** DevOps/Backend

8. **docs/RUNBOOK.md**
   - **Por qué:** Troubleshooting, procedimientos operacionales
   - **Actualizar cuando:** Nuevos problemas comunes o soluciones
   - **Responsable:** Todos los developers

9. **docs/SMOKE_TEST_CHECKLIST.md**
   - **Por qué:** Checklist de testing manual antes de releases
   - **Actualizar cuando:** Nuevas features que requieren testing manual
   - **Responsable:** QA/Testing lead

### Deployment Specific (Actualizar cuando cambien servicios)

10. **docs/PLAYSTORE_GUIDE.md**
    - **Por qué:** Deploy a Google Play, proceso específico
    - **Actualizar cuando:** Cambios en proceso de publicación Android
    - **Responsable:** Mobile lead

11. **docs/TESTFLIGHT_GUIDE.md**
    - **Por qué:** Deploy a TestFlight, proceso específico iOS
    - **Actualizar cuando:** Cambios en proceso de publicación iOS
    - **Responsable:** Mobile lead

12. **docs/NAMECHEAP_DEPLOYMENT.md**
    - **Por qué:** Deploy web, configuración específica
    - **Actualizar cuando:** Cambios en hosting o DNS
    - **Responsable:** Frontend/DevOps

13. **docs/GA4_DASHBOARD_CONFIG.md**
    - **Por qué:** Configuración de analytics, métricas importantes
    - **Actualizar cuando:** Nuevos eventos o dashboards
    - **Responsable:** Product Manager

### AI Prompts & Reference (Actualizar cuando cambien workflows)

14. **docs/PROMPT_CLAUDE_CONTINUATION.md**
    - **Por qué:** Prompt para retomar proyecto en nueva sesión
    - **Actualizar cuando:** Cambios en workflow de Claude Code
    - **Responsable:** Claude Code (auto-actualización)

15. **docs/PROMPT_100_PREGUNTAS_SQL.md**
    - **Por qué:** Banco de preguntas fallback, referencia para contenido curado
    - **Actualizar cuando:** Cambios en formato de preguntas o dominios
    - **Responsable:** Content team

---

## ARCHIVOS A ARCHIVAR (Obsoletos pero históricos)

**Destino:** `docs/archive/deprecated/`

**Razón:** Duplican información que ahora está en CONTEXT_V2.md, pero tienen valor histórico

### 1. CONTEXTO_SESION_NUEVA.md
```bash
# Comando:
mkdir -p docs/archive/deprecated
git mv CONTEXTO_SESION_NUEVA.md docs/archive/deprecated/

# Razón:
# - 790 líneas duplicadas en CONTEXT_V2.md
# - Fecha: 15 Nov 2025 (3 días obsoleto)
# - Valor histórico: Muestra estado pre-consolidación
```

### 2. IMPLEMENTACION_COMPLETADA_15NOV.md
```bash
git mv IMPLEMENTACION_COMPLETADA_15NOV.md docs/archive/deprecated/

# Razón:
# - Info de implementación ya en CONTEXT_V2.md sección "Estado Actual"
# - Fecha: 15 Nov 2025
# - Valor histórico: Muestra qué se completó ese día
```

### 3. RESUMEN_PARA_USUARIO.md
```bash
git mv RESUMEN_PARA_USUARIO.md docs/archive/deprecated/

# Razón:
# - Info de próximos pasos ya en CONTEXT_V2.md
# - Fecha: 15 Nov 2025
# - Valor histórico: Muestra plan original post-implementación
```

### 4. HANDOFF_NEXT_SESSION.md
```bash
git mv HANDOFF_NEXT_SESSION.md docs/archive/deprecated/

# Razón:
# - Info de handoff ya en CONTEXT_V2.md sección "Flujo de Trabajo"
# - Fecha: 3 Enero 2025 (contexto diferente: deployment bloqueado)
# - Valor histórico: Muestra estado cuando gcloud estaba corrupto
```

### 5. docs/Context_edaptia.md (v1)
```bash
git mv docs/Context_edaptia.md docs/archive/deprecated/

# Razón:
# - Reemplazado por Context_edaptia_v2.md
# - Valor histórico: Muestra visión inicial de producto
```

### 6. docs/ESTADO_FINAL_PROYECTO.md
```bash
git mv docs/ESTADO_FINAL_PROYECTO.md docs/archive/deprecated/

# Razón:
# - Score 9.0/10 actualizado en CONTEXT_V2.md
# - Fecha: 9 Nov 2025 (9 días obsoleto)
# - Valor histórico: Muestra estado cuando se completó E2E testing
```

**Ahorro estimado:** ~3,500 líneas de documentación duplicada archivadas

---

## ARCHIVOS A ELIMINAR (Totalmente redundantes)

**Razón:** No tienen valor histórico y toda la info está en otros archivos

### 1. BUGFIX_*.md (múltiples archivos)
```bash
# Comando:
git rm BUGFIX_GENERATIVE_SYSTEM.md
git rm BUGFIX_SUMMARY.md
git rm BUGFIXES_APPLIED.md

# Razón:
# - Info temporal de bugs ya resueltos
# - Toda la info está en commits de git
# - No hay valor histórico (bugs específicos de desarrollo)
```

### 2. DEPLOY_STATUS_FINAL.md
```bash
git rm DEPLOY_STATUS_FINAL.md

# Razón:
# - Estado obsoleto de deployment
# - Info actualizada en CONTEXT_V2.md sección "Estado Actual"
# - No hay valor histórico
```

### 3. FIX_429_RATE_LIMIT.md
```bash
git rm FIX_429_RATE_LIMIT.md

# Razón:
# - Fix específico ya implementado
# - Solución documentada en CONTEXT_V2.md sección "Problemas Conocidos"
# - No hay valor histórico
```

### 4. PROMPT_NUEVA_SESION.md
```bash
git rm PROMPT_NUEVA_SESION.md

# Razón:
# - Reemplazado completamente por CONTEXT_V2.md
# - No hay valor histórico (era archivo temporal)
```

### 5. Archivos temporales de sesión
```bash
# Verificar si existen y eliminar:
git rm TEMP_*.md 2>/dev/null || true
git rm SESSION_*.md 2>/dev/null || true
git rm HANDOFF_TEMP_*.md 2>/dev/null || true

# Razón:
# - Archivos de trabajo temporal
# - No deben estar en repo
```

**Ahorro estimado:** ~1,200 líneas de documentación redundante eliminadas

---

## ARCHIVOS YA ARCHIVADOS (No tocar)

Estos archivos ya están en `docs/archive/` y deben permanecer ahí como referencia histórica:

```
docs/archive/
├─ audit/                              # Audits históricos (11 archivos)
│  ├─ AUDIT_ALGORITMO_IRT.md
│  ├─ AUDIT_ARQUITECTURA_CODIGO.md
│  ├─ AUDIT_DEPLOYMENT_DEVOPS.md
│  ├─ AUDIT_DOCUMENTACION.md
│  ├─ AUDIT_FIREBASE.md
│  ├─ AUDIT_PERFORMANCE.md
│  ├─ AUDIT_SEGURIDAD.md
│  ├─ AUDIT_STRIPE_MONETIZACION.md
│  ├─ AUDIT_SUMMARY.md
│  ├─ AUDIT_TESTING_QA.md
│  └─ AUDIT_UX_UI.md
│
├─ old_plans/                          # Planes de launch completados (5 archivos)
│  ├─ Errores_consola.md
│  ├─ LAUNCH_PLAN.md
│  ├─ MVP_LANZAMIENTO_LUNES_FINAL.md
│  ├─ TODO_BACKLOG.md
│  └─ WEB_LAUNCH_STRATEGY.md
│
├─ prompts_old/                        # Prompts desactualizados (4 archivos)
│  ├─ PROMPT_CODEX_NEXT.md
│  ├─ PROMPT_CODEX_REVIEW.md
│  ├─ PROMPT_PARA_IA_EJECUTORA.md
│  └─ PROMPT_RESUMEN_CLAUDE.md
│
└─ IMPLEMENTATION_SUMMARY_DIA*.md      # Summaries históricos (4 archivos)
   ├─ IMPLEMENTATION_SUMMARY_DIA2.md   # Paywall básico
   ├─ IMPLEMENTATION_SUMMARY_DIA3.md   # M1 gratis, M2-6 locked
   ├─ IMPLEMENTATION_SUMMARY_DIA4.md   # Analytics + GA4
   └─ IMPLEMENTATION_SUMMARY_DIA5.md   # Monitoring + alertas
```

**Total archivado:** 24 archivos
**Razón:** Valor histórico importante, muestran evolución del proyecto

---

## NUEVOS ARCHIVOS CREADOS

### 1. CONTEXT_V2.md ⭐
- **Tamaño:** ~550 líneas
- **Reemplaza:** 4 archivos (~2,800 líneas)
- **Ahorro:** ~2,250 líneas (-80%)
- **Beneficio:** Fuente única de verdad, fácil de mantener

### 2. DOCUMENTATION_CLEANUP_PLAN.md (este archivo)
- **Tamaño:** ~400 líneas
- **Propósito:** Documentar proceso de limpieza
- **Beneficio:** Transparencia, justificación de cambios

---

## IMPACTO ESPERADO

### Antes de la limpieza
```
Total archivos .md en proyecto:         43 archivos
Líneas totales de documentación:        ~15,000 líneas
Tokens consumidos al leer contexto:     ~8,000 tokens
Archivos con info duplicada:            12 archivos
Archivos obsoletos sin archivar:        6 archivos
```

### Después de la limpieza
```
Total archivos .md activos:             15 archivos (-65%)
Líneas totales activas:                 ~5,500 líneas (-63%)
Tokens consumidos al leer contexto:     ~2,500 tokens (-69%)
Archivos con info duplicada:            0 archivos
Archivos obsoletos sin archivar:        0 archivos
Archivos archivados (valor histórico):  30 archivos
```

### Beneficios
1. **Reducción de tokens:** 69% menos tokens consumidos en cada sesión de Claude Code
2. **Claridad:** Fuente única de verdad (CONTEXT_V2.md)
3. **Mantenibilidad:** 15 archivos activos vs 43 archivos
4. **Histórico preservado:** 30 archivos archivados con contexto histórico
5. **Menos confusión:** Documentación clara y actualizada

---

## PLAN DE EJECUCIÓN

### Fase 1: Crear nuevo documento maestro ✅ COMPLETADO
```bash
# Ya ejecutado:
# - CONTEXT_V2.md creado
# - DOCUMENTATION_CLEANUP_PLAN.md creado
```

### Fase 2: Archivar archivos obsoletos (5 min)
```bash
# Crear directorio
mkdir -p docs/archive/deprecated

# Mover archivos
git mv CONTEXTO_SESION_NUEVA.md docs/archive/deprecated/
git mv IMPLEMENTACION_COMPLETADA_15NOV.md docs/archive/deprecated/
git mv RESUMEN_PARA_USUARIO.md docs/archive/deprecated/
git mv HANDOFF_NEXT_SESSION.md docs/archive/deprecated/
git mv docs/Context_edaptia.md docs/archive/deprecated/
git mv docs/ESTADO_FINAL_PROYECTO.md docs/archive/deprecated/

# Verificar
git status
```

### Fase 3: Eliminar archivos redundantes (2 min)
```bash
# Eliminar archivos sin valor histórico
git rm BUGFIX_GENERATIVE_SYSTEM.md
git rm BUGFIX_SUMMARY.md
git rm BUGFIXES_APPLIED.md
git rm DEPLOY_STATUS_FINAL.md
git rm FIX_429_RATE_LIMIT.md
git rm PROMPT_NUEVA_SESION.md

# Verificar que no haya otros archivos temporales
ls -la *.md | grep -E "(TEMP|SESSION|HANDOFF_TEMP)"

# Verificar
git status
```

### Fase 4: Actualizar referencias (5 min)
```bash
# Buscar referencias a archivos movidos/eliminados
grep -r "CONTEXTO_SESION_NUEVA" . --exclude-dir=node_modules --exclude-dir=.git
grep -r "IMPLEMENTACION_COMPLETADA_15NOV" . --exclude-dir=node_modules --exclude-dir=.git
grep -r "RESUMEN_PARA_USUARIO" . --exclude-dir=node_modules --exclude-dir=.git

# Actualizar referencias para apuntar a CONTEXT_V2.md
# (si encuentras alguna)
```

### Fase 5: Commit (1 min)
```bash
git add -A
git commit -m "docs: consolidate documentation into CONTEXT_V2.md

- Create CONTEXT_V2.md as single source of truth (replaces 4 files)
- Archive 6 obsolete but historical files to docs/archive/deprecated/
- Delete 6 redundant files with no historical value
- Create DOCUMENTATION_CLEANUP_PLAN.md to document process

Impact:
- 43 files → 15 active files (-65%)
- ~15,000 lines → ~5,500 lines (-63%)
- Token usage: -69% when reading context

Files archived:
- CONTEXTO_SESION_NUEVA.md
- IMPLEMENTACION_COMPLETADA_15NOV.md
- RESUMEN_PARA_USUARIO.md
- HANDOFF_NEXT_SESSION.md
- docs/Context_edaptia.md
- docs/ESTADO_FINAL_PROYECTO.md

Files deleted:
- BUGFIX_*.md (3 files)
- DEPLOY_STATUS_FINAL.md
- FIX_429_RATE_LIMIT.md
- PROMPT_NUEVA_SESION.md

New files:
- CONTEXT_V2.md (single source of truth)
- DOCUMENTATION_CLEANUP_PLAN.md (this file)

All historical context preserved in docs/archive/"
```

### Fase 6: Verificación (2 min)
```bash
# Verificar que CONTEXT_V2.md está completo
cat CONTEXT_V2.md | grep -E "Estado Actual|Arquitectura|Problemas Conocidos|Comandos|Archivos Críticos|Próximos Pasos"

# Verificar que archivos archivados están en su lugar
ls -la docs/archive/deprecated/

# Verificar que archivos eliminados ya no existen
ls -la BUGFIX_*.md 2>/dev/null || echo "✅ Archivos eliminados correctamente"

# Verificar que README.md no tiene links rotos
cat README.md | grep -E "\.md" | grep -v "CONTEXT_V2\|README\|CONTRIBUTING"

# Verificar estructura final
tree -L 2 docs/
```

**Tiempo total estimado:** 15 minutos

---

## REGLAS DE MANTENIMIENTO POST-LIMPIEZA

### DO (Hacer siempre)
1. **Actualizar CONTEXT_V2.md** cuando hagas cambios significativos
2. **Verificar duplicación** antes de crear nuevo .md
3. **Archivar** documentos obsoletos en lugar de eliminar (si tienen valor histórico)
4. **Commitear** cambios de documentación junto con código
5. **Referenciar** CONTEXT_V2.md desde otros archivos en lugar de duplicar info

### DON'T (Nunca hacer)
1. **Crear** archivos .md temporales en raíz del proyecto (usar `/tmp` o `.gitignore`)
2. **Duplicar** información entre archivos (usar links: "Ver CONTEXT_V2.md sección X")
3. **Dejar** archivos obsoletos sin archivar o eliminar
4. **Commitear** archivos de sesión temporal (BUGFIX_*, TEMP_*, SESSION_*)
5. **Ignorar** este plan - si necesitas desviarte, actualiza este archivo primero

### MAYBE (Considerar caso por caso)
1. **Crear** nuevo .md si:
   - La información es totalmente nueva (no existe en CONTEXT_V2.md)
   - Es específica de un proceso (ej: PLAYSTORE_GUIDE.md)
   - Tiene audiencia diferente (público vs interno)
2. **Archivar** vs **Eliminar**:
   - Archivar: Si tiene valor histórico (muestra evolución del proyecto)
   - Eliminar: Si es temporal y la info está en commits de git

---

## VALIDACIÓN DEL PLAN

### Checklist antes de ejecutar
- [ ] CONTEXT_V2.md creado y revisado
- [ ] DOCUMENTATION_CLEANUP_PLAN.md creado (este archivo)
- [ ] Lista de archivos a archivar verificada (6 archivos)
- [ ] Lista de archivos a eliminar verificada (6 archivos)
- [ ] Backup de archivos importantes (opcional, están en git)
- [ ] Usuario aprobó el plan de limpieza

### Checklist después de ejecutar
- [ ] CONTEXT_V2.md es el único archivo de contexto en raíz
- [ ] 6 archivos movidos a docs/archive/deprecated/
- [ ] 6 archivos eliminados del repo
- [ ] git status muestra cambios correctos
- [ ] Commit message descriptivo creado
- [ ] Verificación final ejecutada sin errores

---

## APROBACIÓN NECESARIA

**IMPORTANTE:** Este plan es una PROPUESTA. Requiere aprobación del usuario antes de ejecutar.

**Razones para aprobar:**
- Reduce consumo de tokens en 69%
- Elimina confusión de documentación duplicada
- Preserva histórico importante
- Mejora mantenibilidad a largo plazo

**Razones para rechazar (posibles):**
- Usuario quiere mantener archivos temporales por alguna razón
- Usuario prefiere estructura diferente
- Usuario necesita revisar archivos antes de archivar

**Siguiente paso:** Presentar este plan al usuario y esperar aprobación antes de ejecutar Fase 2-6.

---

**Creado por:** Claude Code
**Fecha:** 18 de Noviembre, 2025
**Estado:** PROPUESTA (Pendiente de aprobación)
**Próxima acción:** Esperar aprobación del usuario

