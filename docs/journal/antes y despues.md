# Registro de Cambios: Antes y DespuÃ©s

Este documento registra las modificaciones realizadas en el cÃ³digo fuente para mejorar la funcionalidad y corregir errores. Cada cambio se documenta con el estado del cÃ³digo "Antes" y "DespuÃ©s" de la modificaciÃ³n.

---

---

### **Cambio 2: Ajustar el Prompt para la Generación de Lecciones por Módulo**

*   **Archivo:** unctions/src/openai-service.ts
*   **Función:** uildModuleUserPrompt
*   **Problema:** El prompt anterior era ambiguo y rígido, lo que llevaba a la IA a generar consistentemente 8 lecciones por módulo, haciendo que los módulos se sintieran incompletos ("flojos").
*   **Solución:** Se ha modificado el prompt para solicitar explícitamente **12 lecciones** por módulo. Se han reemplazado las instrucciones de coreografía rígidas por directrices más flexibles, permitiendo a la IA seleccionar los tipos de lección intermedios más apropiados para el tema y los déficits del estudiante, asegurando una progresión lógica y gradual.

#### Antes:
`	ypescript
function buildModuleUserPrompt(params: {
  learnerState: LearnerState;
  nextModuleNumber: number;
  topDeficits: string[];
  target: string;
  topic: string;
}): string {
  const deficits =
    params.topDeficits.length > 0 ? params.topDeficits.join(", ") : "sin prioridades declaradas";
  const lessonBlueprint = [
    "1. welcome_summary -> bienvenida, glosario clave y meta del modulo.",
    "2. diagnostic_quiz -> micro-diagnostico de 2 preguntas para activar conocimientos previos.",
    "3. guided_practice -> resolver una mini tarea paso a paso.",
    "4. mini_game -> actividad creativa o gamificada de 3-5 pasos.",
    "5. theory_refresh -> nueva teoria sintetica + ejemplo LATAM.",
    "6. applied_project -> reto corto conectado al mundo real.",
    "7. activity -> escenario colaborativo o role play.",
    "8. reflection -> takeaway + accion concreta.",
    "9+. alterna guided_practice, theory_refresh, mini_game y reflection segun los deficits.",
  ].join("\n");
  return [
    Tema central: . Objetivo final: .,
    "LearnerState:",
    stringifyJson(params.learnerState),
    Siguiente modulo solicitado: ,
    Foco prioritario (ordenado por brecha): ,
    "Genera ENTRE 10 y 14 lecciones. Sigue la siguiente coreografia y utiliza el campo lessonType para cada leccion:",
    lessonBlueprint,
    "CRITICO: Cada leccion debe incluir: hook (<=140 chars), lessonType (enum), theory (<=2 parrafos COMPLETOS nunca vacios), exampleGlobal (global professional example <=400 chars NUNCA vacio), practice (SIEMPRE con prompt y expected nunca vacios), microQuiz (OBLIGATORIO: MINIMO 2 preguntas, maximo 4, NUNCA menos de 2), hint (1 frase opcional), motivation (micro-copy motivacional <=80 chars) y takeaway (NUNCA vacio).",
    "VALIDACION CRITICA: El array microQuiz[] de CADA leccion debe contener MINIMO 2 preguntas. Si generas menos de 2 preguntas, el sistema rechazara el modulo completo.",
    "IMPORTANTE: checkpointBlueprint DEBE tener entre 5 y 10 items, no menos de 5.",
    "Haz que la leccion welcome_summary incluya bienvenida + resumen de terminos clave; diagnostic_quiz debe centrarse en preguntas de seleccion multiple; mini_game debe describir pasos estilo juego; reflection debe cerrar con accion concreta.",
    "SOLO JSON con la estructura solicitada (no incluyas markdown ni texto adicional). NUNCA dejes campos requeridos vacios.",
    stringifyJson({
      moduleNumber: "<int>",
      title: "...",
      durationMinutes: "<25-45>",
      skillsTargeted: ["skillA"],
      lessons: [
        {
          title: "...",
          hook: "... (<=140)",
          lessonType: "welcome_summary",
          theory: "... (<=2 parrafos)",
          exampleGlobal: "... (<=400 chars, global example)",
          practice: { prompt: "...", expected: "..." },
          microQuiz: [
            {
              id: "l1q1",
              stem: "...",
              options: { A: "...", B: "...", C: "...", D: "..." },
              correct: "B",
              skillTag: "skillA",
              rationale: "...",
            },
            {
              id: "l1q2",
              stem: "...",
              options: { A: "...", B: "...", C: "...", D: "..." },
              correct: "C",
              skillTag: "skillA",
              rationale: "...",
            },
          ],
          hint: "...",
          motivation: "...",
          takeaway: "...",
        },
      ],
      challenge: { desc: "...", expected: "...", rubric: ["...", "...", "..."] },
      checkpointBlueprint: {
        items: [
          { id: "c1", skillTag: "skillA", type: "mcq" },
          { id: "c2", skillTag: "skillB", type: "mcq" },
          { id: "c3", skillTag: "skillA", type: "mcq" },
          { id: "c4", skillTag: "skillC", type: "mcq" },
          { id: "c5", skillTag: "skillB", type: "mcq" },
        ],
        targetReliability: "medium",
      },
    }),
  ].join("\n");
}
`

