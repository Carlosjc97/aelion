# CONTEXT Edaptia (versión actualizada - Enero 2025)

## Qué es

Edaptia es tu **tutor IA personalizado** que genera contenido educativo adaptado a tu nivel en tiempo real. En lugar de cursos eternos y genéricos, obtienes un **plan dinámico de 4-12 módulos** con lecciones de 3-7 minutos que se ajustan según tu desempeño. La calibración inicial (10 preguntas, ~3 min) nos ubica para generar el camino correcto.

## Para quién (ICP)

Profesionales y equipos que necesitan resultados rápidos en:

* **Tecnología** (p. ej., SQL, Python, .NET)
* **Negocio/Marketing** (p. ej., analítica, growth)
* **Idiomas profesionales** (p. ej., inglés B1-B2)

Enfoque **bilingüe (ES/EN)** con ejemplos globales y multiculturales para despertar curiosidad.

## Problemas que resolvemos

* Falta de tiempo y cursos largos que nunca se terminan
* Contenido genérico que no se adapta al nivel
* "Parálisis por teoría": mucho saber, poco hacer
* Incertidumbre de si realmente estás progresando

## Propuesta de valor

* **Avanzas desde el día 1** con un plan generado para ti
* **Aprendes a tu ritmo** - el contenido se ajusta a tu progreso
* **Sin paja** - solo lo que necesitas, cuando lo necesitas
* **Transparente** - siempre ves tu progreso y el siguiente paso
* **Global** - ejemplos curiosos de todo el mundo (startups islandesas, equipos en Singapur, cooperativas en Kenia)

## Cómo funciona (flujo MVP actual)

1. **Home** → botón "Generar mi plan con IA"
2. **Calibración corta** (10 preguntas, sin nota visible, ~2-3 min). Generada en vivo con OpenAI + cache
3. **Plan adaptado** a tu nivel: 4-12 módulos dinámicos de 25-45 min cada uno; **M1 gratis**
4. **Módulos adaptativos** con 8-20 lecciones cada uno, generadas on-demand según tu progreso
5. **Checkpoints** (quiz de 5-10 preguntas) después de cada módulo con umbral 70% para avanzar
6. **Boosters remediales** si no pasas checkpoint (máximo 3 intentos por módulo)
7. **Paywall claro**: M1 gratis, resto premium con trial 7 días
8. **Streak diario** con check-in y badges motivacionales

## Qué incluye Premium (trial 7 días → $9/mes)

### Gratis (siempre):
- Calibración completa con IA
- Módulo 1 completo (M1)
- Ver plan sugerido completo
- Módulos 2+ bloqueados

### Premium:
- Plan completo desbloqueado (4-12 módulos adaptativos)
- Checkpoints y boosters ilimitados
- Guardado de progreso automático
- Streak diario con recordatorios
- Contenido generado on-demand personalizado
- Soporte prioritario

**Valor percibido:** "Menos que un café al día, contenido 100% personalizado a tu nivel y objetivos"

## Stack técnico

* **App**: Flutter (iOS + Android + Web)
* **Backend**: Firebase (Auth, Firestore, Functions, Storage)
* **IA**: OpenAI GPT-4o con structured outputs + cache agresivo
* **Mensajes**: FCM push + SendGrid/Postmark
* **Pago**: RevenueCat + Stripe

## Arquitectura adaptativa (clave de Edaptia)

### LearnerState
Estado del alumno en Firestore: `users/{uid}/adaptiveState/summary`
- `level_band`: "basic" | "intermediate" | "advanced"
- `skill_mastery`: Record<string, number> (0-1, tipo ELO simple)
- `history`: { passedModules, failedModules, commonErrors }
- `target`: objetivo del usuario (string)

### Generación adaptativa
1. **adaptivePlanDraft**: Genera bosquejo inicial de 4-12 módulos basado en calibración
2. **adaptiveModuleGenerate**: Genera M1 gratis, resto on-demand (8-20 lecciones c/u)
3. **adaptiveCheckpointQuiz**: Genera quiz de checkpoint (5-10 preguntas) para validar módulo
4. **adaptiveBooster**: Genera módulo remedial (1-2 lecciones) si fallas checkpoint (max 3 intentos)

### Cache inteligente
- Quiz de calibración: 7 días TTL
- Módulos: 14 días TTL
- Invalidación automática si cae en fallback

### Fallback curado
Si OpenAI falla, usamos banco de preguntas SQL Marketing (100 items) como fallback temporal, invalidando cache para forzar regeneración en próximo intento.

## Principios de producto (no negociables)

1. **No examinamos**, ubicamos - La calibración es para nosotros, no para juzgarte
2. Siempre **muestra progreso** y el **siguiente paso** claro
3. **Primer módulo gratis** visible antes de pedir pago (demuestra valor primero)
4. **Accesible**: foco visible, objetivos táctiles ≥44px, contraste suficiente (WCAG AA)
5. **Privado y seguro**: la corrección vive en servidor; no filtramos respuestas correctas al cliente
6. **Rápido por diseño**: 500 ms skeleton, p95 < 4s para plan completo, timeout 60s para operaciones IA

## Métricas de éxito

### Conversión:
* **Trial start rate ≥ 6%** (de quienes completan calibración)
* **Trial → Pago ≥ 45%** (realista para EdTech de calidad)
* **CAC orgánico < $5**

### Retention:
* **D7 ≥ 12%** (usuarios activos después de 7 días)
* **D30 ≥ 25%** (usuarios activos después de 30 días)
* **Completion rate ≥ 40%** (completan el plan completo)

### Performance:
* **p95 plan_rendered < 4s** (velocidad percibida)
* **Abandono calibration → plan < 8%**
* **Crash-free rate ≥ 99.5%**

## Diferenciales frente a cursos tradicionales

* **Micro-aprendizaje adaptativo** (no teoría infinita)
* **Primero utilidad, luego profundidad**: resolvemos la intención real del usuario
* **Bilingüe nativo** (ES/EN) con ejemplos globales y curiosos
* **Tiempo respetado**: todo cabe en bloques de 3-7 min
* **Validación constante**: sabes exactamente dónde estás parado
* **Generado on-demand**: no cursos pre-hechos, sino contenido personalizado 100%

## Privacidad y confianza

* La calibración solo diagnostica nivel, no juzga
* Guardamos progreso para reanudar donde ibas
* No compartimos respuestas correctas del banco en el dispositivo
* Cumplimos GDPR/CCPA básico (borrado, exportación)
* Logs sanitizados (sin PII, solo userId hasheado + métricas)

## Estado actual (Enero 2025)

### ✅ Completado:
- Calibración adaptativa con OpenAI GPT-4o + fallback
- Plan draft dinámico (4-12 módulos)
- Generación de módulos on-demand
- Checkpoints con umbral 70%
- Boosters remediales (límite 3 intentos)
- Streak diario con Firestore
- Paywall M1 gratis + trial 7 días
- Cache inteligente con invalidación
- Timeout aumentado a 60s para plan draft
- Ejemplos globales en prompts

### 🚧 En progreso:
- Testing E2E completo (Italiano, Inglés A1)
- Deploy a producción
- Landing page optimizada

### ⏳ Próximos pasos:
- Certificados al completar
- Chat tutor IA multi-turno
- Modo offline parcial
- Más tracks (Python, Growth Marketing, etc.)

---

**Última actualización:** 2025-01-13
**Versión:** 3.0 (Post-audit fixes + prompts globales)
**Próxima revisión:** Post-lanzamiento MVP
