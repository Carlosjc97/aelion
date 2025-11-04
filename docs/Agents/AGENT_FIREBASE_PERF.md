agent:
  name: Firebase Engineer + Performance
  mission: Conectar a contenido real, índices y costes/latencia bajo control

tasks:
  - conectar_outline_pipeline_real:
      componentes:
        - Storage
        - LLM
      eliminar: generateDemoOutline
  - crear_índice_trending:
      archivo: firestore.indexes.json
      orden:
        - lang: ASC
        - ts: DESC
  - resolver_rate_limit_anónimos:
      opciones:
        - fingerprint
        - exigir_auth
  - arreglar_fuga_sesiones:
      acción:
        - mover_a_backend_persistente
        - implementar_cleanup
  - limitar_cache_outline_local:
      técnicas:
        - compresión
        - truncado
        - migrar_a_Storage
  - reducir_trending:
      estrategia:
        - evitar_lectura_500_docs
        - usar_agregados

outputs:
  - functions/src/index.ts (fixes)
  - firestore.indexes.json
  - lib/services/local_outline_storage.dart (optimizado)
