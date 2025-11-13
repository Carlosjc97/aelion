/**
 * SQL Marketing Course Templates - Stratified by Level
 *
 * BEGINNER (theta < -0.5): 24 lessons, detailed fundamentals
 * INTERMEDIATE (theta -0.5 to +1.0): 20 lessons, balanced
 * ADVANCED (theta > +1.0): 18 lessons, concise and practical
 */

interface TemplateLesson {
  id: string;
  title: string;
  summary: string;
  objective: string;
  type: "lesson" | "practice" | "workshop" | "exercise";
  durationMinutes: number;
}

interface TemplateModule {
  id: string;
  title: string;
  summary: string;
  lessons: TemplateLesson[];
}

export interface OutlineTemplate {
  slug: string;
  topic: string;
  goal: string;
  language: string;
  estimatedHours: number;
  modules: TemplateModule[];
}

// ============================================================
// BEGINNER TEMPLATE (theta < -0.5)
// 6 modules × 4 lessons = 24 lessons, ~8 hours
// ============================================================

export const SQL_MARKETING_BEGINNER: OutlineTemplate = {
  slug: "sql-marketing-beginner",
  topic: "SQL para Marketing",
  goal: "Domina SQL desde cero para analizar campañas y tomar decisiones basadas en datos",
  language: "es",
  estimatedHours: 8,
  modules: [
    {
      id: "m1-select",
      title: "Fundamentos SELECT",
      summary: "Aprende a consultar datos básicos de tus campañas y clientes",
      lessons: [
        {
          id: "m1l1",
          title: "¿Qué es SQL y por qué importa en marketing?",
          summary: "Descubre casos reales donde SQL resuelve problemas de marketing",
          objective: "Conectar SQL con decisiones del día a día en marketing",
          type: "lesson",
          durationMinutes: 4,
        },
        {
          id: "m1l2",
          title: "Tu primera query: SELECT básico",
          summary: "Extrae datos de una tabla de clientes paso a paso",
          objective: "Ejecutar consultas SELECT simples con confianza",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m1l3",
          title: "Filtrar con WHERE",
          summary: "Encuentra solo los clientes que cumplen condiciones específicas",
          objective: "Aplicar filtros WHERE con operadores básicos",
          type: "practice",
          durationMinutes: 4,
        },
        {
          id: "m1l4",
          title: "Combinar filtros con AND/OR",
          summary: "Segmenta audiencias usando múltiples condiciones",
          objective: "Crear segmentos combinando AND, OR y paréntesis",
          type: "exercise",
          durationMinutes: 5,
        },
      ],
    },
    {
      id: "m2-joins",
      title: "Unir tablas con JOINs",
      summary: "Conecta datos de campañas, clientes y conversiones",
      lessons: [
        {
          id: "m2l1",
          title: "¿Por qué necesitamos JOINs?",
          summary: "Entiende cómo relacionar tablas de customers, orders y campaigns",
          objective: "Visualizar relaciones entre tablas de marketing",
          type: "lesson",
          durationMinutes: 4,
        },
        {
          id: "m2l2",
          title: "INNER JOIN paso a paso",
          summary: "Une clientes con sus pedidos para calcular valor",
          objective: "Ejecutar INNER JOINs entre 2 tablas",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m2l3",
          title: "LEFT JOIN para datos incompletos",
          summary: "Encuentra clientes que NO han comprado aún",
          objective: "Usar LEFT JOIN para detectar gaps en el funnel",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m2l4",
          title: "Múltiples JOINs en una query",
          summary: "Conecta campaigns → leads → customers → orders",
          objective: "Combinar 3+ tablas en una sola consulta",
          type: "exercise",
          durationMinutes: 6,
        },
      ],
    },
    {
      id: "m3-aggregations",
      title: "Agregaciones y KPIs",
      summary: "Calcula métricas clave: totales, promedios, conversiones",
      lessons: [
        {
          id: "m3l1",
          title: "COUNT, SUM y AVG",
          summary: "Cuenta clientes, suma ingresos, promedia ticket",
          objective: "Usar funciones de agregación básicas",
          type: "lesson",
          durationMinutes: 4,
        },
        {
          id: "m3l2",
          title: "GROUP BY para segmentar",
          summary: "Calcula KPIs por campaña, canal o periodo",
          objective: "Agrupar datos y agregar por dimensión",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m3l3",
          title: "HAVING para filtrar grupos",
          summary: "Encuentra campañas con ROI > 200%",
          objective: "Aplicar filtros después de agrupar",
          type: "practice",
          durationMinutes: 4,
        },
        {
          id: "m3l4",
          title: "KPIs de marketing con SQL",
          summary: "Calcula CPL, CPA, LTV y ROI en una query",
          objective: "Automatizar cálculo de métricas clave",
          type: "exercise",
          durationMinutes: 6,
        },
      ],
    },
    {
      id: "m4-functions",
      title: "Funciones útiles",
      summary: "Manipula fechas, textos y formatos para reportes",
      lessons: [
        {
          id: "m4l1",
          title: "Funciones de fecha",
          summary: "Filtra por mes, calcula días desde última compra",
          objective: "Usar DATE, MONTH, DATEDIFF en queries",
          type: "lesson",
          durationMinutes: 4,
        },
        {
          id: "m4l2",
          title: "Funciones de texto",
          summary: "Limpia nombres, extrae dominios de emails",
          objective: "Aplicar CONCAT, UPPER, SUBSTRING",
          type: "practice",
          durationMinutes: 4,
        },
        {
          id: "m4l3",
          title: "CASE para categorizar",
          summary: "Crea segmentos de valor (alto, medio, bajo)",
          objective: "Usar CASE WHEN para crear columnas calculadas",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m4l4",
          title: "Cohorts por fecha de registro",
          summary: "Agrupa usuarios por mes de signup",
          objective: "Combinar fechas + CASE + GROUP BY",
          type: "exercise",
          durationMinutes: 5,
        },
      ],
    },
    {
      id: "m5-subqueries",
      title: "Subconsultas",
      summary: "Queries dentro de queries para análisis complejos",
      lessons: [
        {
          id: "m5l1",
          title: "¿Qué es una subquery?",
          summary: "Entiende cuándo y por qué usar subconsultas",
          objective: "Identificar casos de uso de subqueries",
          type: "lesson",
          durationMinutes: 4,
        },
        {
          id: "m5l2",
          title: "Subquery en WHERE",
          summary: "Filtra clientes con compras > promedio",
          objective: "Usar subquery para calcular threshold dinámico",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m5l3",
          title: "Subquery en FROM",
          summary: "Pre-agrega datos y luego filtra",
          objective: "Crear tablas temporales con subqueries",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m5l4",
          title: "Análisis de retención con subqueries",
          summary: "Calcula % de usuarios que regresan en 30 días",
          objective: "Combinar subqueries para métricas de engagement",
          type: "exercise",
          durationMinutes: 6,
        },
      ],
    },
    {
      id: "m6-window",
      title: "Window Functions",
      summary: "Rankings, running totals y análisis avanzados",
      lessons: [
        {
          id: "m6l1",
          title: "Introducción a Window Functions",
          summary: "Entiende la diferencia con GROUP BY",
          objective: "Visualizar casos de uso de ventanas",
          type: "lesson",
          durationMinutes: 4,
        },
        {
          id: "m6l2",
          title: "ROW_NUMBER y RANK",
          summary: "Rankea productos más vendidos por categoría",
          objective: "Usar funciones de ranking básicas",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m6l3",
          title: "Running totals con SUM OVER",
          summary: "Calcula ingresos acumulados mes a mes",
          objective: "Aplicar ventanas con agregación",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m6l4",
          title: "LAG/LEAD para comparar periodos",
          summary: "Calcula crecimiento vs mes anterior",
          objective: "Usar funciones de offset para análisis temporal",
          type: "exercise",
          durationMinutes: 6,
        },
      ],
    },
  ],
};

