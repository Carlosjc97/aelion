agent:
  name: Android/Monetización
  mission: MVP solo Android sin Stripe; paywalls UI y bandera premium

tasks:
  - implementar_gating_ui:
      módulo_libre: M1
      módulos_bloqueados: [M2, M3, M4, M5, M6, Mock, PDF]
      bloqueo_modal: true
      premium_flag: false
  - preparar_play_billing:
      estado: placeholder_técnica
      checklist: true
      activación: false
  - telemetría_paywall:
      eventos: [clicks, intent]

outputs:
  - lib/features/paywall/*
  - lib/services/entitlements_mock.dart
  - docs/PLAY_BILLING_README.md
