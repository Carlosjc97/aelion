# PROMPT: Generar 100 Preguntas SQL para Marketing

> **Usar con:** ChatGPT-4, Claude Opus, o cualquier LLM con conocimiento técnico profundo
> **Objetivo:** Banco completo de preguntas SQL calibradas para track "SQL para Marketing"

---

## 📋 INSTRUCCIONES PARA LA IA

Genera un banco de **100 preguntas de SQL** en formato JSON para una app de micro-aprendizaje llamada **Edaptia**. Estas preguntas serán usadas por un **motor IRT adaptativo** que ajusta la dificultad según el desempeño del usuario.

---

## 🎯 CONTEXTO DEL PRODUCTO

**Quién lo usa:**
- **Marketing Analysts** que necesitan aprender SQL para analizar datos de campañas
- Pueden hacer Excel pero necesitan queries para BigQuery/Snowflake
- Nivel target: Básico → Intermedio (NOT senior developers)

**Propuesta de valor:**
- Módulos de 3-4 minutos
- Ejemplos LATAM (Mercado Libre, Rappi, Kavak, Platzi, etc.)
- Sin jerga innecesaria, tono cercano
- Progreso visible y accionable

---

## 📚 ESTRUCTURA DE 6 MÓDULOS

Distribuye las 100 preguntas en estos 6 módulos:

### **M1: Fundamentos SELECT (20 preguntas)**
- SELECT, FROM, WHERE básico
- Operadores de comparación (=, >, <, BETWEEN, IN)
- Filtros simples con AND/OR
- LIMIT y ORDER BY
- **Contexto:** Consultas básicas de campañas de email marketing

### **M2: JOINs y Relaciones (18 preguntas)**
- INNER JOIN (principal foco)
- LEFT JOIN
- RIGHT JOIN (mencionar, no profundizar)
- Casos de uso: unir tablas de usuarios + transacciones
- **Contexto:** Análisis de conversión de embudos de marketing

### **M3: Agregaciones (18 preguntas)**
- COUNT, SUM, AVG, MAX, MIN
- GROUP BY
- HAVING vs WHERE
- Agregaciones condicionales (COUNT DISTINCT)
- **Contexto:** KPIs de campañas (CTR, CAC, ROI)

### **M4: Funciones y Transformaciones (16 preguntas)**
- DATE functions (DATE_TRUNC, DATE_DIFF, EXTRACT)
- STRING functions (CONCAT, UPPER, LOWER, SUBSTRING)
- CASE WHEN
- COALESCE, NULLIF
- **Contexto:** Limpieza de datos de Google Ads, Facebook Ads

### **M5: Subconsultas (14 preguntas)**
- Subconsultas en WHERE
- Subconsultas en FROM (inline views)
- EXISTS y NOT EXISTS
- **Contexto:** Segmentación avanzada de audiencias

### **M6: Window Functions (14 preguntas)**
- ROW_NUMBER, RANK, DENSE_RANK
- PARTITION BY
- LAG, LEAD
- Running totals (SUM OVER)
- **Contexto:** Análisis de cohortes y retención

---

## 🎲 DISTRIBUCIÓN DE TIPOS DE PREGUNTA

De las 100 preguntas:
- **80 preguntas:** Multiple choice (1 respuesta correcta, 3 incorrectas)
- **10 preguntas:** Verdadero/Falso
- **10 preguntas:** Multiple select (2-3 respuestas correctas)

---

## 📊 PARÁMETROS IRT (a, b, c)

Cada pregunta debe tener parámetros IRT aproximados:

- **a (discriminación):** Qué tan bien diferencia entre niveles
  - Easy: 0.8-1.2
  - Medium: 1.2-1.8
  - Hard: 1.8-2.5

- **b (dificultad):** Nivel de habilidad necesario
  - Easy: -1.5 a -0.5
  - Medium: -0.5 a 0.5
  - Hard: 0.5 a 2.0

