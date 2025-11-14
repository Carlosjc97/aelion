agent:
  name: Content/Pedagogy + Docs
  mission: Publicar “documentos maestros” y contenido base de SQL

tasks:
  - crear_documentos_maestros:
      ruta: /docs
      archivos:
        - PROMPT_GENERATOR.md
        - MODULE_STRUCTURE.md
        - MOCK_EXAM.json
        - PDF_CHEATSHEET.md
        - MASTER_EXECUTION_PLAN.md
  - escribir_banco_preguntas:
      cantidad: 100
      idioma: ES
      formato: aproximado (a,b,c)
      distribución:
        - multiple_choice: 80%
        - verdadero_falso: 10%
        - multiple_select: 10%
      etiquetas: por_módulo
      destino: Storage
  - crear_contenido_sql:
      plantillas_lección: [2_intro, 3_contenido, 2_cierre]
      lecciones_sql: 25
      mock_exam_items: 5–10
      cheat_sheet_paginas: 1–2
  - actualizar_auditorías:
      archivos:
        - AUDIT_DOCUMENTACION.md
        - AUDIT_SUMMARY.md
      estado: created

outputs:
  - /docs/* completos
  - /content/tracks/sql-marketing/* en Storage
