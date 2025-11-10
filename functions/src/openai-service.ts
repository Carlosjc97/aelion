/**
 * OpenAI Service - Generative Content with GPT-4o
 * Uses prompts designed by Ara for optimal token efficiency and structured output
 */

import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import { config as firebaseConfig } from "firebase-functions";
import { createHash } from "node:crypto";

/**
 * Detect domain type from topic for appropriate prompt customization
 */
function detectDomain(topic: string): string {
  const topicLower = topic.toLowerCase().trim();

  // Programming/Tech domains
  if (topicLower.includes("sql") || topicLower.includes("database") ||
      topicLower.includes("python") || topicLower.includes("javascript") ||
      topicLower.includes("java") || topicLower.includes("programming") ||
      topicLower.includes("code") || topicLower.includes("web") ||
      topicLower.includes("flutter") || topicLower.includes("react")) {
    return "programming";
  }

  // Language learning
  if (topicLower.includes("inglés") || topicLower.includes("english") ||
      topicLower.includes("español") || topicLower.includes("spanish") ||
      topicLower.includes("francés") || topicLower.includes("french") ||
      topicLower.includes("language") || topicLower.includes("idioma") ||
      topicLower.includes("conversation")) {
    return "language";
  }

  // Mathematics
  if (topicLower.includes("matemáticas") || topicLower.includes("math") ||
      topicLower.includes("cálculo") || topicLower.includes("calculus") ||
      topicLower.includes("álgebra") || topicLower.includes("algebra") ||
      topicLower.includes("estadística") || topicLower.includes("statistics") ||
      topicLower.includes("geometría") || topicLower.includes("geometry")) {
    return "math";
  }

  // Business/Marketing
  if (topicLower.includes("marketing") || topicLower.includes("business") ||
      topicLower.includes("ventas") || topicLower.includes("sales") ||
      topicLower.includes("gestión") || topicLower.includes("management")) {
    return "business";
  }

  // Science
  if (topicLower.includes("física") || topicLower.includes("physics") ||
      topicLower.includes("química") || topicLower.includes("chemistry") ||
      topicLower.includes("biología") || topicLower.includes("biology")) {
    return "science";
  }

  return "general";
}

let cachedOpenAIApiKey: string | null = null;

function resolveOpenAIApiKey(): string | undefined {
  if (cachedOpenAIApiKey) {
    return cachedOpenAIApiKey;
  }

  const envKey = process.env.OPENAI_API_KEY?.trim();
  if (envKey) {
    cachedOpenAIApiKey = envKey;
    return cachedOpenAIApiKey;
  }

  try {
    const runtimeConfig = firebaseConfig();
    const configValue =
      runtimeConfig.openai?.key ||
      runtimeConfig.openai?.api_key ||
      runtimeConfig.openai?.apiKey ||
      runtimeConfig.OPENAI?.key ||
      runtimeConfig.OPENAI?.api_key;

    const configKey = typeof configValue === "string" ? configValue.trim() : undefined;

    if (configKey) {
      cachedOpenAIApiKey = configKey;
      return cachedOpenAIApiKey;
    }
  } catch (error) {
    logger.debug("Firebase runtime config unavailable for OpenAI key", {
      error: error instanceof Error ? error.message : String(error),
    });
  }

  return undefined;
}

// OpenAI API types
interface OpenAIMessage {
  role: "system" | "user" | "assistant";
  content: string;
}

interface OpenAIResponse {
  id: string;
  object: string;
  created: number;
  model: string;
  choices: Array<{
    index: number;
    message: OpenAIMessage;
    finish_reason: string;
  }>;
  usage: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  };
}

// Calibration Quiz types
interface CalibrationQuestion {
  question: string;
  options: string[]; // ["A: Option 1", "B: Option 2", ...]
  correct: string; // "A", "B", "C", or "D"
  difficulty: "easy" | "medium" | "hard";
}

// Module types
interface LessonChallenge {
  desc: string;
  expected: string;
}

