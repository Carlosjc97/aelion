// ============================================================
// GENERATIVE CONTENT ENDPOINTS (OpenAI 4o)
// Designed with Ara's prompts for adaptive learning
// ============================================================

import { onRequest } from "firebase-functions/v2/https";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";
import * as logger from "firebase-functions/logger";
import {
  generateCalibrationQuiz,
  generateModule,
  validateChallengeResponse,
  tweakOutlinePlan,
} from "./openai-service";
import { getCached, setCached, generateCacheKey } from "./cache-service";
import {
  loadQuestionBank,
  selectCalibrationQuestions,
  selectModuleQuestions,
  gradeModuleQuiz,
  generateQuizId,
} from "./assessment";
import { getSQLMarketingTemplate } from "./templates/sql-marketing";
import {
  savePlacementSession,
  getPlacementSession,
  saveModuleSession,
  getModuleSession,
  deleteModuleSession,
} from "./session-store";
import {
  authenticateRequest,
  enforceRateLimit,
  resolveRateLimitKey,
} from "./request-guard";

if (!getApps().length) {
  initializeApp();
}

const firestore = getFirestore();
const authClient = getAuth();

interface UserEntitlements {
  isPremium: boolean;
  trialEndsAt?: Timestamp | Date;
}

interface GateResult {
  scorePct: number;
  errors: string[];
}

function isTrialActive(record?: Timestamp | Date | number): boolean {
  if (!record) {
    return false;
  }
  const expiresAt =
    record instanceof Timestamp
      ? record.toMillis()
      : record instanceof Date
        ? record.getTime()
        : typeof record === "number"
          ? record
          : 0;
  return Date.now() < expiresAt;
}

async function getUserEntitlements(userId: string): Promise<UserEntitlements> {
  const userDoc = await firestore.collection("users").doc(userId).get();
  if (!userDoc.exists) {
    return { isPremium: false };
  }

  const data = userDoc.data() ?? {};
  const entitlements = data.entitlements ?? {};
  const trial = entitlements.trialEndsAt ?? data.trialEndsAt;

  return {
    isPremium: Boolean(entitlements.isPremium ?? data.isPremium ?? false),
    trialEndsAt: trial,
  };
}

async function ensurePremiumAccess(
  userId: string,
  moduleNumber: number,
): Promise<void> {
  if (moduleNumber <= 1) {
    return;
  }

  const entitlements = await getUserEntitlements(userId);
  if (entitlements.isPremium || isTrialActive(entitlements.trialEndsAt)) {
    return;
  }

  throw new Error("PREMIUM_REQUIRED");
}

function gateDocRef(userId: string, moduleNumber: number) {
  return firestore
    .collection("users")
    .doc(userId)
    .collection("moduleGates")
    .doc(`module-${moduleNumber}`);
}

async function ensureGatePassed(
  userId: string,
  previousModuleNumber: number,
): Promise<GateResult> {
  if (previousModuleNumber <= 0) {
    return { scorePct: 100, errors: [] };
  }

  const gateDoc = await gateDocRef(userId, previousModuleNumber).get();
  if (!gateDoc.exists) {
    throw new Error("GATE_REQUIRED");
  }

  const data = gateDoc.data() ?? {};
  if (!data.passed) {
    throw new Error("GATE_NOT_PASSED");
  }

  return {
    scorePct: typeof data.scorePct === "number" ? data.scorePct : 70,
    errors: Array.isArray(data.incorrectTags) ? data.incorrectTags : [],
  };
}

async function recordUserBadge(options: {
  userId: string;
  badgeId: string;
  topic: string;
  score: number;
}): Promise<void> {
  const { userId, badgeId, topic, score } = options;
  const docRef = firestore.collection("user_badges").doc(userId);
  await docRef.set({
    [badgeId]: {
      topic,
      score,
      earnedAt: Timestamp.now(),
    },
  }, { merge: true });
}

async function persistGateResult(options: {
  userId: string;
  moduleNumber: number;
  passed: boolean;
  scorePct: number;
  incorrectQuestionIds: string[];
  incorrectTags: string[];
}) {
  const { userId, moduleNumber, passed, scorePct, incorrectQuestionIds, incorrectTags } = options;
  await gateDocRef(userId, moduleNumber).set({
    passed,
    scorePct,
    incorrectQuestionIds,
    incorrectTags,
    updatedAt: Timestamp.now(),
  });
}

