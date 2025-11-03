# AUDIT: UX/UI & FLOWS

## 📊 SCORE: 4/10

## ✅ LO QUE ESTÁ BIEN
- `lib/features/auth/auth_gate.dart:17` maneja estados loading/error antes de mostrar contenido.
- `lib/widgets/skeleton.dart:6` proporciona esqueletos reutilizables para cargas.
- `lib/features/quiz/quiz_screen.dart:96` cubre estados intro, loading, preguntas, resultado y error.

## 🔴 PROBLEMAS CRÍTICOS (Arreglar HOY)

### Normalización rota en recomendaciones
- **Ubicación:** lib/features/home/home_view.dart:181
- **Impacto:** tópicos aparecen con caracteres corruptos (“A�…”) y se deduplican mal.
- **Detalle:** tabla de reemplazos contiene bytes mal codificados. Usar utilidades de acentos (ej. `diacritic`) y pruebas i18n.

### Outline fallback usa “Default Topic”
- **Ubicación:** lib/features/modules/outline/module_outline_view.dart:291
- **Impacto:** usuarios ven un título genérico en vez del tema real cuando el argumento llega vacío.
- **Detalle:** se fuerza `Default Topic`; mostrar error/guided CTA para elegir tema válido.

### Contenido premium sin bloqueo visible
- **Ubicación:** lib/features/lesson/lesson_view.dart:101
- **Impacto:** flujo premium confunde: banner, pero CTA permite completar lección igual.
- **Detalle:** deshabilitar acciones o lanzar paywall dialog hasta que el usuario compre.