- **c (guessing):** Probabilidad de acertar por suerte
  - Multiple choice (4 opciones): 0.25
  - True/False: 0.5
  - Multiple select: 0.15

**Distribución recomendada por módulo:**
- M1: 12 easy, 6 medium, 2 hard
- M2: 8 easy, 7 medium, 3 hard
- M3: 6 easy, 8 medium, 4 hard
- M4: 4 easy, 8 medium, 4 hard
- M5: 3 easy, 7 medium, 4 hard
- M6: 2 easy, 6 medium, 6 hard

---

## 🌎 EJEMPLOS LATAM

Usa contextos y marcas reales de Latinoamérica:

**E-commerce:**
- Mercado Libre, Falabella, Linio

**Delivery/Movilidad:**
- Rappi, DiDi, Kavak

**Fintech:**
- Nubank, Ualá, Clip

**EdTech:**
- Platzi, Crehana, Coursera (audiencia LATAM)

**Retail:**
- Éxito, Cencosud, Liverpool

**Ejemplos de datos:**
- Campañas de email en español
- Monedas: MXN, COP, ARS, CLP, PEN
- Ciudades: CDMX, Bogotá, Buenos Aires, Santiago, Lima

---

## 📝 FORMATO JSON

Genera el JSON con esta estructura exacta:

```json
{
  "metadata": {
    "track": "sql-marketing",
    "version": "1.0",
    "language": "es",
    "total_questions": 100,
    "generated_date": "2025-01-04",
    "author": "AI-generated for Edaptia MVP"
  },
  "questions": [
    {
      "id": "sql-m1-001",
      "module": "M1",
      "module_name": "Fundamentos SELECT",
      "type": "multiple_choice",
      "difficulty": "easy",
      "irt_params": {
        "a": 1.0,
        "b": -1.2,
        "c": 0.25
      },
      "question": "¿Cuál es la sintaxis correcta para seleccionar todas las columnas de una tabla llamada 'campaigns'?",
      "options": [
        "SELECT * FROM campaigns",
        "SELECT ALL FROM campaigns",
        "GET * FROM campaigns",
        "FETCH * FROM campaigns"
      ],
      "correct_answer": 0,
      "explanation": "SELECT * FROM [tabla] es la sintaxis estándar de SQL para seleccionar todas las columnas. El asterisco (*) representa 'todas las columnas'.",
      "context": "Consulta básica de campañas de marketing en Mercado Libre",
      "tags": ["select", "basic", "syntax"]
    },
    {
      "id": "sql-m2-001",
      "module": "M2",
      "module_name": "JOINs y Relaciones",
      "type": "multiple_choice",
      "difficulty": "medium",
      "irt_params": {
        "a": 1.5,
        "b": 0.2,
        "c": 0.25
      },
      "question": "Tienes dos tablas: 'users' (user_id, email) y 'orders' (order_id, user_id, amount). ¿Qué JOIN usarías para obtener TODOS los usuarios, incluso los que NO han comprado?",
      "options": [
        "INNER JOIN",
        "LEFT JOIN",
        "RIGHT JOIN",
        "FULL OUTER JOIN"
      ],
      "correct_answer": 1,
      "explanation": "LEFT JOIN devuelve todos los registros de la tabla izquierda (users), incluso si no hay coincidencias en la tabla derecha (orders). Usuarios sin compras aparecerán con NULL en los campos de orders.",
      "context": "Análisis de conversión de usuarios en Rappi",
      "tags": ["join", "left-join", "null-handling"]
    },
    {
      "id": "sql-m3-001",
      "module": "M3",
      "module_name": "Agregaciones",
      "type": "multiple_choice",
      "difficulty": "medium",
      "irt_params": {
        "a": 1.6,
        "b": 0.5,
        "c": 0.25
      },
      "question": "Quieres calcular el costo promedio de adquisición (CAC) por canal de marketing. Tienes una tabla 'campaigns' con columnas: channel, cost, conversions. ¿Qué query es correcta?",
      "options": [
        "SELECT channel, AVG(cost/conversions) FROM campaigns GROUP BY channel",
        "SELECT channel, SUM(cost)/SUM(conversions) FROM campaigns GROUP BY channel",
        "SELECT channel, cost/conversions FROM campaigns GROUP BY channel",
        "SELECT AVG(cost), AVG(conversions) FROM campaigns GROUP BY channel"
      ],
      "correct_answer": 1,
      "explanation": "El CAC correcto es SUM(cost)/SUM(conversions) para obtener el promedio ponderado. AVG(cost/conversions) daría un promedio incorrecto porque trata cada campaña por igual, independiente de su tamaño.",
      "context": "Cálculo de métricas de performance en Google Ads para Platzi",
      "tags": ["aggregation", "metrics", "group-by", "cac"]
    },
    {
      "id": "sql-m5-001",
      "module": "M5",
      "module_name": "Subconsultas",
      "type": "multiple_choice",
      "difficulty": "hard",
      "irt_params": {
        "a": 2.0,
        "b": 1.2,
        "c": 0.25
      },
      "question": "Necesitas encontrar usuarios que hicieron su primera compra en los últimos 30 días. Tablas: users (user_id, email), orders (order_id, user_id, order_date). ¿Qué query es correcta?",
      "options": [
        "SELECT u.* FROM users u WHERE u.user_id IN (SELECT user_id FROM orders WHERE order_date >= CURRENT_DATE - 30)",
        "SELECT u.* FROM users u JOIN (SELECT user_id, MIN(order_date) as first_order FROM orders GROUP BY user_id) o ON u.user_id = o.user_id WHERE o.first_order >= CURRENT_DATE - 30",
        "SELECT * FROM users WHERE user_id IN (SELECT DISTINCT user_id FROM orders WHERE order_date >= CURRENT_DATE - 30 LIMIT 1)",
        "SELECT u.* FROM users u WHERE EXISTS (SELECT 1 FROM orders WHERE user_id = u.user_id AND order_date >= CURRENT_DATE - 30 LIMIT 1)"
      ],
      "correct_answer": 1,
      "explanation": "La opción correcta usa MIN(order_date) para identificar la PRIMERA compra y luego filtra por fecha. La opción A incluiría usuarios con compras antiguas si también compraron recientemente. La D es similar a A.",
      "context": "Análisis de cohortes de nuevos clientes en Nubank",
      "tags": ["subquery", "date", "first-purchase", "cohort"]
    }
  ]
}
```