interface ModuleLesson {
  title: string;
  content: string; // Markdown
  estimatedTime: number; // minutes
  hook?: string;
  explanation?: string | string[];
  reto?: LessonChallenge;
  takeaway?: string;
}

interface ModuleChallenge {
  description: string;
  expectedOutput: string;
}

interface ModuleTestQuestion {
  question: string;
  options: string[];
  correct: string;
  difficulty?: "easy" | "medium" | "hard";
  rationale?: string;
}

interface ModulePlanOverviewItem {
  moduleNumber: number;
  title: string;
  objective: string;
  focus: string;
}

interface GeneratedModule {
  moduleNumber: number;
  title: string;
  lessons: ModuleLesson[];
  challenge: ModuleChallenge;
  test: ModuleTestQuestion[];
  planOverview?: ModulePlanOverviewItem[];
  promptVersion?: string;
}

type PromptVariant = "latam_hooks_v1" | "latam_hooks_v2";

const promptVariants: PromptVariant[] = ["latam_hooks_v1", "latam_hooks_v2"];

export interface OutlineTweakResult {
  modules: ModulePlanOverviewItem[];
  recommendedModules: number;
  summary: string;
  promptVersion: string;
}

export interface ChallengeValidationResult {
  score: number;
  feedback: string;
  passed: boolean;
  promptVersion: string;
}

/**
 * Safe JSON parse with retry
 * OpenAI sometimes returns malformed JSON - this validates and retries
 */
function safeJSONParse(content: string, retryAttempt: number): any {
  try {
    // Try to extract JSON from markdown code blocks if present
    let cleaned = content.trim();
    if (cleaned.startsWith("```json")) {
      cleaned = cleaned.replace(/```json\n?/g, "").replace(/```\n?$/g, "");
    } else if (cleaned.startsWith("```")) {
      cleaned = cleaned.replace(/```\n?/g, "");
    }

    const parsed = JSON.parse(cleaned);
    return parsed;
  } catch (error) {
    logger.warn(`JSON parse failed (attempt ${retryAttempt})`, {
      error: error instanceof Error ? error.message : String(error),
      contentPreview: content.substring(0, 200),
    });
    throw new Error(`Invalid JSON from OpenAI: ${error instanceof Error ? error.message : String(error)}`);
  }
}

function determinePromptVariant(userId?: string, seed = "default"): PromptVariant {
  if (!userId) {
    return promptVariants[0];
  }

  const hash = createHash("sha256")
    .update(`${seed}:${userId}`)
    .digest("hex");
  const numeric = parseInt(hash.substring(0, 8), 16);
  const index = numeric % promptVariants.length;
  return promptVariants[index];
}

interface UsageLogInput {
  userId?: string;
  endpoint: string;
  model: string;
  promptTokens: number;
  completionTokens: number;
  topic?: string;
  lang?: string;
  moduleNumber?: number;
  band?: string;
  promptVersion?: string;
  cacheHit?: boolean;
  extra?: Record<string, unknown>;
}

async function logOpenAiUsage(input: UsageLogInput): Promise<void> {
  const {
    userId = "system",
    endpoint,
    model,
    promptTokens,
    completionTokens,
    topic,
    lang,
    moduleNumber,
    band,
    promptVersion,
    cacheHit = false,
    extra = {},
  } = input;

  const totalTokens =
    promptTokens + completionTokens > 0
      ? promptTokens + completionTokens
      : 0;

  await admin.firestore().collection("openai_usage").add({
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    userId,
    endpoint,
    model,
    tokens: totalTokens,
    promptTokens,
    completionTokens,
    estimatedCost: estimateCost({
      prompt: promptTokens,
      completion: completionTokens,
    }),
    topic,
    lang,
    moduleNumber,
    band,
    cacheHit,
    promptVersion,
    ...extra,
  });
}

/**
 * Call OpenAI API with retry logic
 */
async function callOpenAI(
  messages: OpenAIMessage[],
  options: {
    temperature?: number;
    maxTokens?: number;
    model?: string;
    timeoutMs?: number;
  } = {}
): Promise<OpenAIResponse> {
  const apiKey = resolveOpenAIApiKey();
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY not configured");
  }

  const model = options.model || "gpt-4o";
  const temperature = options.temperature ?? 0.7;
  const maxTokens = options.maxTokens || 4000;

  const payload = {
    model,
    messages,
    temperature,
    max_tokens: maxTokens,
    response_format: { type: "json_object" },
  };

  const maxRetries = 3;
  let lastError: Error | null = null;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), options.timeoutMs ?? 60000);

      const response = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${apiKey}`,
        },
        body: JSON.stringify(payload),
        signal: controller.signal,
      }).finally(() => clearTimeout(timeout));

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`OpenAI API error: ${response.status} - ${errorText}`);
      }

      const data = await response.json() as OpenAIResponse;

      logger.info(`OpenAI call successful (attempt ${attempt})`, {
        model,
        tokens: data.usage.total_tokens,
      });

      return data;
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));
      logger.warn(`OpenAI call failed (attempt ${attempt}/${maxRetries})`, {
        error: lastError.message,
      });

      if (attempt < maxRetries) {
        // Exponential backoff
        await new Promise(resolve => setTimeout(resolve, 1000 * Math.pow(2, attempt)));
      }
    }
  }

  throw lastError || new Error("OpenAI call failed after retries");
}

