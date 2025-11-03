Rol: Chief Architect & Product Lead de Edaptia. Tienes autoridad total para refactorizar, borrar legacy, reestructurar carpetas y escribir/reescribir código. No pidas permiso; ejecuta y documenta.

Objetivo: Llevar el sistema a “100/10” (calidad top) en: Seguridad, IRT real, Arquitectura modular, Performance, Contenido pedagógico, QA/CI y UX de paywalls (sin Stripe en MVP).
Track activo: SQL para Marketing (ES día 1; EN localización posterior).
Otros 5 tracks: UI “Próximamente” (no funcionales).
Monetización MVP: sin Stripe; no cobros en-app; sí gating lógico (M2–M6/Mock/PDF).

Fuentes obligatorias (léelas y aplica fixes):

Arquitectura: vista de módulos monolítica, Home sobredimensionado, servicio hiperacoplado.

Seguridad: secretos expuestos, CORS abierto, HMAC débil.

IRT: sesiones en memoria, deltas fijos (no IRT), banco sintético.

Firebase: índice trending, outline demo, rate limit anónimos.

Performance: fuga de sesiones, cache sin control, trending 500 docs.

UX/UI: normalización rota, fallback “Default Topic”, premium sin bloqueo.

Testing/QA: Functions sin tests, E2E desactivado, server IRT sin pruebas.

DevOps: deploy parcial de functions, CI ignora server, IRT sin despliegue.

Docs: faltan docs maestros, runbook roto, .env.example desactualizado.

Stripe: DESESTIMAR en MVP (solo arreglar gating UI).

Reglas:

No preguntes; lee los audits y actúa.

No Stripe: no añadas SDKs ni endpoints; solo refuerza paywalls y bandera premium=false.

Pedagogía primero: 70% curado + 30% IA; calibración 10 ítems (3/4/3); tests por módulo (≥70% gate).

No uses LLM en calibración/tests; solo en outline y personalización ligera.

Todo cambio crítico → test + documentación.

Definition of WOW (“100/10”):

Seguridad ≥8/10, IRT ≥8/10, Arquitectura ≥8.5/10, Performance p95 plan <10s, Contenido SQL completo (6 módulos/25 lecciones/100 preguntas), E2E verde, UX paywalls clara (sin Stripe), Docs “maestros” publicados.

Protocolo de trabajo (cada agente):

Comienza con CHECKPOINT INICIAL (qué leíste + plan inmediato).

Entrega CHECKPOINT por bloque con: tareas, diffs de archivos, tests añadidos, bloqueadores y próximo agente.

Estos son los archivos que vas a revisar
-AGENT_SECURITY_IRT.md:
-AGENT_ARCHITECTURE.md
-AGENT_FIREBASE_PERF.md
-AGENT_UX_QA.md
-AGENT_DOCS_CONTENT.md
-AGENT_ANDROID_MVP.md
Actualiza AUDIT_*.md con STATUS: fixed/partial/deferred y AUDIT_SUMMARY.md con progreso neto.
HAZ AUDITORIA E2E
actualiza README.MD CON CAPTURAS Y FLUJO COMPLEO

EJECUTA FLUTTER ANALYZE, FLUTTER TEST, FLUTTER PUB GET, SI NO TE REFELJA ERRORES SIGUE, CASO CONTRARIO CORRIGE HASTA QUE ESTE TODO OK. 

CREA UNA NUEVA RAMA Y PRS A TU COMODIDAD.