/**
 * POST /placementQuizStartLive
 * Generative placement quiz using OpenAI 4o with cache + curated fallback
 * Body: { topic: string, lang: string }
 * Returns: { quizId, questions: [...], expiresAt, policy, meta }
 */
export const placementQuizStartLive = onRequest({ cors: true }, async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  try {
    const authContext = await authenticateRequest(req, authClient);
    if (!authContext.userId) {
      res.status(401).json({ error: "Authentication required" });
      return;
    }

    const rateKey = `${resolveRateLimitKey(req, authContext.userId)}:placement_quiz_start`;
    try {
      await enforceRateLimit({
        key: rateKey,
        limit: 10, // Increased from 5 for testing
        windowSeconds: 300, // 5 minutes instead of 1 minute
      });
    } catch (limitError) {
      if (limitError instanceof Error && limitError.message === "RATE_LIMIT_EXCEEDED") {
        res.status(429).json({ error: "Too many placement quiz requests" });
        return;
      }
      throw limitError;
    }

    const { topic, lang } = req.body;

    if (!topic || typeof topic !== "string" || topic.trim().length < 3) {
      res.status(400).json({ error: "Invalid topic" });
      return;
    }

    const language = lang === "es" ? "es" : "en";
    const quizId = generateQuizId();
    const createdAt = Date.now();
    const expiresAt = createdAt + 60 * 60 * 1000; // 1 hour

    // Try cache first
    const cacheKey = generateCacheKey({
      type: "quiz",
      topic: topic.trim().toLowerCase(),
      lang: language,
    });

    let questions: any[] = [];
    let source = "cache";

    const cached = await getCached(cacheKey);
    if (cached && Array.isArray(cached)) {
      questions = cached;
      logger.info(`Using cached quiz: ${cacheKey}`);
    } else {
      // Generate with OpenAI
      try {
        const generated = await generateCalibrationQuiz({
          topic,
          lang: language,
          userId: authContext.userId,
        });
        questions = generated.map((q, idx) => ({
          id: `cal-${Date.now()}-${idx}`,
          text: q.question,
          choices: q.options,
          difficulty: q.difficulty,
          correctAnswer: q.correct.charCodeAt(0) - 65, // "A" -> 0, "B" -> 1, etc.
        }));

        // Cache for 7 days
        await setCached(cacheKey, questions, 7, {
          model: "gpt-4o",
          lang: language,
          topic: topic.trim(),
          type: "quiz",
        });

        source = "openai";
        logger.info(`Generated quiz with OpenAI: ${cacheKey}`);
      } catch (openaiError) {
        const errorMessage =
          openaiError instanceof Error ? openaiError.message : String(openaiError);
        logger.error("OpenAI generation failed", {
          error: errorMessage,
          topic,
          language,
        });

        const configError =
          /OPENAI_API_KEY/i.test(errorMessage) ||
          errorMessage.toLowerCase().includes("not configured") ||
          errorMessage.includes("401");

        if (configError) {
          // Surface configuration/auth errors immediately so they can be fixed
          throw openaiError instanceof Error ? openaiError : new Error(errorMessage);
        }

        logger.warn("OpenAI unavailable, using curated fallback question bank", {
          topic,
          language,
          error: errorMessage,
        });

        try {
          const bank = loadQuestionBank(language);
          const selected = selectCalibrationQuestions(bank, 10);
          questions = selected.map((q) => ({
            id: q.id,
            text: q.question,
            choices: q.options,
            difficulty: q.difficulty,
            correctAnswer: q.correct_answer,
          }));
          source = "curated-fallback";
        } catch (fallbackError) {
          const fallbackReason =
            fallbackError instanceof Error ? fallbackError.message : String(fallbackError);
          throw new Error(
            `Unable to generate quiz for topic "${topic}". ` +
              `OpenAI unavailable and fallback question bank failed: ${fallbackReason}`,
          );
        }
      }
    }

    // Store session for grading in Firestore
    await savePlacementSession({
      quizId,
      topic: topic.trim(),
      language,
      userId: authContext.userId,
      questions: questions.map(q => ({
        id: q.id,
        question: q.text,
        options: q.choices,
        correct_answer: q.correctAnswer,
        difficulty: q.difficulty,
        irt_params: { a: 1.0, b: 0.0, c: 0.25 },
        module: "calibration",
        module_name: "Calibration",
        type: "multiple_choice",
        explanation: "",
        context: "",
        tags: ["calibration"],
      })),
      createdAt,
      expiresAt,
    });

    // Return questions without correct answers
    const questionsForClient = questions.map(q => ({
      id: q.id,
      text: q.text,
      choices: q.choices,
    }));

    res.status(200).json({
      quizId,
      expiresAt,
      maxMinutes: 15,
      questions: questionsForClient,
      policy: {
        numQuestions: 10,
        maxMinutes: 15,
      },
      meta: {
        source,
      },
    });

    logger.info(`placementQuizStartLive: ${quizId} for topic "${topic}" by ${authContext.userId} (source: ${source})`);
  } catch (error) {
    logger.error("placementQuizStartLive error:", error);
    res.status(500).json({
      error: error instanceof Error ? error.message : "Internal server error",
    });
  }
});