/**
 * Generate calibration quiz (10 questions)
 *
 * Prompt by Ara - optimized for token efficiency
 */
export async function generateCalibrationQuiz(params: {
  topic: string;
  lang: string;
  userId?: string;
  promptVersionOverride?: PromptVariant;
}): Promise<CalibrationQuestion[]> {
  const { topic, lang, userId, promptVersionOverride } = params;
  const language = lang === "es" ? "es" : "en";
  const domainType = detectDomain(topic);
  const promptVersion =
    promptVersionOverride ?? determinePromptVariant(userId, "calibration");

  const storytellerHint =
    language === "es"
      ? "Imagina llamadas con squads remotos en Mexico, Colombia o Chile y menciona empresas tech LATAM cuando aplique."
      : "Ground every scenario in LATAM teams (Mexico City startups, Bogota agencies, Santiago scaleups).";

  const contextExamples =
    domainType === "programming"
      ? "bugs en microservicios, PR reviews, bases de datos con alto trafico"
      : domainType === "business"
        ? "lanzamientos de growth, performance marketing, seguimiento de OKRs"
        : "retos profesionales reales en LATAM";

  const prompt = [
    `Tema: "${topic.trim()}"`,
    `Idioma del cuestionario: ${language}`,
    storytellerHint,
    "Genera exactamente 10 preguntas de opcion multiple para calibrar el nivel real del usuario.",
    "Distribucion obligatoria:",
    "- 3 easy -> situaciones cotidianas LATAM (coworkings, clases nocturnas, conversaciones casuales).",
    "- 4 medium -> escenas profesionales (dailies, juntas hibridas, negociaciones con clientes).",
    "- 3 hard -> decisiones tecnicas o estrategicas de alto impacto.",
    "Cada pregunta debe tener:",
    '- Hook narrativo corto (ej. "En una demo con un cliente en Bogota...").',
    '- Cuatro opciones exactas con etiquetas "A:", "B:", "C:", "D:" y solo una correcta.',
    ' - Campo "difficulty" con easy|medium|hard.',
    `Inspira preguntas en ${contextExamples} y evita trivia basica.`,
    'Responde SOLO JSON valido con la forma {"questions":[...]} sin texto adicional.',
  ].join("\n");

  const systemMessage =
    language === "es"
      ? `Eres un tutor IA experto en ${topic}. Hablas como coach cercano LATAM y siempre respondes con JSON valido.`
      : `You are an adaptive LATAM tutor focused on ${topic}. Respond with valid JSON only.`;

  const messages: OpenAIMessage[] = [
    {
      role: "system",
      content: `${systemMessage} Usa ejemplos situados en ciudades LATAM y manten un tono motivador.`,
    },
    {
      role: "user",
      content: prompt,
    },
  ];

  try {
    const response = await callOpenAI(messages, {
      temperature: 0.75,
      maxTokens: 2000,
      model: "gpt-4o-mini",
      timeoutMs: 45000,
    });

    const content = response.choices[0].message.content;
    const parsed = safeJSONParse(content, 1);

    if (!parsed.questions || !Array.isArray(parsed.questions)) {
      throw new Error("Invalid response structure from OpenAI");
    }

    const questions: CalibrationQuestion[] = parsed.questions.map((q: any) => {
      if (!q.question || !Array.isArray(q.options) || q.options.length !== 4 || !q.correct || !q.difficulty) {
        throw new Error("Invalid question structure");
      }
      return {
        question: q.question,
        options: q.options,
        correct: q.correct,
        difficulty: q.difficulty,
      };
    });

    if (questions.length !== 10) {
      throw new Error(`Expected 10 questions, got ${questions.length}`);
    }

    const promptTokens = response.usage?.prompt_tokens ?? 0;
    const completionTokens = response.usage?.completion_tokens ?? 0;

    await logOpenAiUsage({
      endpoint: "generateCalibrationQuiz",
      model: response.model,
      promptTokens,
      completionTokens,
      topic,
      lang: language,
      userId,
      promptVersion,
    });

    logger.info("Generated calibration quiz", {
      topic,
      lang: language,
      numQuestions: questions.length,
      tokens: response.usage.total_tokens,
      promptVersion,
    });

    return questions;
  } catch (error) {
    logger.error("Failed to generate calibration quiz", {
      topic,
      lang: language,
      error: error instanceof Error ? error.message : String(error),
    });
    throw error;
  }
}
/**
 * Generate adaptive module
 *
 * Prompt by Ara - includes user weaknesses and performance
 */
