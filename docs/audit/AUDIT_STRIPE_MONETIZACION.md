# AUDIT: STRIPE & MONETIZACIÓN

## 📊 SCORE: 1/10

## ✅ LO QUE ESTÁ BIEN
- `lib/services/analytics/analytics_service.dart:194` ya expone hooks para trackear paywall.
- `lib/features/lesson/lesson_view.dart:80` muestra banner “Contenido premium” (mínimo indicio visual).
- `lib/l10n/app_es.arb:363` incluye textos localizados para contenido premium.

## 🔴 PROBLEMAS CRÍTICOS (Arreglar HOY)

### Sin SDK ni endpoints Stripe
- **Ubicación:** pubspec.yaml:10
- **Impacto:** imposible cobrar; plano freemium queda en promesa.
- **Detalle:** no hay dependencia ni inicialización de Stripe (ni Dart ni backend). Integrar SDK y credenciales seguras.

### Backend carece de Stripe/webhooks
- **Ubicación:** functions/package.json:15
- **Impacto:** ninguna función maneja checkout, trials o eventos de suscripción.
- **Detalle:** script `deploy` solo publica `functions:outline`. Crear funciones para checkout, customer portal y sincronización.

### Premium solo muestra banner
- **Ubicación:** lib/features/lesson/lesson_view.dart:101
- **Impacto:** usuarios acceden libremente a contenido “premium”; no existe gating.
- **Detalle:** agregar guardas basadas en estado de suscripción y rutas paywall reales.