// ============================================================
// INTERMEDIATE TEMPLATE (theta -0.5 to +1.0)
// 6 modules × 3-4 lessons = 20 lessons, ~7 hours
// ============================================================

export const SQL_MARKETING_INTERMEDIATE: OutlineTemplate = {
  slug: "sql-marketing-intermediate",
  topic: "SQL para Marketing",
  goal: "Optimiza tus análisis de marketing con SQL avanzado y automatización",
  language: "es",
  estimatedHours: 7,
  modules: [
    {
      id: "m1-select",
      title: "SELECT avanzado",
      summary: "Queries eficientes y optimización de consultas",
      lessons: [
        {
          id: "m1l1",
          title: "Query optimization con EXPLAIN",
          summary: "Analiza planes de ejecución y mejora performance",
          objective: "Interpretar EXPLAIN y optimizar queries",
          type: "lesson",
          durationMinutes: 4,
        },
        {
          id: "m1l2",
          title: "CTEs para queries legibles",
          summary: "Estructura consultas complejas con WITH",
          objective: "Refactorizar queries usando Common Table Expressions",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m1l3",
          title: "Índices y performance",
          summary: "Entiende cómo los índices aceleran tus queries",
          objective: "Identificar oportunidades de indexación",
          type: "lesson",
          durationMinutes: 4,
        },
      ],
    },
    {
      id: "m2-joins",
      title: "JOINs complejos",
      summary: "Self-joins, cross-joins y joins condicionales",
      lessons: [
        {
          id: "m2l1",
          title: "Self-joins para jerarquías",
          summary: "Relaciona usuarios con sus referidos",
          objective: "Ejecutar self-joins en árboles de datos",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m2l2",
          title: "Joins con condiciones complejas",
          summary: "Une tablas con rangos de fechas y múltiples keys",
          objective: "Aplicar ON con expresiones avanzadas",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m2l3",
          title: "Attribution modeling con joins",
          summary: "Conecta touchpoints a conversiones",
          objective: "Modelar atribución multi-touch con SQL",
          type: "exercise",
          durationMinutes: 6,
        },
      ],
    },
    {
      id: "m3-aggregations",
      title: "Agregaciones avanzadas",
      summary: "Métricas complejas y análisis dimensional",
      lessons: [
        {
          id: "m3l1",
          title: "Agregaciones condicionales",
          summary: "COUNT/SUM con filtros inline usando CASE",
          objective: "Calcular múltiples métricas en una query",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m3l2",
          title: "Percentiles y distribuciones",
          summary: "Calcula P50, P90, P99 de LTV",
          objective: "Usar funciones de agregación estadística",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m3l3",
          title: "Funnel analysis con SQL",
          summary: "Calcula conversión por etapa del funnel",
          objective: "Modelar funnels con agregaciones",
          type: "exercise",
          durationMinutes: 6,
        },
      ],
    },
    {
      id: "m4-functions",
      title: "Funciones avanzadas",
      summary: "JSON, arrays y funciones analíticas",
      lessons: [
        {
          id: "m4l1",
          title: "Manipulación de JSON",
          summary: "Extrae datos de campos JSON en eventos",
          objective: "Usar JSON_EXTRACT y funciones relacionadas",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m4l2",
          title: "Regex para limpieza de datos",
          summary: "Extrae UTM params de URLs con expresiones regulares",
          objective: "Aplicar REGEXP en queries de marketing",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m4l3",
          title: "Cálculos de cohort retention",
          summary: "Cohorts dinámicos con fechas y ventanas",
          objective: "Automatizar análisis de retención",
          type: "exercise",
          durationMinutes: 6,
        },
      ],
    },
    {
      id: "m5-subqueries",
      title: "Subqueries avanzadas",
      summary: "Queries correlacionadas y optimización",
      lessons: [
        {
          id: "m5l1",
          title: "Correlated subqueries",
          summary: "Compara cada fila con su grupo",
          objective: "Usar subqueries que referencian la query externa",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m5l2",
          title: "EXISTS vs IN",
          summary: "Elige la estrategia correcta para performance",
          objective: "Optimizar subqueries según el caso",
          type: "lesson",
          durationMinutes: 4,
        },
        {
          id: "m5l3",
          title: "User journey analysis",
          summary: "Reconstruye el camino del usuario desde awareness a purchase",
          objective: "Combinar subqueries para análisis de rutas",
          type: "exercise",
          durationMinutes: 6,
        },
      ],
    },
    {
      id: "m6-window",
      title: "Window Functions avanzadas",
      summary: "Análisis temporal y cohorts con ventanas",
      lessons: [
        {
          id: "m6l1",
          title: "PARTITION BY múltiples dimensiones",
          summary: "Rankea por categoría, canal y periodo",
          objective: "Dominar particiones complejas",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m6l2",
          title: "Moving averages",
          summary: "Calcula promedios móviles de 7 y 30 días",
          objective: "Usar ROWS BETWEEN para ventanas deslizantes",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m6l3",
          title: "NTILE para segmentación",
          summary: "Divide usuarios en cuartiles o deciles de valor",
          objective: "Aplicar NTILE para RFM analysis",
          type: "exercise",
          durationMinutes: 6,
        },
      ],
    },
  ],
};

