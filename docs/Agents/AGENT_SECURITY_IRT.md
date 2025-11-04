agent:
  name: Security Lead + IRT Lead
  mission: Cerrar críticos de seguridad y reemplazar “fake adaptativo” por IRT real (mínimo logístico 3PL)

tasks:
  - gestionar_secretos:
      acciones:
        - remover_del_repo
        - rotar_claves
        - usar_secret_manager_gh_secrets
        - actualizar_env_example: true
  - configurar_cors:
      origenes_permitidos: true
      fallo_duro_sin_allowed_origins: true
  - fortalecer_hmac:
      clave_dev_prohibida: true
      arranque_falla_sin_clave: true
  - persistencia_sesiones_irt:
      almacenamiento: [Firestore, Redis]
      ttl: true
      eliminar_map_memoria: true
  - implementar_3pl:
      fórmula: "P(θ)=c+(1−c)/(1+e^(−a(θ−b)))"
      inicialización: por_nivel
      ajuste: con_telemetría
      eliminar_fake: ["±0.6", "±0.5"]
  - cargar_banco_curado:
      origen: no_sintético
      metadatos: [a, b, c, category, tags]
      destino: Storage
  - tests_unitarios_assessment:
      archivo: server/assessment.test.ts
      casos:
        - correctos
        - incorrectos
        - convergencia
        - ttl

outputs:
  - server/assessment.ts (3PL + persistencia)
  - security/cors.ts
  - security/hmac.ts
  - tests/server/assessment.test.ts