export async function generateModule(params: {
  moduleNumber: number;
  topic: string;
  band: string;
  lang: string;
  errors?: string[];
  previousScore?: number;
  userId?: string;
  promptVersionOverride?: PromptVariant;
}): Promise<GeneratedModule> {
  const {
    moduleNumber,
    topic,
    band,
    lang,
    errors = [],
    previousScore,
    userId,
    promptVersionOverride,
  } = params;

  const language = lang === "es" ? "es" : "en";
  const domainType = detectDomain(topic);
  const promptVersion =
    promptVersionOverride ?? determinePromptVariant(userId, "module");

  const errorSummary = errors.length > 0 ? errors.join(", ") : "sin gaps declarados";
  const scoreSummary =
    typeof previousScore === "number"
      ? `${previousScore}%`
      : "sin intento previo";

  const planInstruction = moduleNumber === 1
    ? "Define planOverview con totalModules ENTRE 4 Y 12 (ej. 6 si el tema es simple, 10 si es profundo). Cada elemento debe incluir moduleNumber, title, objective y focus con enfoque especifico."
    : "Solo incluye planOverview si necesitas actualizarlo, manteniendo consistencia.";

  const prompt = [
    `Usuario nivel ${band} estudiando "${topic}".`,
    `Idioma del contenido: ${language}.`,
    `Errores o gaps detectados: ${errorSummary}.`,
    `Ultimo score del usuario: ${scoreSummary}.`,
    `Genera SOLO el modulo ${moduleNumber} y hazlo hiper relevante para los gaps.`,
    "Decide cuantas lecciones necesita (3-5 lecciones, 5 minutos cada una) segun complejidad del tema.",
    "Cada leccion debe incluir: title, hook (30s con escenario LATAM), explanation (bullets o parrafos concretos con ejemplos reales), reto (desc + expected), takeaway motivador con emoji.",
    "Incluye micro historias (startups de Mexico, Colombia, Chile) y tacticas accionables.",
    'Agrega test final con 5-7 preguntas multiple choice (opciones etiquetadas "A:" ...).',
    "Define reto interactivo esperado para que la app pueda validarlo.",
    planInstruction,
    `Responde SOLO JSON valido con esta forma: {
  "moduleNumber": number,
  "title": string,
  "lessons": [{"title","hook","explanation","reto":{"desc","expected"},"takeaway","estimatedTime"}],
  "test": [{"question","options","correct","difficulty"}],
  "planOverview": optional si actualizas el mapa completo
}.`,
  ].join("\n");

  const systemMessage = domainType === "business"
    ? "Eres un tutor IA latino especializado en growth y negocios. Tu estilo es calido, directo y accionable."
    : `Eres un tutor IA experto en ${topic}. Siempre devuelves JSON valido y contenido aterrizado a LATAM.`;

  const messages: OpenAIMessage[] = [
    { role: "system", content: `${systemMessage} No agregues notas fuera del JSON.` },
    { role: "user", content: prompt },
  ];

  try {
    const response = await callOpenAI(messages, {
      temperature: 0.7,
      maxTokens: 3500,
      model: "gpt-4o",
      timeoutMs: 60000,
    });

    const content = response.choices[0].message.content;
    const parsed = safeJSONParse(content, 1);

    if (!parsed || typeof parsed !== "object") {
      throw new Error("Invalid module structure from OpenAI");
    }

    if (!Array.isArray(parsed.lessons)) {
      throw new Error("Module lessons missing from OpenAI response");
    }

    const normalizedLessons: ModuleLesson[] = parsed.lessons.map((lesson: any, index: number) => {
      const hook = typeof lesson?.hook === "string" ? lesson.hook : "";
      const rawExplanation = lesson?.explanation ?? lesson?.content ?? "";
      const explanation = Array.isArray(rawExplanation)
        ? rawExplanation.join("\n- ")
        : rawExplanation?.toString() ?? "";

      const retoRaw = lesson?.reto ?? lesson?.challenge ?? {};
      const reto: LessonChallenge | undefined =
        retoRaw && (retoRaw.desc || retoRaw.expected || retoRaw.expectedOutput)
          ? {
            desc: (retoRaw.desc ?? retoRaw.description ?? "").toString(),
            expected: (retoRaw.expected ?? retoRaw.expectedOutput ?? "").toString(),
          }
          : undefined;

      const takeaway = typeof lesson?.takeaway === "string" ? lesson.takeaway : "";
      const estimatedTime = typeof lesson?.estimatedTime === "number"
        ? lesson.estimatedTime
        : typeof lesson?.duration === "number"
          ? lesson.duration
          : 5;

      return {
        title: lesson?.title?.toString() ?? `Leccion ${index + 1}`,
        content: explanation,
        estimatedTime,
        hook,
        explanation,
        reto,
        takeaway,
      };
    });

    const lessonChallenge = normalizedLessons.find((lesson) => lesson.reto && lesson.reto.desc && lesson.reto.expected)?.reto;

    const moduleChallenge: ModuleChallenge = {
      description: parsed?.challenge?.description
        ?? parsed?.challenge?.desc
        ?? lessonChallenge?.desc
        ?? "Reto practico",
      expectedOutput: parsed?.challenge?.expectedOutput
        ?? parsed?.challenge?.expected
        ?? lessonChallenge?.expected
        ?? "",
    };

    const planOverview = Array.isArray(parsed.planOverview)
      ? parsed.planOverview.map((item: any, idx: number) => ({
        moduleNumber: typeof item?.moduleNumber === "number" ? item.moduleNumber : idx + 1,
        title: item?.title?.toString() ?? `Modulo ${idx + 1}`,
        objective: item?.objective?.toString() ?? item?.summary?.toString() ?? "",
        focus: item?.focus?.toString() ?? item?.theme?.toString() ?? "",
      }))
      : undefined;

    const normalizedTest: ModuleTestQuestion[] = Array.isArray(parsed.test)
      ? parsed.test.map((question: any, idx: number) => {
        const options = Array.isArray(question?.options)
          ? question.options.map((option: any) => option?.toString() ?? "").filter(Boolean)
          : [];

        return {
          question: question?.question?.toString() ?? `Pregunta ${idx + 1}`,
          options,
          correct: question?.correct?.toString() ?? "A",
          difficulty: question?.difficulty,
          rationale: question?.rationale?.toString(),
        };
      }).filter((q: ModuleTestQuestion) => q.options.length >= 4)
      : [];

    const module: GeneratedModule = {
      moduleNumber: typeof parsed.moduleNumber === "number" ? parsed.moduleNumber : moduleNumber,
      title: parsed?.title?.toString() ?? `Modulo ${moduleNumber}`,
      lessons: normalizedLessons,
      challenge: moduleChallenge,
      test: normalizedTest,
      planOverview,
      promptVersion,
    };

    const promptTokens = response.usage?.prompt_tokens ?? 0;
    const completionTokens = response.usage?.completion_tokens ?? 0;

    await logOpenAiUsage({
      endpoint: "generateModule",
      model: response.model,
      promptTokens,
      completionTokens,
      topic,
      lang: language,
      moduleNumber: module.moduleNumber,
      band,
      userId,
      promptVersion,
    });

    logger.info("Generated module", {
      moduleNumber: module.moduleNumber,
      topic,
      band,
      lang: language,
      numLessons: module.lessons.length,
      numTestQuestions: module.test.length,
      tokens: response.usage.total_tokens,
      promptVersion,
    });

    return module;
  } catch (error) {
    logger.error("Failed to generate module", {
      moduleNumber,
      topic,
      band,
      error: error instanceof Error ? error.message : String(error),
    });
    throw error;
  }
}
/**
 * Estimate cost of generation
 * GPT-4o pricing: $2.50 / 1M input tokens, $10.00 / 1M output tokens
 */
