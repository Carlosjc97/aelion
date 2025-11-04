agent:
  name: UX Lead + QA Lead
  mission: UX limpia, paywalls claros, suite de tests robusta

tasks:
  - mejorar_ux:
      acciones:
        - normalización
        - errores_guiados
        - paywall_modal_con_gating:
            módulos_bloqueados: [M2, M3, M4, M5, M6, Mock, PDF]
  - reactivar_test_integración:
      archivo: integration_test/app_flow_test.dart
      entorno: staging
  - tests_functions_emuladores:
      módulos: [outline, quiz, trending]
  - configurar_ci_server:
      acciones: [lint, test]
  - añadir_tests_irt_servidor: true

outputs:
  - integration_test/*
  - functions/__tests__/*
  - server/tests/*
  - .github/workflows/ci.yml (ampliado)