---

## ✅ VALIDACIONES

Asegúrate de que:
1. **100 preguntas exactas** (distribuidas según módulos)
2. **IDs únicos** en formato `sql-m[1-6]-[001-020]`
3. **Parámetros IRT realistas** (no todos 1.0)
4. **Opciones incorrectas plausibles** (no obviamente falsas)
5. **Explicaciones educativas** (no solo "porque sí")
6. **Contextos LATAM** en al menos 70% de las preguntas
7. **Tags descriptivos** para futuras búsquedas

---

## 🚀 OUTPUT ESPERADO

Un archivo JSON válido de ~150-200 KB con:
- Metadata completa
- 100 objetos question con todos los campos
- Sin errores de sintaxis JSON
- Listo para importar en `server/assessment.js`

---

## 💡 TIPS PARA CALIDAD

**Preguntas buenas:**
- Basadas en casos reales de trabajo
- Opciones incorrectas que reflejan errores comunes
- Explicaciones que enseñan el "por qué"
- Progresión lógica de dificultad

**Preguntas malas:**
- Trivia sin aplicación práctica
- Opciones incorrectas absurdas
- Explicaciones que solo repiten la respuesta
- Saltos bruscos de dificultad

---

**Genera el JSON completo ahora. ¡Edaptia depende de ti! 🚀**