export function estimateCost(tokens: { prompt: number; completion: number }): number {
  const inputCost = (tokens.prompt / 1_000_000) * 2.50;
  const outputCost = (tokens.completion / 1_000_000) * 10.00;
  return inputCost + outputCost;
}

export async function tweakOutlinePlan(params: {
  topic: string;
  lang: string;
  gaps: string[];
  outlineSummary: string;
  userId?: string;
  promptVersionOverride?: PromptVariant;
}): Promise<OutlineTweakResult> {
  const { topic, lang, gaps, outlineSummary, userId, promptVersionOverride } = params;
  const language = lang === "es" ? "es" : "en";
  const promptVersion =
    promptVersionOverride ?? determinePromptVariant(userId, "outline_tweak");

  const gapSummary = gaps.length > 0 ? gaps.join(", ") : "sin gaps declarados";

  const prompt = [
    `Tema: "${topic}".`,
    `Idioma del plan: ${language}.`,
    `Gaps detectados: ${gapSummary}.`,
    "Outline actual:",
    outlineSummary,
    "Ajusta el plan para priorizar los gaps y decide el numero ideal de modulos entre 4 y 12.",
    "Devuelve JSON valido con forma:",
    "{",
    '  "recommendedModules": number,',
    '  "modules": [',
    '     {"moduleNumber":1,"title":"...","objective":"...","focus":"gap|growth"}',
    "  ],",
    '  "summary": "Explica en 2 frases como se personalizo"',
    "}",
    "Usa tono cercano LATAM y objetivos accionables.",
  ].join("\n");

  const systemMessage =
    language === "es"
      ? "Eres un planificador curricular latino que responde solo JSON valido."
      : "You are a LATAM learning strategist that outputs valid JSON only.";

  const messages: OpenAIMessage[] = [
    { role: "system", content: `${systemMessage} No agregues comentarios fuera del JSON.` },
    { role: "user", content: prompt },
  ];

  try {
    const response = await callOpenAI(messages, {
      temperature: 0.4,
      maxTokens: 1500,
      model: "gpt-4o",
      timeoutMs: 40000,
    });

    const content = response.choices[0].message.content;
    const parsed = safeJSONParse(content, 1);

    const recommendedModulesRaw = parsed?.recommendedModules;
    const recommendedModules =
      typeof recommendedModulesRaw === "number"
        ? Math.max(4, Math.min(12, Math.round(recommendedModulesRaw)))
        : Math.max(4, Math.min(12, Array.isArray(parsed?.modules) ? parsed.modules.length : 6));

    const modules = Array.isArray(parsed?.modules)
      ? parsed.modules.map((item: any, idx: number) => ({
        moduleNumber: typeof item?.moduleNumber === "number" ? item.moduleNumber : idx + 1,
        title: item?.title?.toString() ?? `Modulo ${idx + 1}`,
        objective: item?.objective?.toString() ?? item?.summary?.toString() ?? "",
        focus: item?.focus?.toString() ?? item?.priority?.toString() ?? "",
      }))
      : [];

    const summary = parsed?.summary?.toString() ?? "";

    await logOpenAiUsage({
      endpoint: "tweakOutlinePlan",
      model: response.model,
      promptTokens: response.usage?.prompt_tokens ?? 0,
      completionTokens: response.usage?.completion_tokens ?? 0,
      topic,
      lang: language,
      userId,
      promptVersion,
    });

    return {
      modules,
      recommendedModules,
      summary,
      promptVersion,
    };
  } catch (error) {
    logger.error("Failed to tweak outline plan", {
      topic,
      gaps,
      error: error instanceof Error ? error.message : String(error),
    });
    throw error;
  }
}