#### Después:
`	ypescript
function buildModuleUserPrompt(params: {
  learnerState: LearnerState;
  nextModuleNumber: number;
  topDeficits: string[];
  target: string;
  topic: string;
}): string {
  const deficits =
    params.topDeficits.length > 0 ? params.topDeficits.join(", ") : "sin prioridades declaradas";
  
  // Adjusted lesson blueprint for more adaptive and complete module generation (12 lessons)
  // Replaced rigid choreography with more flexible guidelines for AI to choose activity types
  const lessonBlueprintGuidelines = [
    "La primera lección (L1) debe ser de tipo welcome_summary para introducir el módulo.",
    "La segunda lección (L2) debe ser de tipo diagnostic_quiz para activar conocimientos previos.",
    "Las lecciones intermedias (L3-L11) deben ser una mezcla equilibrada y variada de los tipos: guided_practice, 	heory_refresh, mini_game, y ctivity. La IA debe seleccionar los tipos de lección más apropiados para el tema y los déficits del estudiante, asegurando una progresión lógica.",
    "La última lección (L12) debe ser de tipo eflection para consolidar el aprendizaje y ofrecer un takeaway concreto.",
    "Asegúrate de que la dificultad de las lecciones escale gradualmente a lo largo del módulo."
  ].join("\n");

  return [
    Tema central: . Objetivo final: .,
    "LearnerState:",
    stringifyJson(params.learnerState),
    Siguiente modulo solicitado: ,
    Foco prioritario (ordenado por brecha): ,
    // Adjusted instruction for 12 lessons and flexible choreography
    Genera un módulo de aprendizaje completo y variado con EXACTAMENTE 12 lecciones para el tema "".,
    "Sigue las siguientes directrices para la coreografía de las lecciones:",
    lessonBlueprintGuidelines,
    "CRITICO: Cada leccion debe incluir: hook (<=140 chars), lessonType (enum, siguiendo las directrices), theory (<=2 parrafos COMPLETOS nunca vacios), exampleGlobal (global professional example <=400 chars NUNCA vacio), practice (SIEMPRE con prompt y expected nunca vacios), microQuiz (OBLIGATORIO: MINIMO 2 preguntas, maximo 4, NUNCA menos de 2), hint (1 frase opcional), motivation (micro-copy motivacional <=80 chars) y takeaway (NUNCA vacio).",
    "VALIDACION CRITICA: El array microQuiz[] de CADA leccion debe contener MINIMO 2 preguntas. Si generas menos de 2 preguntas, el sistema rechazara el modulo completo.",
    "IMPORTANTE: checkpointBlueprint DEBE tener entre 5 y 10 items, no menos de 5.",
    "Haz que la leccion welcome_summary incluya bienvenida + resumen de terminos clave; diagnostic_quiz debe centrarse en preguntas de seleccion multiple; mini_game debe describir pasos estilo juego; reflection debe cerrar con accion concreta.",
    "SOLO JSON con la estructura solicitada (no incluyas markdown ni texto adicional). NUNCA dejes campos requeridos vacios.",
    stringifyJson({
      moduleNumber: "<int>",
      title: "...",
      durationMinutes: "<25-45>",
      skillsTargeted: ["skillA"],
      lessons: [
        {
          title: "...",
          hook: "... (<=140)",
          lessonType: "welcome_summary", // L1
          theory: "... (<=2 parrafos)",
          exampleGlobal: "... (<=400 chars, global example)",
          practice: { prompt: "...", expected: "..." },
          microQuiz: [
            { id: "l1q1", stem: "...", options: { A: "...", B: "...", C: "...", D: "..." }, correct: "B", skillTag: "skillA", rationale: "..." },
            { id: "l1q2", stem: "...", options: { A: "...", B: "...", C: "...", D: "..." }, correct: "C", skillTag: "skillA", rationale: "..." },
          ],
          hint: "...",
          motivation: "...",
          takeaway: "...",
        },
        // ... (lecciones intermedias L3-L11 serán una mezcla elegida por la IA) ...
        {
          title: "...",
          hook: "... (<=140)",
          lessonType: "reflection", // L12
          theory: "... (<=2 parrafos)",
          exampleGlobal: "... (<=400 chars, global example)",
          practice: { prompt: "...", expected: "..." },
          microQuiz: [
            { id: "l12q1", stem: "...", options: { A: "...", B: "...", C: "...", D: "..." }, correct: "B", skillTag: "skillX", rationale: "..." },
            { id: "l12q2", stem: "...", options: { A: "...", B: "...", C: "...", D: "..." }, correct: "C", skillTag: "skillY", rationale: "..." },
          ],
          hint: "...",
          motivation: "...",
          takeaway: "...",
        },
      ],
      challenge: { desc: "...", expected: "...", rubric: ["...", "...", "..."] },
      checkpointBlueprint: {
        items: [
          { id: "c1", skillTag: "skillA", type: "mcq" },
          { id: "c2", skillTag: "skillB", type: "mcq" },
          { id: "c3", skillTag: "skillA", type: "mcq" },
          { id: "c4", skillTag: "skillC", type: "mcq" },
          { id: "c5", skillTag: "skillB", type: "mcq" },
        ],
        targetReliability: "medium",
      },
    }),
  ].join("\n");
}
`
---