/**
 * POST /outlineGenerative
 * Generate module 1 adaptively based on quiz results
 * Body: { topic: string, band: string, lang: string, errors?: string[], quizScore?: number }
 * Returns: { module: {...}, cacheKey, source, meta }
 */
export const outlineGenerative = onRequest({ cors: true }, async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  try {
    const authContext = await authenticateRequest(req, authClient);
    if (!authContext.userId) {
      res.status(401).json({ error: "Authentication required" });
      return;
    }

    const rateKey = `${resolveRateLimitKey(req, authContext.userId)}:module1`;
    try {
      await enforceRateLimit({
        key: rateKey,
        limit: 10, // Increased for testing
        windowSeconds: 300, // 5 minutes
      });
    } catch (limitError) {
      if (limitError instanceof Error && limitError.message === "RATE_LIMIT_EXCEEDED") {
        res.status(429).json({ error: "Too many outline requests" });
        return;
      }
      throw limitError;
    }

    const { topic, band, lang, errors = [], quizScore } = req.body;

    if (!topic || typeof topic !== "string") {
      res.status(400).json({ error: "Invalid topic" });
      return;
    }

    const language = lang === "es" ? "es" : "en";
    const level = band || "intermediate";

    // Try cache first
    const cacheKey = generateCacheKey({
      type: "module",
      topic: topic.trim().toLowerCase(),
      lang: language,
      level,
      moduleNumber: 1,
    });

    let moduleData: any = null;
    let source = "cache";

    const cached = await getCached(cacheKey);
    if (cached) {
      moduleData = cached;
      logger.info(`Using cached module: ${cacheKey}`);
    } else {
      // Generate with OpenAI
      try {
        const generated = await generateModule({
          moduleNumber: 1,
          topic,
          band: level,
          lang: language,
          errors: Array.isArray(errors) ? errors : [],
          previousScore: quizScore,
          userId: authContext.userId,
        });

        moduleData = generated;

        // Cache for 14 days
        await setCached(cacheKey, moduleData, 14, {
          model: "gpt-4o",
          lang: language,
          topic: topic.trim(),
          type: "module",
        });

        source = "openai";
        logger.info(`Generated module 1 with OpenAI: ${cacheKey}`);
      } catch (openaiError) {
        const errorMessage =
          openaiError instanceof Error ? openaiError.message : String(openaiError);
        logger.error("OpenAI module generation failed", {
          error: errorMessage,
          topic,
          band: level,
          language,
        });

        // Check if it's a configuration error
        const configError =
          /OPENAI_API_KEY/i.test(errorMessage) ||
          errorMessage.toLowerCase().includes("not configured") ||
          errorMessage.includes("401");

        if (configError) {
          // Surface configuration/auth errors immediately so they can be fixed
          throw openaiError instanceof Error ? openaiError : new Error(errorMessage);
        }

        // For transient errors, return error instead of wrong content
        logger.error("Cannot generate module without OpenAI", {
          topic,
          language,
          error: errorMessage,
        });

        throw new Error(
          `Unable to generate module for topic "${topic}". ` +
            `OpenAI service is temporarily unavailable. Please try again later. ` +
            `Error: ${errorMessage}`,
        );
      }
    }

    res.status(200).json({
      module: moduleData,
      cacheKey,
      source,
      meta: {
        topic,
        band: level,
        lang: language,
      },
    });

    logger.info(`outlineGenerative: module 1 for "${topic}" (source: ${source}) user=${authContext.userId}`);
  } catch (error) {
    logger.error("outlineGenerative error:", error);
    res.status(500).json({
      error: error instanceof Error ? error.message : "Internal server error",
    });
  }
});