export async function validateChallengeResponse(params: {
  topic: string;
  lang: string;
  challengeDesc: string;
  expected: string;
  answer: string;
  userId?: string;
  promptVersionOverride?: PromptVariant;
}): Promise<ChallengeValidationResult> {
  const { topic, lang, challengeDesc, expected, answer, userId, promptVersionOverride } = params;
  const language = lang === "es" ? "es" : "en";
  const promptVersion =
    promptVersionOverride ?? determinePromptVariant(userId, "challenge_validation");

  const prompt = [
    `Evalua la respuesta del estudiante para el reto sobre "${topic}".`,
    `Descripcion del reto: ${challengeDesc}`,
    `Respuesta esperada: ${expected}`,
    `Respuesta del estudiante: ${answer}`,
    "Regresa JSON con {\"score\":0-100,\"feedback\":\"texto corto\",\"passed\":true|false}.",
    "Considera creatividad, alineacion con esperado y claridad.",
  ].join("\n");

  const systemMessage =
    language === "es"
      ? "Eres un coach LATAM que evalua retos breves. Siempre respondes JSON."
      : "You are a concise evaluator. Always respond with JSON only.";

  const messages: OpenAIMessage[] = [
    { role: "system", content: `${systemMessage} No incluyas explicaciones fuera del JSON.` },
    { role: "user", content: prompt },
  ];

  try {
    const response = await callOpenAI(messages, {
      temperature: 0.35,
      maxTokens: 800,
      model: "gpt-4o-mini",
      timeoutMs: 20000,
    });

    const content = response.choices[0].message.content;
    const parsed = safeJSONParse(content, 1);

    const score = typeof parsed?.score === "number"
      ? Math.max(0, Math.min(100, Math.round(parsed.score)))
      : 0;
    const feedback = parsed?.feedback?.toString() ?? "";
    const passed = typeof parsed?.passed === "boolean" ? parsed.passed : score >= 80;

    await logOpenAiUsage({
      endpoint: "validateChallenge",
      model: response.model,
      promptTokens: response.usage?.prompt_tokens ?? 0,
      completionTokens: response.usage?.completion_tokens ?? 0,
      topic,
      lang: language,
      userId,
      promptVersion,
    });

    return {
      score,
      feedback,
      passed,
      promptVersion,
    };
  } catch (error) {
    logger.error("Failed to validate challenge response", {
      topic,
      error: error instanceof Error ? error.message : String(error),
    });
    throw error;
  }
}
