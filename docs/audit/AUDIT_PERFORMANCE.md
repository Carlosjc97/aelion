# AUDIT: PERFORMANCE & OPTIMIZACIÓN

## 📊 SCORE: 4/10

## ✅ LO QUE ESTÁ BIEN
- `lib/services/local_outline_storage.dart:138` limita historial a 5 elementos para evitar crecimiento indefinido.
- `functions/src/index.ts:1040` recorta trending a 20 resultados.
- `server/assessment.js:455` selecciona preguntas ponderando cobertura por skill para evitar repetir.

## 🔴 PROBLEMAS CRÍTICOS (Arreglar HOY)

### Fuga de sesiones en memoria
- **Ubicación:** server/assessment.js:44
- **Impacto:** memoria crece sin límites; reinicios borran estado.
- **Detalle:** nunca se purgan entradas del `Map`. Implementar cleanup o backend persistente con expiración.

### [fixed] Outline cache en SharedPreferences sin control de tamaño
- **Ubicación:** lib/services/local_outline_storage.dart:118
- **STATUS:** fixed - historial serializado con compresión gzip condicional, sanitizado de campos pesados y retención de 14 días.
- **Detalle:** `local_outline_storage.dart` remueve `rawOutline/debug`, comprime cuando conviene y expurga entradas antiguas; nuevos tests garantizan dedupe y pruning.
### Trending lee 500 docs por request
- **Ubicación:** functions/src/index.ts:990
- **Impacto:** bajo carga eleva costos y latencia; sin agregaciones.
- **Detalle:** considerar jobs programados o agregados precomputados.