/**
 * POST /fetchNextModule
 * Generate modules 2-6 on demand based on previous performance
 * Body: { topic, moduleNumber, band, lang, previousScore, errors?, isPaid }
 * Returns: { module: {...}, cacheKey, source, meta }
 */
export const fetchNextModule = onRequest({ cors: true }, async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  try {
    const authContext = await authenticateRequest(req, authClient);
    if (!authContext.userId) {
      res.status(401).json({ error: "Authentication required" });
      return;
    }

    const rateKey = `${resolveRateLimitKey(req, authContext.userId)}:next_module`;
    try {
      await enforceRateLimit({
        key: rateKey,
        limit: 10, // Increased for testing
        windowSeconds: 300, // 5 minutes
      });
    } catch (limitError) {
      if (limitError instanceof Error && limitError.message === "RATE_LIMIT_EXCEEDED") {
        res.status(429).json({ error: "Too many module requests" });
        return;
      }
      throw limitError;
    }

    const { topic, moduleNumber, band, lang, errors = [] } = req.body;

    // Validation
    if (!topic || typeof topic !== "string") {
      res.status(400).json({ error: "Invalid topic" });
      return;
    }

    if (!moduleNumber || typeof moduleNumber !== "number" || moduleNumber < 2 || moduleNumber > 6) {
      res.status(400).json({ error: "Invalid moduleNumber (must be 2-6)" });
      return;
    }

    await ensurePremiumAccess(authContext.userId, moduleNumber);
    const gateResult = await ensureGatePassed(authContext.userId, moduleNumber - 1);
    const previousScore = gateResult.scorePct;
    const derivedErrors = [
      ...(Array.isArray(errors) ? errors : []),
      ...gateResult.errors,
    ].filter(Boolean);

    const language = lang === "es" ? "es" : "en";
    const level = band || "intermediate";

    // Try cache first
    const cacheKey = generateCacheKey({
      type: "module",
      topic: topic.trim().toLowerCase(),
      lang: language,
      level,
      moduleNumber,
    });

    let moduleData: any = null;
    let source = "cache";

    const cached = await getCached(cacheKey);
    if (cached) {
      moduleData = cached;
      logger.info(`Using cached module: ${cacheKey}`);
    } else {
      // Generate with OpenAI
      try {
        const generated = await generateModule({
          moduleNumber,
          topic,
          band: level,
          lang: language,
          errors: derivedErrors,
          previousScore,
          userId: authContext.userId,
        });

        moduleData = generated;

        // Cache for 14 days
        await setCached(cacheKey, moduleData, 14, {
          model: "gpt-4o",
          lang: language,
          topic: topic.trim(),
          type: "module",
        });

        source = "openai";
        logger.info(`Generated module ${moduleNumber} with OpenAI: ${cacheKey}`);
      } catch (openaiError) {
        // Fallback to static template
        logger.warn("OpenAI failed, falling back to template", {
          error: openaiError instanceof Error ? openaiError.message : String(openaiError),
        });

        const template = getSQLMarketingTemplate(level);
        const moduleTemplate = template.modules[moduleNumber - 1];

        if (!moduleTemplate) {
          res.status(404).json({ error: `Module ${moduleNumber} not found in template` });
          return;
        }

        moduleData = {
          moduleNumber,
          title: moduleTemplate.title,
          lessons: moduleTemplate.lessons.map(lesson => ({
            title: lesson.title,
            content: lesson.summary,
            estimatedTime: lesson.durationMinutes || 4,
          })),
          challenge: {
            description: "Complete las lecciones y tome el quiz final.",
            expectedOutput: "N/A",
          },
          test: [],
        };

        source = "template-fallback";
      }
    }

    res.status(200).json({
      module: moduleData,
      cacheKey,
      source,
      meta: {
        topic,
        moduleNumber,
        band: level,
        lang: language,
        previousScore,
        userId: authContext.userId,
      },
    });

    logger.info(`fetchNextModule: module ${moduleNumber} for "${topic}" (source: ${source}) user=${authContext.userId}`);
  } catch (error) {
    if (error instanceof Error) {
      if (error.message === "PREMIUM_REQUIRED") {
        res.status(403).json({ error: "Premium subscription required for modules 2-6" });
        return;
      }
      if (error.message === "GATE_REQUIRED") {
        res.status(403).json({ error: "Must complete gate quiz for previous module" });
        return;
      }
      if (error.message === "GATE_NOT_PASSED") {
        res.status(403).json({ error: "Previous gate quiz not passed (≥70% required)" });
        return;
      }
      if (error.message === "RATE_LIMIT_EXCEEDED") {
        res.status(429).json({ error: "Too many requests" });
        return;
      }
    }
    logger.error("fetchNextModule error:", error);
    res.status(500).json({
      error: error instanceof Error ? error.message : "Internal server error",
    });
  }
});

