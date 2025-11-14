# Estado actual del flujo adaptativo y problema abierto

## ¿Dónde estamos?
- El flujo genera un quiz de calibración usando OpenAI (GPT-4o) y lo valida contra `CalibrationQuizSchema`. El cliente Flutter aumenta el timeout a 45s y el home se encarga de cerrar la sesión y abrir `AdaptiveJourneyScreen`.
- `AdaptiveJourneyScreen` escucha la colección `users/{uid}/adaptiveState/summary`, genera módulos on-demand y permite boosters/checkpoints con reglas 70% + cobertura, mientras el streak y los módulos premium se actualizan.
- El backend documenta cada llamada en `openai_usage` y guarda el cache en `users/{uid}/adaptiveCheckpoints` y `ai_cache`.

## Error investigado
1. El log lleno en `downloaded-logs-20251112-204051.json` muestra "Failed to generate calibration quiz" causado por un error de Firestore: "`moduleNumber` is undefined". Ese error proviene de `logOpenAiUsage` porque intentamos escribir un campo `undefined`, lo que hace que el `try/catch` de `placementQuizStart` marque la generación como fallida y sirva el fallback `curated-fallback`.
2. El efecto visible: cualquier topic nuevo (italiano, inglés B1) cae automáticamente en `source: curated-fallback`, generando preguntas reutilizadas del banco SQL y engañando a la app con falsas suposiciones de fallos de IA.
3. El problema es crítico porque el user paga tokens y no recibe el contenido adaptativo; además, cada fallback aumenta el uso de `ai_cache` y vuelve a servir preguntas viejas.

## Pasos siguientes (2e2 forense)
- Sanear `logOpenAiUsage` eliminando claves `undefined` y asegurando que todo campo requerido (moduleNumber, band, topic, model) esté presente antes de escribir.
- Invalidar la entrada `ai_cache` asociada al topic + idioma cuando detectamos que `placementQuizStart` se sirvió desde el fallback actual.
- Mejorar los logs de Cloud Run para distinguir correcciones de validación de Firestore vs. fallos reales de la API y documentar el comportamiento en la carpeta `docs/audit`.
- Verificar que los cambios en Flutter (timeout 45s, eliminación del botón del streak) no dependen del fallback y que la UI muestra correctamente el nuevo quiz adaptativo.
