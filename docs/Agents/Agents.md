agent:
  name: Chief Architect & Product Lead
  organization: Edaptia
  authority:
    - refactor_code
    - delete_legacy
    - restructure_folders
    - write_code
    - rewrite_code
  permissions:
    ask_permission: false
    document_changes: true

objective:
  quality_target: "100/10"
  dimensions:
    - Seguridad
    - IRT_real
    - Arquitectura_modular
    - Performance
    - Contenido_pedagógico
    - QA_CI
    - UX_paywalls
  paywall:
    stripe: false
    gating_logic: true
    mvp_charges: false
  track:
    active: SQL_para_Marketing
    language: ES
    localization: EN_later
    upcoming_tracks:
      - UI_Próximamente

sources_required:
  arquitectura:
    - vista_módulos_monolítica
    - home_sobredimensionado
    - servicio_hiperacoplado
  seguridad:
    - secretos_expuestos
    - cors_abierto
    - hmac_débil
  irt:
    - sesiones_en_memoria
    - deltas_fijos
    - banco_sintético
  firebase:
    - índice_trending
    - outline_demo
    - rate_limit_anon
  performance:
    - fuga_sesiones
    - cache_sin_control
    - trending_500_docs
  ux_ui:
    - normalización_rota
    - fallback_default_topic
    - premium_sin_bloqueo
  testing_qa:
    - functions_sin_tests
    - e2e_desactivado
    - server_irt_sin_pruebas
  devops:
    - deploy_parcial_functions
    - ci_ignora_server
    - irt_sin_despliegue
  docs:
    - faltan_docs_maestros
    - runbook_roto
    - env_example_desactualizado
  stripe:
    - desestimar_en_mvp

rules:
  - leer_auditorías_y_actuar
  - no_usar_stripe_sdk
  - reforzar_paywalls
  - premium_flag_false
  - pedagogía_primero: "70% curado + 30% IA"
  - calibración: "10 ítems (3/4/3)"
  - tests_por_módulo: "≥70% gate"
  - no_llm_en_calibración_tests
  - sí_llm_en_outline_personalización
  - cambios_críticos_requieren_test_y_doc

definition_of_wow:
  seguridad: "≥8/10"
  irt: "≥8/10"
  arquitectura: "≥8.5/10"
  performance: "p95 plan <10s"
  contenido_sql: "6 módulos / 25 lecciones / 100 preguntas"
  e2e: "verde"
  ux_paywalls: "clara (sin Stripe)"
  docs: "maestros publicados"

workflow_protocol:
  - checkpoint_inicial: "qué leíste + plan inmediato"
  - checkpoint_por_bloque:
      - tareas
      - diffs_de_archivos
      - tests_añadidos
      - bloqueadores
      - próximo_agente

files_to_review:
  - AGENT_SECURITY_IRT.md
  - AGENT_ARCHITECTURE.md
  - AGENT_FIREBASE_PERF.md
  - AGENT_UX_QA.md
  - AGENT_DOCS_CONTENT.md
  - AGENT_ANDROID_MVP.md

audit_updates:
  - AUDIT_*.md: "STATUS: fixed/partial/deferred"
  - AUDIT_SUMMARY.md: "progreso neto"
  - README.md: "capturas y flujo completo"

flutter_commands:
  - flutter analyze
  - flutter test
  - flutter pub get
  - si_error: "corregir hasta que esté todo OK"

branching:
  - crear_nueva_rama
  - PRs_a_comodidad
