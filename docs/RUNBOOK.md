# Runbook de Validación

Este documento contiene una checklist para validar la correcta implementación de las features de autenticación y la migración de `/outline` a Firebase Functions.

## Checklist de Validación Post-Merge

| Área              | Criterio                                                    | Cómo verificar                                                              | Estado | Evidencia (link, captura, etc.) |
| ----------------- | ----------------------------------------------------------- | --------------------------------------------------------------------------- | ------ | ------------------------------- |
| **Auth (Google)** | `firebase_options.dart` presente o documentado si falta     | `git ls-files lib/firebase_options.dart` o ver sección en `README.md`.      | ☐      |                                 |
| **Auth (Google)** | `google-services.json` con `oauth_client` (client_type=3)   | Abrir `android/app/google-services.json` y buscar el bloque `oauth_client`. | ☐      |                                 |
| **Emuladores**    | Auth/Functions/Firestore corren en local                    | `firebase emulators:start` no muestra errores.                              | ☐      |                                 |
| **Functions**     | `outline` desplegada o probada en emulador                  | `firebase emulators:start --only functions` o `firebase deploy --only functions:outline`. | ☐      |                                 |
| **Cache/TTL**     | `cache_outline` crea docs con `expiresAt`                   | Ver en la consola de Firestore la colección `cache_outline`.                | ☐      |                                 |
| **Base URL**      | `API_BASE_URL` se usa (no `localhost` en release)           | `grep "localhost" en el código de la app en modo release`.                  | ☐      |                                 |
| **Skeletons**     | Skeletons visibles durante la carga del outline             | Grabar o capturar la pantalla de `ModuleOutlineView` al cargar.             | ☐      |                                 |
| **Fallback**      | Banner/Chip “Modo demo” ante contenido cacheado             | Verificar que el banner aparece cuando la función devuelve `source: 'cache'`. | ☐      |                                 |
| **Accesibilidad** | Targets de botones ≥ 48dp                                   | Revisar el `minSize` en `A11yButton`.                                       | ☑      | `lib/widgets/a11y_button.dart`  |
| **Accesibilidad** | Semantics en botón de Google                                | `flutter test test/a11y_semantics_test.dart` pasa.                          | ☑      | `test/a11y_semantics_test.dart` |
| **Accesibilidad** | Text scaling 200% sin overflow                              | `flutter test test/a11y_textscale_test.dart` pasa.                          | ☑      | `test/a11y_textscale_test.dart` |
| **Observabilidad**| Evento `outline_response` con `source` y `latency_ms`       | Consola de Firebase Analytics o Logs.                                       | ☐      |                                 |
| **CI**            | `flutter analyze` y `flutter test` en verde                 | Logs del job de CI/CD.                                                      | ☐      |                                 |
| **Seguridad**     | `gitleaks` sin hallazgos                                    | Salida del comando `gitleaks detect`.                                       | ☐      |                                 |