/**
 * Gate quiz start for modules (post-lesson assessments)
 */
export const moduleQuizStart = onRequest({ cors: true }, async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  try {
    const authContext = await authenticateRequest(req, authClient);
    if (!authContext.userId) {
      res.status(401).json({ error: "Authentication required" });
      return;
    }

    const rateKey = `${resolveRateLimitKey(req, authContext.userId)}:module_quiz_start`;
    try {
      await enforceRateLimit({
        key: rateKey,
        limit: 10,
        windowSeconds: 300,
      });
    } catch (limitError) {
      if (limitError instanceof Error && limitError.message === "RATE_LIMIT_EXCEEDED") {
        res.status(429).json({ error: "Too many gate quiz attempts" });
        return;
      }
      throw limitError;
    }

    const { moduleId, moduleNumber, lang, topic } = req.body;
    const normalizedModuleNumber =
      typeof moduleNumber === "number" ? moduleNumber : Number.parseInt(moduleId?.replace(/\D+/g, ""), 10);
    if (!normalizedModuleNumber || normalizedModuleNumber < 1 || normalizedModuleNumber > 6) {
      res.status(400).json({ error: "Invalid module number" });
      return;
    }

    const language = lang === "es" ? "es" : "en";
    const bank = loadQuestionBank(language);
    const moduleKey = moduleId?.toString() || `module-${normalizedModuleNumber}`;
    const questions = selectModuleQuestions(bank, moduleKey);

    const quizId = generateQuizId();
    const createdAt = Date.now();
    const expiresAt = createdAt + 30 * 60 * 1000;

    await saveModuleSession({
      quizId,
      moduleId: moduleKey,
      moduleNumber: normalizedModuleNumber,
      topic: typeof topic === "string" && topic.trim().length > 0
        ? topic.trim()
        : "unknown", // No hardcoded default
      language,
      createdAt,
      expiresAt,
      userId: authContext.userId,
      questions: questions.map((question) => ({
        id: question.id,
        question: question.question,
        options: question.options,
        correct_answer: question.correct_answer,
        tags: question.tags ?? [],
      })),
    });

    res.status(200).json({
      quizId,
      moduleNumber: normalizedModuleNumber,
      expiresAt,
      questions: questions.map((q) => ({
        id: q.id,
        text: q.question,
        choices: q.options,
      })),
      policy: {
        passingScore: 70,
        numQuestions: questions.length,
      },
    });
  } catch (error) {
    logger.error("moduleQuizStart error:", error);
    res.status(500).json({
      error: error instanceof Error ? error.message : "Internal server error",
    });
  }
});