// ============================================================
// ADVANCED TEMPLATE (theta > +1.0)
// 6 modules × 3 lessons = 18 lessons, ~6 hours
// ============================================================

export const SQL_MARKETING_ADVANCED: OutlineTemplate = {
  slug: "sql-marketing-advanced",
  topic: "SQL para Marketing",
  goal: "Arquitecturas de datos y análisis avanzado para marketing data-driven",
  language: "es",
  estimatedHours: 6,
  modules: [
    {
      id: "m1-select",
      title: "Query optimization",
      summary: "Performance tuning y arquitectura de queries",
      lessons: [
        {
          id: "m1l1",
          title: "Execution plans y bottlenecks",
          summary: "Diagnóstica y resuelve queries lentas",
          objective: "Optimizar queries de producción con EXPLAIN ANALYZE",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m1l2",
          title: "Materialized views para dashboards",
          summary: "Pre-agrega datos para reportes en tiempo real",
          objective: "Diseñar estrategia de materialización",
          type: "lesson",
          durationMinutes: 4,
        },
        {
          id: "m1l3",
          title: "Query refactoring con CTEs recursivas",
          summary: "Resuelve problemas jerárquicos complejos",
          objective: "Aplicar recursive CTEs en casos reales",
          type: "exercise",
          durationMinutes: 6,
        },
      ],
    },
    {
      id: "m2-joins",
      title: "Advanced join strategies",
      summary: "Hash joins, merge joins y optimización",
      lessons: [
        {
          id: "m2l1",
          title: "Join algorithms y performance",
          summary: "Entiende nested loop vs hash vs merge",
          objective: "Elegir estrategia de join óptima",
          type: "lesson",
          durationMinutes: 4,
        },
        {
          id: "m2l2",
          title: "Multi-touch attribution modeling",
          summary: "Implementa modelos lineales, time-decay y data-driven",
          objective: "Construir attribution pipeline en SQL",
          type: "exercise",
          durationMinutes: 7,
        },
        {
          id: "m2l3",
          title: "Graph queries en SQL",
          summary: "Analiza redes de referidos y viralidad",
          objective: "Modelar grafos con joins recursivos",
          type: "practice",
          durationMinutes: 6,
        },
      ],
    },
    {
      id: "m3-aggregations",
      title: "Statistical aggregations",
      summary: "Análisis estadístico y modelado predictivo",
      lessons: [
        {
          id: "m3l1",
          title: "Distribuciones y outlier detection",
          summary: "Detecta anomalías en métricas de campaña",
          objective: "Aplicar estadística descriptiva en SQL",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m3l2",
          title: "Cohort retention matrix",
          summary: "Implementa matriz de retención completa",
          objective: "Automatizar análisis de cohortes longitudinales",
          type: "exercise",
          durationMinutes: 7,
        },
        {
          id: "m3l3",
          title: "A/B test analysis en SQL",
          summary: "Calcula statistical significance de experimentos",
          objective: "Validar tests con z-scores y p-values",
          type: "exercise",
          durationMinutes: 6,
        },
      ],
    },
    {
      id: "m4-functions",
      title: "Advanced functions",
      summary: "UDFs, JSON avanzado y procesamiento de texto",
      lessons: [
        {
          id: "m4l1",
          title: "User-defined functions",
          summary: "Crea funciones personalizadas para lógica de negocio",
          objective: "Implementar UDFs para métricas custom",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m4l2",
          title: "Event stream processing",
          summary: "Procesa eventos JSON en tiempo real",
          objective: "Parsear y agregar event streams complejos",
          type: "exercise",
          durationMinutes: 6,
        },
        {
          id: "m4l3",
          title: "NLP básico en SQL",
          summary: "Sentiment analysis y keyword extraction",
          objective: "Aplicar regex y funciones de texto para análisis",
          type: "practice",
          durationMinutes: 5,
        },
      ],
    },
    {
      id: "m5-subqueries",
      title: "Query architecture",
      summary: "CTEs complejas y optimización de subqueries",
      lessons: [
        {
          id: "m5l1",
          title: "Lateral joins",
          summary: "Subqueries correlacionadas optimizadas",
          objective: "Usar LATERAL para queries eficientes",
          type: "practice",
          durationMinutes: 5,
        },
        {
          id: "m5l2",
          title: "Query planning para pipelines",
          summary: "Diseña arquitectura de transformaciones de datos",
          objective: "Estructurar ETL con CTEs y temp tables",
          type: "lesson",
          durationMinutes: 4,
        },
        {
          id: "m5l3",
          title: "Customer 360 view",
          summary: "Construye vista unificada del cliente",
          objective: "Integrar múltiples fuentes en single customer view",
          type: "exercise",
          durationMinutes: 7,
        },
      ],
    },
    {
      id: "m6-window",
      title: "Advanced analytics",
      summary: "Window functions para machine learning features",
      lessons: [
        {
          id: "m6l1",
          title: "Feature engineering con ventanas",
          summary: "Crea features temporales para modelos ML",
          objective: "Generar lag features y rolling statistics",
          type: "practice",
          durationMinutes: 6,
        },
        {
          id: "m6l2",
          title: "Churn prediction features",
          summary: "Calcula engagement decay y recency metrics",
          objective: "Construir feature set para churn modeling",
          type: "exercise",
          durationMinutes: 7,
        },
        {
          id: "m6l3",
          title: "LTV prediction con SQL",
          summary: "Implementa modelo simple de lifetime value",
          objective: "Calcular pLTV usando historical patterns",
          type: "exercise",
          durationMinutes: 6,
        },
      ],
    },
  ],
};

// ============================================================
// TEMPLATE SELECTOR
// ============================================================

export function getSQLMarketingTemplate(band?: string): OutlineTemplate {
  const normalizedBand = (band || "intermediate").toLowerCase();

  if (normalizedBand === "beginner" || normalizedBand === "principiante") {
    return SQL_MARKETING_BEGINNER;
  }

  if (normalizedBand === "advanced" || normalizedBand === "senior" || normalizedBand === "avanzado") {
    return SQL_MARKETING_ADVANCED;
  }

  // Default: intermediate
  return SQL_MARKETING_INTERMEDIATE;
}