export const moduleQuizGrade = onRequest({ cors: true }, async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  try {
    const authContext = await authenticateRequest(req, authClient);
    if (!authContext.userId) {
      res.status(401).json({ error: "Authentication required" });
      return;
    }

    const rateKey = `${resolveRateLimitKey(req, authContext.userId)}:module_quiz_grade`;
    try {
      await enforceRateLimit({
        key: rateKey,
        limit: 12,
        windowSeconds: 300,
      });
    } catch (limitError) {
      if (limitError instanceof Error && limitError.message === "RATE_LIMIT_EXCEEDED") {
        res.status(429).json({ error: "Too many grading attempts" });
        return;
      }
      throw limitError;
    }

    const { quizId, answers } = req.body;
    if (!quizId || typeof quizId !== "string") {
      res.status(400).json({ error: "quizId is required" });
      return;
    }
    if (!Array.isArray(answers) || answers.length === 0) {
      res.status(400).json({ error: "answers array is required" });
      return;
    }

    const session = await getModuleSession(quizId);
    if (!session) {
      res.status(404).json({ error: "Quiz session not found or expired" });
      return;
    }

    if (session.userId && session.userId !== authContext.userId) {
      res.status(403).json({ error: "Not allowed to grade this quiz" });
      return;
    }

    if (Date.now() > session.expiresAt) {
      await deleteModuleSession(quizId);
      res.status(410).json({ error: "Quiz session expired" });
      return;
    }

    const answerMap = new Map<string, number>();
    answers.forEach((entry: any) => {
      if (entry && typeof entry.id === "string" && typeof entry.choiceIndex === "number") {
        answerMap.set(entry.id, entry.choiceIndex);
      }
    });

    const result = gradeModuleQuiz(
      session.questions.map((question) => ({
        id: question.id,
        question: question.question,
        options: question.options,
        correct_answer: question.correct_answer,
        module: session.moduleId,
        module_name: session.moduleId,
        type: "multiple_choice",
        difficulty: "medium",
        irt_params: { a: 1, b: 0, c: 0.25 },
        explanation: "",
        context: "",
        tags: question.tags ?? [],
      })),
      answerMap,
    );

    await deleteModuleSession(quizId);

    const incorrectTags = result.incorrectQuestions.flatMap((questionId) => {
      const question = session.questions.find((q) => q.id === questionId);
      return question?.tags ?? [];
    });

    await persistGateResult({
      userId: authContext.userId,
      moduleNumber: session.moduleNumber,
      passed: result.passed,
      scorePct: result.scorePct,
      incorrectQuestionIds: result.incorrectQuestions,
      incorrectTags,
    });

    res.status(200).json({
      passed: result.passed,
      scorePct: result.scorePct,
      incorrectQuestions: result.incorrectQuestions,
      incorrectTags,
      nextModuleUnlocked: result.passed,
    });
  } catch (error) {
    logger.error("moduleQuizGrade error:", error);
    res.status(500).json({
      error: error instanceof Error ? error.message : "Internal server error",
    });
  }
});

// Quiz sessions are now persisted in Firestore via session-store helpers

export const validateChallenge = onRequest({ cors: true }, async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  try {
    const authContext = await authenticateRequest(req, authClient);
    if (!authContext.userId) {
      res.status(401).json({ error: "Authentication required" });
      return;
    }

    const rateKey = `${resolveRateLimitKey(req, authContext.userId)}:challenge_validate`;
    try {
      await enforceRateLimit({
        key: rateKey,
        limit: 20,
        windowSeconds: 300,
      });
    } catch (limitError) {
      if (limitError instanceof Error && limitError.message === "RATE_LIMIT_EXCEEDED") {
        res.status(429).json({ error: "Too many challenge validations" });
        return;
      }
      throw limitError;
    }

    const { topic, lang = "es", challengeDesc, expected, answer, moduleNumber, lessonId } = req.body;

    if (!topic || typeof topic !== "string") {
      res.status(400).json({ error: "Invalid topic" });
      return;
    }

    if (!challengeDesc || !expected || !answer) {
      res.status(400).json({ error: "challengeDesc, expected and answer are required" });
      return;
    }

    const language = lang === "es" ? "es" : "en";

    const validation = await validateChallengeResponse({
      topic,
      lang: language,
      challengeDesc,
      expected,
      answer,
      userId: authContext.userId,
    });

    let badgeId: string | undefined;
    const badgeThreshold = 80;
    if (validation.score >= badgeThreshold) {
      badgeId = lessonId
        ? `lesson-${lessonId}`
        : moduleNumber
          ? `module-${moduleNumber}-challenge`
          : `challenge-${Date.now()}`;

      await recordUserBadge({
        userId: authContext.userId,
        badgeId,
        topic,
        score: validation.score,
      });
    }

    res.status(200).json({
      ...validation,
      badgeId,
      moduleNumber,
      lessonId,
    });
  } catch (error) {
    logger.error("validateChallenge error:", error);
    res.status(500).json({
      error: error instanceof Error ? error.message : "Internal server error",
    });
  }
});

export const outlineTweak = onRequest({ cors: true }, async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  try {
    const authContext = await authenticateRequest(req, authClient);
    if (!authContext.userId) {
      res.status(401).json({ error: "Authentication required" });
      return;
    }

    const rateKey = `${resolveRateLimitKey(req, authContext.userId)}:outline_tweak`;
    try {
      await enforceRateLimit({
        key: rateKey,
        limit: 6,
        windowSeconds: 600,
      });
    } catch (limitError) {
      if (limitError instanceof Error && limitError.message === "RATE_LIMIT_EXCEEDED") {
        res.status(429).json({ error: "Too many tweak requests" });
        return;
      }
      throw limitError;
    }

    const { topic, lang = "es", gaps = [], outlineSummary } = req.body;

    if (!topic || typeof topic !== "string") {
      res.status(400).json({ error: "Invalid topic" });
      return;
    }

    if (!outlineSummary || typeof outlineSummary !== "string") {
      res.status(400).json({ error: "outlineSummary is required" });
      return;
    }

    const language = lang === "es" ? "es" : "en";
    const tweak = await tweakOutlinePlan({
      topic,
      lang: language,
      gaps: Array.isArray(gaps) ? gaps.map((gap: any) => gap?.toString() ?? "") : [],
      outlineSummary,
      userId: authContext.userId,
    });

    res.status(200).json({
      modules: tweak.modules,
      recommendedModules: tweak.recommendedModules,
      summary: tweak.summary,
      promptVersion: tweak.promptVersion,
    });
  } catch (error) {
    logger.error("outlineTweak error:", error);
    res.status(500).json({
      error: error instanceof Error ? error.message : "Internal server error",
    });
  }
});

export const openaiUsageMetrics = onRequest({ cors: true }, async (req, res) => {
  if (req.method !== "GET") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  try {
    const authContext = await authenticateRequest(req, authClient);
    if (!authContext.userId) {
      res.status(401).json({ error: "Authentication required" });
      return;
    }

    const rateKey = `${resolveRateLimitKey(req, authContext.userId)}:usage_metrics`;
    try {
      await enforceRateLimit({
        key: rateKey,
        limit: 10,
        windowSeconds: 300,
      });
    } catch (limitError) {
      if (limitError instanceof Error && limitError.message === "RATE_LIMIT_EXCEEDED") {
        res.status(429).json({ error: "Too many usage requests" });
        return;
      }
      throw limitError;
    }

    const snapshot = await firestore
      .collection("openai_usage")
      .where("userId", "==", authContext.userId)
      .orderBy("timestamp", "desc")
      .limit(60)
      .get();

    const entries = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        endpoint: data.endpoint,
        tokens: data.tokens ?? 0,
        promptTokens: data.promptTokens ?? 0,
        completionTokens: data.completionTokens ?? 0,
        estimatedCost: data.estimatedCost ?? 0,
        promptVersion: data.promptVersion,
        timestamp: data.timestamp instanceof Timestamp ? data.timestamp.toMillis() : Date.now(),
      };
    });

    const totals = entries.reduce(
      (acc, entry) => {
        acc.tokens += entry.tokens;
        acc.cost += entry.estimatedCost;
        return acc;
      },
      { tokens: 0, cost: 0 },
    );

    const byEndpoint: Record<string, number> = {};
    entries.forEach((entry) => {
      const key = entry.endpoint ?? "unknown";
      byEndpoint[key] = (byEndpoint[key] ?? 0) + entry.tokens;
    });

    res.status(200).json({
      totals,
      entries,
      byEndpoint,
    });
  } catch (error) {
    logger.error("openaiUsageMetrics error:", error);
    res.status(500).json({
      error: error instanceof Error ? error.message : "Internal server error",
    });
  }
});
