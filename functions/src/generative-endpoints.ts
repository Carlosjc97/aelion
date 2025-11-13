// ============================================================
// GENERATIVE CONTENT ENDPOINTS (OpenAI 4o)
// Designed with Ara's prompts for adaptive learning
// ============================================================

import { onRequest } from "firebase-functions/v2/https";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp, FieldValue } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";
import * as logger from "firebase-functions/logger";
import type {
  LearnerState,
  ModuleOut,
  AdaptivePlanDraft,
  CheckpointQuiz,
  EvaluationResult,
  Band,
} from "./openai-service";
import { getCached, setCached, generateCacheKey, invalidateCache } from "./cache-service";
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
type OpenAIServiceModule = typeof import("./openai-service");
type AssessmentModule = typeof import("./assessment");
type SqlTemplateModule = typeof import("./templates/sql-marketing");

let openaiModule: OpenAIServiceModule | null = null;
let assessmentModule: AssessmentModule | null = null;
let sqlTemplateModule: SqlTemplateModule | null = null;

function getOpenAI(): OpenAIServiceModule {
  if (!openaiModule) {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    openaiModule = require("./openai-service") as OpenAIServiceModule;
  }
  return openaiModule;
}

function getAssessment(): AssessmentModule {
  if (!assessmentModule) {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    assessmentModule = require("./assessment") as AssessmentModule;
  }
  return assessmentModule;
}

function getSqlTemplates(): SqlTemplateModule {
  if (!sqlTemplateModule) {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    sqlTemplateModule = require("./templates/sql-marketing") as SqlTemplateModule;
  }
  return sqlTemplateModule;
}

if (!getApps().length) {
  initializeApp();
}

const firestore = getFirestore();
const authClient = getAuth();
const DAILY_AI_CAP = 20;

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

function gateAttemptRef(userId: string, moduleNumber: number) {
  return firestore
    .collection("user_gates_attempts")
    .doc(`${userId}_module_${moduleNumber}`);
}

interface GateAttemptState {
  attempts: number;
  practiceUnlocked: boolean;
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

const DEFAULT_LEARNER_STATE: LearnerState = {
  level_band: "basic",
  skill_mastery: {},
  history: {
    passedModules: [],
    failedModules: [],
    commonErrors: [],
  },
  target: "general",
};

function learnerStateDoc(userId: string) {
  return firestore
    .collection("users")
    .doc(userId)
    .collection("adaptiveState")
    .doc("summary");
}

function checkpointDoc(userId: string, moduleNumber: number) {
  return firestore
    .collection("users")
    .doc(userId)
    .collection("adaptiveCheckpoints")
    .doc(`module-${moduleNumber}`);
}

function createLearnerStateSnapshot(overrides: Partial<LearnerState> = {}): LearnerState {
  return {
    level_band: (overrides.level_band as Band) ?? DEFAULT_LEARNER_STATE.level_band,
    skill_mastery: overrides.skill_mastery ?? {},
    history: {
      passedModules: overrides.history?.passedModules ?? [],
      failedModules: overrides.history?.failedModules ?? [],
      commonErrors: overrides.history?.commonErrors ?? [],
    },
    target: overrides.target ?? DEFAULT_LEARNER_STATE.target,
  };
}

async function loadLearnerState(userId: string): Promise<LearnerState> {
  const snapshot = await learnerStateDoc(userId).get();
  if (!snapshot.exists) {
    return createLearnerStateSnapshot();
  }
  const data = snapshot.data() ?? {};
  return createLearnerStateSnapshot({
    level_band: data.level_band as Band,
    skill_mastery: typeof data.skill_mastery === "object" ? data.skill_mastery : {},
    history: {
      passedModules: Array.isArray(data.history?.passedModules) ? data.history.passedModules : [],
      failedModules: Array.isArray(data.history?.failedModules) ? data.history.failedModules : [],
      commonErrors: Array.isArray(data.history?.commonErrors) ? data.history.commonErrors : [],
    },
    target: typeof data.target === "string" ? data.target : DEFAULT_LEARNER_STATE.target,
  });
}

async function saveLearnerState(userId: string, state: LearnerState): Promise<void> {
  await learnerStateDoc(userId).set(
    {
      ...state,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: false },
  );
}

async function updateLearnerState(
  userId: string,
  updates: Partial<LearnerState>,
): Promise<LearnerState> {
  const current = await loadLearnerState(userId);
  const next: LearnerState = {
    ...current,
    ...updates,
    skill_mastery: {
      ...current.skill_mastery,
      ...(updates.skill_mastery ?? {}),
    },
    history: {
      ...current.history,
      ...(updates.history ?? {}),
      passedModules: updates.history?.passedModules ?? current.history.passedModules,
      failedModules: updates.history?.failedModules ?? current.history.failedModules,
      commonErrors: updates.history?.commonErrors ?? current.history.commonErrors,
    },
  };
  await saveLearnerState(userId, next);
  return next;
}

function rankSkillDeficits(state: LearnerState, limit = 3): string[] {
  const entries = Object.entries(state.skill_mastery);
  if (!entries.length) {
    return [];
  }
  return entries
    .sort((a, b) => a[1] - b[1])
    .slice(0, limit)
    .map(([skill]) => skill);
}

interface StoredCheckpointMeta {
  key: Record<string, "A" | "B" | "C" | "D">;
  skillMap: Record<string, { skillTag: string; difficulty: "easy" | "medium" | "hard" }>;
  skillsTargeted: string[];
  topic: string;
  band: Band;
}

async function saveCheckpointMeta(
  userId: string,
  moduleNumber: number,
  meta: StoredCheckpointMeta,
): Promise<void> {
  await checkpointDoc(userId, moduleNumber).set({
    ...meta,
    moduleNumber,
    createdAt: FieldValue.serverTimestamp(),
  });
}

async function readCheckpointMeta(
  userId: string,
  moduleNumber: number,
): Promise<StoredCheckpointMeta | null> {
  const snapshot = await checkpointDoc(userId, moduleNumber).get();
  if (!snapshot.exists) {
    return null;
  }
  const data = snapshot.data() ?? {};
  if (!data.key || !data.skillMap) {
    return null;
  }
  return {
    key: data.key,
    skillMap: data.skillMap,
    skillsTargeted: Array.isArray(data.skillsTargeted) ? data.skillsTargeted : [],
    topic: data.topic ?? "",
    band: (data.band as Band) ?? "basic",
  };
}

async function getGateAttemptState(userId: string, moduleNumber: number): Promise<GateAttemptState> {
  try {
    const snapshot = await gateAttemptRef(userId, moduleNumber).get();
    if (!snapshot.exists) {
      return { attempts: 0, practiceUnlocked: false };
    }
    const data = snapshot.data() ?? {};
    return {
      attempts: typeof data.attempts === "number" ? data.attempts : 0,
      practiceUnlocked: Boolean(data.practiceUnlocked),
    };
  } catch (error) {
    logger.warn("Failed to load gate attempts", {
      userId,
      moduleNumber,
      error: error instanceof Error ? error.message : String(error),
    });
    return { attempts: 0, practiceUnlocked: false };
  }
}

async function updateGateAttemptState(options: {
  userId: string;
  moduleNumber: number;
  passed: boolean;
}): Promise<GateAttemptState> {
  const { userId, moduleNumber, passed } = options;
  const ref = gateAttemptRef(userId, moduleNumber);

  if (passed) {
    try {
      await ref.delete();
    } catch {
      await ref.set(
        {
          attempts: 0,
          practiceUnlocked: false,
          updatedAt: Timestamp.now(),
        },
        { merge: true },
      );
    }
    return { attempts: 0, practiceUnlocked: false };
  }

  const state = await firestore.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const data = snapshot.data() ?? {};
    let attempts = typeof data.attempts === "number" ? data.attempts : 0;
    attempts += 1;
    const practiceUnlocked = data.practiceUnlocked === true || attempts >= 3;

    transaction.set(
      ref,
      {
        attempts,
        practiceUnlocked,
        updatedAt: Timestamp.now(),
      },
      { merge: true },
    );

    return { attempts, practiceUnlocked };
  });

  return state;
}

async function loadGateErrorTags(userId: string, moduleNumber: number): Promise<string[]> {
  try {
    const snapshot = await gateDocRef(userId, moduleNumber).get();
    if (!snapshot.exists) {
      return [];
    }
    const data = snapshot.data() ?? {};
    const tags = Array.isArray(data.incorrectTags)
      ? data.incorrectTags.map((tag: unknown) => (typeof tag === "string" ? tag : String(tag ?? ""))).filter(Boolean)
      : [];
    return Array.from(new Set(tags));
  } catch (error) {
    logger.warn("Failed to load gate error tags", {
      userId,
      moduleNumber,
      error: error instanceof Error ? error.message : String(error),
    });
    return [];
  }
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
export const placementQuizStartLive = onRequest({ cors: true, timeoutSeconds: 300, memory: "512MiB" }, async (req, res) => {
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
        userId: authContext.userId,
        userDailyCap: DAILY_AI_CAP,
      });
    } catch (limitError) {
      if (limitError instanceof Error) {
        if (limitError.message === "RATE_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Too many placement quiz requests" });
          return;
        }
        if (limitError.message === "DAILY_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Daily AI limit reached, try tomorrow" });
          return;
        }
      }
      throw limitError;
    }

    const { topic, lang } = req.body;

    if (!topic || typeof topic !== "string" || topic.trim().length < 3) {
      res.status(400).json({ error: "Invalid topic" });
      return;
    }

    const language = lang === "es" ? "es" : "en";
    const quizId = getAssessment().generateQuizId();
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
        const generated = await getOpenAI().generateCalibrationQuiz({
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

        logger.warn(
          "placementQuizStart fallback: OpenAI unavailable, using curated bank",
          {
            topic,
            language,
            error: errorMessage,
          },
        );

        // Invalidate cache so next attempt regenerates with OpenAI
        await invalidateCache(cacheKey);
        logger.info(`Invalidated cache ${cacheKey} due to fallback`);

        try {
          const assessment = getAssessment();
          const bank = assessment.loadQuestionBank(language);
          const selected = assessment.selectCalibrationQuestions(bank, 10);
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
export const outlineGenerative = onRequest({ cors: true, timeoutSeconds: 300, memory: "512MiB" }, async (req, res) => {
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
        userId: authContext.userId,
        userDailyCap: DAILY_AI_CAP,
      });
    } catch (limitError) {
      if (limitError instanceof Error) {
        if (limitError.message === "RATE_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Too many outline requests" });
          return;
        }
        if (limitError.message === "DAILY_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Daily AI limit reached, try tomorrow" });
          return;
        }
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
        const generated = await getOpenAI().generateModule({
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
export const fetchNextModule = onRequest({ cors: true, timeoutSeconds: 300, memory: "512MiB" }, async (req, res) => {
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
        userId: authContext.userId,
        userDailyCap: DAILY_AI_CAP,
      });
    } catch (limitError) {
      if (limitError instanceof Error) {
        if (limitError.message === "RATE_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Too many module requests" });
          return;
        }
        if (limitError.message === "DAILY_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Daily AI limit reached, try tomorrow" });
          return;
        }
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
        const generated = await getOpenAI().generateModule({
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

        const template = getSqlTemplates().getSQLMarketingTemplate(level);
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
export const moduleQuizStart = onRequest({ cors: true, timeoutSeconds: 300, memory: "512MiB" }, async (req, res) => {
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
    const assessment = getAssessment();
    const bank = assessment.loadQuestionBank(language);
    const moduleKey = moduleId?.toString() || `module-${normalizedModuleNumber}`;
    const questions = assessment.selectModuleQuestions(bank, moduleKey);

    const quizId = assessment.generateQuizId();
    const createdAt = Date.now();
    const expiresAt = createdAt + 30 * 60 * 1000;

    const attemptState = await getGateAttemptState(authContext.userId, normalizedModuleNumber);
    let practiceHints: string[] | undefined;
    if (attemptState.practiceUnlocked) {
      const hintTopic = typeof topic === "string" && topic.trim().length > 0 ? topic.trim() : "learning";
      const recentTags = await loadGateErrorTags(authContext.userId, normalizedModuleNumber);
      try {
        practiceHints = await getOpenAI().generateGateHints({
          topic: hintTopic,
          moduleNumber: normalizedModuleNumber,
          lang: language,
          errors: recentTags,
          userId: authContext.userId,
        });
      } catch (hintError) {
        logger.warn("generateGateHints failed", {
          userId: authContext.userId,
          moduleNumber: normalizedModuleNumber,
          error: hintError instanceof Error ? hintError.message : String(hintError),
        });
      }
    }

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
        practiceMode: attemptState.practiceUnlocked,
        attempts: attemptState.attempts,
        maxAttempts: 3,
      },
      practice: {
        enabled: attemptState.practiceUnlocked,
        hints: attemptState.practiceUnlocked ? practiceHints ?? [] : [],
        attempts: attemptState.attempts,
        maxAttempts: 3,
      },
    });
  } catch (error) {
    logger.error("moduleQuizStart error:", error);
    res.status(500).json({
      error: error instanceof Error ? error.message : "Internal server error",
    });
  }
});

export const moduleQuizGrade = onRequest({ cors: true, timeoutSeconds: 300, memory: "512MiB" }, async (req, res) => {
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

    const assessment = getAssessment();
    const result = assessment.gradeModuleQuiz(
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

    const attemptState = await updateGateAttemptState({
      userId: authContext.userId,
      moduleNumber: session.moduleNumber,
      passed: result.passed,
    });

    res.status(200).json({
      passed: result.passed,
      scorePct: result.scorePct,
      incorrectQuestions: result.incorrectQuestions,
      incorrectTags,
      nextModuleUnlocked: result.passed,
      attempts: attemptState.attempts,
      practiceUnlocked: attemptState.practiceUnlocked,
    });
  } catch (error) {
    logger.error("moduleQuizGrade error:", error);
    res.status(500).json({
      error: error instanceof Error ? error.message : "Internal server error",
    });
  }
});

// Quiz sessions are now persisted in Firestore via session-store helpers

export const validateChallenge = onRequest({ cors: true, timeoutSeconds: 300, memory: "512MiB" }, async (req, res) => {
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
        userId: authContext.userId,
        userDailyCap: DAILY_AI_CAP,
      });
    } catch (limitError) {
      if (limitError instanceof Error) {
        if (limitError.message === "RATE_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Too many challenge validations" });
          return;
        }
        if (limitError.message === "DAILY_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Daily AI limit reached, try tomorrow" });
          return;
        }
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

    const validation = await getOpenAI().validateChallengeResponse({
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

export const outlineTweak = onRequest({ cors: true, timeoutSeconds: 300, memory: "512MiB" }, async (req, res) => {
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
        userId: authContext.userId,
        userDailyCap: DAILY_AI_CAP,
      });
    } catch (limitError) {
      if (limitError instanceof Error) {
        if (limitError.message === "RATE_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Too many tweak requests" });
          return;
        }
        if (limitError.message === "DAILY_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Daily AI limit reached, try tomorrow" });
          return;
        }
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
    const tweak = await getOpenAI().tweakOutlinePlan({
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

export const adaptivePlanDraft = onRequest({ cors: true, timeoutSeconds: 300, memory: "512MiB" }, async (req, res) => {
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

    const rateKey = `${resolveRateLimitKey(req, authContext.userId)}:adaptive_plan`;
    try {
      await enforceRateLimit({
        key: rateKey,
        limit: 20,
        windowSeconds: 300,
        userId: authContext.userId,
        userDailyCap: DAILY_AI_CAP,
      });
    } catch (limitError) {
      if (limitError instanceof Error) {
        if (limitError.message === "RATE_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Too many adaptive plan drafts" });
          return;
        }
        if (limitError.message === "DAILY_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Daily AI limit reached, try tomorrow" });
          return;
        }
      }
      throw limitError;
    }

    const { topic, band, target, persona } = req.body ?? {};

    if (!topic || typeof topic !== "string" || topic.trim().length < 3) {
      res.status(400).json({ error: "Invalid topic" });
      return;
    }

    if (!target || typeof target !== "string" || target.trim().length < 2) {
      res.status(400).json({ error: "Invalid target" });
      return;
    }

    const normalizedBand: Band =
      band === "intermediate" || band === "advanced" ? band : "basic";

    const learnerState = await updateLearnerState(authContext.userId, {
      level_band: normalizedBand,
      target: target.trim(),
    });

    const plan: AdaptivePlanDraft = await getOpenAI().generateAdaptivePlanDraft({
      topic: topic.trim(),
      band: normalizedBand,
      target: target.trim(),
      persona: typeof persona === "string" ? persona.trim() : undefined,
      userId: authContext.userId,
    });

    res.status(200).json({
      plan,
      learnerState,
    });
  } catch (error) {
    logger.error("adaptivePlanDraft error:", error);
    res.status(500).json({
      error: error instanceof Error ? error.message : "Internal server error",
    });
  }
});

export const adaptiveModuleGenerate = onRequest({ cors: true, timeoutSeconds: 300, memory: "512MiB" }, async (req, res) => {
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

    const rateKey = `${resolveRateLimitKey(req, authContext.userId)}:adaptive_module`;
    try {
      await enforceRateLimit({
        key: rateKey,
        limit: 8,
        windowSeconds: 600,
        userId: authContext.userId,
        userDailyCap: DAILY_AI_CAP,
      });
    } catch (limitError) {
      if (limitError instanceof Error) {
        if (limitError.message === "RATE_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Too many module requests" });
          return;
        }
        if (limitError.message === "DAILY_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Daily AI limit reached, try tomorrow" });
          return;
        }
      }
      throw limitError;
    }

    const { topic, moduleNumber, focusSkills } = req.body ?? {};

    if (!topic || typeof topic !== "string" || topic.trim().length < 3) {
      res.status(400).json({ error: "Invalid topic" });
      return;
    }

    const learnerState = await loadLearnerState(authContext.userId);
    const fallbackModuleNumber =
      Math.max(0, ...(learnerState.history.passedModules ?? []), ...(learnerState.history.failedModules ?? [])) + 1;
    const resolvedModuleNumber =
      Number.isInteger(moduleNumber) && moduleNumber > 0 ? moduleNumber : fallbackModuleNumber;

    await ensurePremiumAccess(authContext.userId, resolvedModuleNumber);

    const focusList: string[] = Array.isArray(focusSkills)
      ? focusSkills.map((skill: unknown) => skill?.toString() ?? "").filter((skill: string) => skill.length > 0)
      : [];
    const deficits = focusList.length > 0 ? focusList : rankSkillDeficits(learnerState, 3);

    const moduleData: ModuleOut = await getOpenAI().generateModuleAdaptive({
      topic: topic.trim(),
      learnerState,
      nextModuleNumber: resolvedModuleNumber,
      topDeficits: deficits,
      target: learnerState.target,
      userId: authContext.userId,
    });

    res.status(200).json({
      module: moduleData,
      learnerState,
      focusSkills: deficits,
    });
  } catch (error) {
    logger.error("adaptiveModuleGenerate error:", error);
    res.status(500).json({
      error: error instanceof Error ? error.message : "Internal server error",
    });
  }
});

export const adaptiveCheckpointQuiz = onRequest({ cors: true, timeoutSeconds: 300, memory: "512MiB" }, async (req, res) => {
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

    const rateKey = `${resolveRateLimitKey(req, authContext.userId)}:adaptive_checkpoint`;
    try {
      await enforceRateLimit({
        key: rateKey,
        limit: 6,
        windowSeconds: 600,
        userId: authContext.userId,
        userDailyCap: DAILY_AI_CAP,
      });
    } catch (limitError) {
      if (limitError instanceof Error) {
        if (limitError.message === "RATE_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Too many checkpoint requests" });
          return;
        }
        if (limitError.message === "DAILY_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Daily AI limit reached, try tomorrow" });
          return;
        }
      }
      throw limitError;
    }

    const { topic, moduleNumber, skillsTargeted } = req.body ?? {};

    if (!topic || typeof topic !== "string" || topic.trim().length < 3) {
      res.status(400).json({ error: "Invalid topic" });
      return;
    }

    if (!Number.isInteger(moduleNumber) || moduleNumber <= 0) {
      res.status(400).json({ error: "moduleNumber must be a positive integer" });
      return;
    }

    const skills: string[] = Array.isArray(skillsTargeted)
      ? skillsTargeted.map((skill: unknown) => skill?.toString() ?? "").filter((skill: string) => skill.length > 0)
      : [];

    if (!skills.length) {
      res.status(400).json({ error: "skillsTargeted is required" });
      return;
    }

    const learnerState = await loadLearnerState(authContext.userId);
    const quiz: CheckpointQuiz = await getOpenAI().generateCheckpointQuiz({
      topic: topic.trim(),
      moduleNumber,
      skillsTargeted: skills,
      band: learnerState.level_band,
      userId: authContext.userId,
    });

    const answerKey: Record<string, "A" | "B" | "C" | "D"> = {};
    const skillMap: Record<string, { skillTag: string; difficulty: "easy" | "medium" | "hard" }> = {};

    quiz.items.forEach((item) => {
      answerKey[item.id] = item.correct;
      skillMap[item.id] = {
        skillTag: item.skillTag,
        difficulty: item.difficulty,
      };
    });

    await saveCheckpointMeta(authContext.userId, moduleNumber, {
      key: answerKey,
      skillMap,
      skillsTargeted: skills,
      topic: topic.trim(),
      band: learnerState.level_band,
    });

    res.status(200).json({
      quiz,
      learnerState,
    });
  } catch (error) {
    logger.error("adaptiveCheckpointQuiz error:", error);
    res.status(500).json({
      error: error instanceof Error ? error.message : "Internal server error",
    });
  }
});

export const adaptiveEvaluateCheckpoint = onRequest({ cors: true, timeoutSeconds: 300, memory: "512MiB" }, async (req, res) => {
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

    const rateKey = `${resolveRateLimitKey(req, authContext.userId)}:adaptive_evaluate`;
    try {
      await enforceRateLimit({
        key: rateKey,
        limit: 12,
        windowSeconds: 600,
        userId: authContext.userId,
        userDailyCap: DAILY_AI_CAP,
      });
    } catch (limitError) {
      if (limitError instanceof Error) {
        if (limitError.message === "RATE_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Too many evaluation requests" });
          return;
        }
        if (limitError.message === "DAILY_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Daily AI limit reached, try tomorrow" });
          return;
        }
      }
      throw limitError;
    }

    const { moduleNumber, answers, skillsTargeted } = req.body ?? {};

    if (!Number.isInteger(moduleNumber) || moduleNumber <= 0) {
      res.status(400).json({ error: "moduleNumber must be a positive integer" });
      return;
    }

    if (!Array.isArray(answers) || answers.length === 0) {
      res.status(400).json({ error: "answers array is required" });
      return;
    }

    const normalizedAnswers = answers
      .map((entry: any) => ({
        id: entry?.id?.toString() ?? "",
        choice: typeof entry?.choice === "string" ? entry.choice.toUpperCase().trim() : "",
      }))
      .filter((entry: { id: string; choice: string }) => entry.id && ["A", "B", "C", "D"].includes(entry.choice));

    if (!normalizedAnswers.length) {
      res.status(400).json({ error: "answers must include id and choice" });
      return;
    }

    const checkpointMeta = await readCheckpointMeta(authContext.userId, moduleNumber);
    if (!checkpointMeta) {
      res.status(404).json({ error: "Checkpoint not found or expired" });
      return;
    }

    const learnerState = await loadLearnerState(authContext.userId);
    const skills: string[] =
      Array.isArray(skillsTargeted) && skillsTargeted.length
        ? skillsTargeted.map((skill: unknown) => skill?.toString() ?? "").filter((skill: string) => skill.length > 0)
        : checkpointMeta.skillsTargeted.length > 0
          ? checkpointMeta.skillsTargeted
          : Array.from(new Set(Object.values(checkpointMeta.skillMap).map((meta) => meta.skillTag)));

    const evaluation: EvaluationResult = await getOpenAI().evaluateCheckpoint({
      previousMastery: learnerState.skill_mastery,
      answers: normalizedAnswers,
      key: checkpointMeta.key,
      skillMap: checkpointMeta.skillMap,
      targetedSkills: skills,
      userId: authContext.userId,
      moduleNumber,
    });

    const passedSet = new Set(learnerState.history.passedModules ?? []);
    const failedSet = new Set(learnerState.history.failedModules ?? []);

    if (evaluation.recommendation === "advance") {
      passedSet.add(moduleNumber);
      failedSet.delete(moduleNumber);
    } else {
      failedSet.add(moduleNumber);
      passedSet.delete(moduleNumber);
    }

    const combinedErrors = Array.from(
      new Set([...(evaluation.weakSkills ?? []), ...(learnerState.history.commonErrors ?? [])]),
    ).slice(0, 10);

    const updatedState = await updateLearnerState(authContext.userId, {
      skill_mastery: evaluation.updatedMastery,
      history: {
        passedModules: Array.from(passedSet),
        failedModules: Array.from(failedSet),
        commonErrors: combinedErrors,
      },
    });

    let action: "advance" | "booster" | "replan";
    if (evaluation.score < 50) {
      action = "replan";
    } else if (evaluation.recommendation === "advance") {
      action = "advance";
    } else {
      action = "booster";
    }

    try {
      await checkpointDoc(authContext.userId, moduleNumber).delete();
    } catch (cleanupError) {
      logger.warn("Failed to delete checkpoint doc", {
        userId: authContext.userId,
        moduleNumber,
        error: cleanupError instanceof Error ? cleanupError.message : String(cleanupError),
      });
    }

    res.status(200).json({
      result: evaluation,
      learnerState: updatedState,
      action,
    });
  } catch (error) {
    logger.error("adaptiveEvaluateCheckpoint error:", error);
    res.status(500).json({
      error: error instanceof Error ? error.message : "Internal server error",
    });
  }
});

export const adaptiveBooster = onRequest({ cors: true, timeoutSeconds: 300, memory: "512MiB" }, async (req, res) => {
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

    const rateKey = `${resolveRateLimitKey(req, authContext.userId)}:adaptive_booster`;
    try {
      await enforceRateLimit({
        key: rateKey,
        limit: 6,
        windowSeconds: 600,
        userId: authContext.userId,
        userDailyCap: DAILY_AI_CAP,
      });
    } catch (limitError) {
      if (limitError instanceof Error) {
        if (limitError.message === "RATE_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Too many booster requests" });
          return;
        }
        if (limitError.message === "DAILY_LIMIT_EXCEEDED") {
          res.status(429).json({ error: "Daily AI limit reached, try tomorrow" });
          return;
        }
      }
      throw limitError;
    }

    const { topic, moduleNumber, weakSkills } = req.body ?? {};

    if (!topic || typeof topic !== "string" || topic.trim().length < 3) {
      res.status(400).json({ error: "Invalid topic" });
      return;
    }

    if (!moduleNumber || typeof moduleNumber !== "number") {
      res.status(400).json({ error: "Invalid moduleNumber" });
      return;
    }

    // Check booster attempts for this module (max 3)
    const attemptState = await getGateAttemptState(authContext.userId, moduleNumber);
    if (!attemptState.practiceUnlocked && attemptState.attempts >= 3) {
      res.status(403).json({
        error: "Maximum booster attempts reached (3)",
        attempts: attemptState.attempts,
      });
      return;
    }

    const learnerState = await loadLearnerState(authContext.userId);

    const incomingWeak: string[] = Array.isArray(weakSkills)
      ? weakSkills.map((skill: unknown) => skill?.toString() ?? "").filter((skill: string) => skill.length > 0)
      : [];

    const fallbackWeak = rankSkillDeficits(learnerState, 3).filter(
      (skill) => (learnerState.skill_mastery[skill] ?? 0) < 0.6,
    );

    const skillsForBooster = incomingWeak.length > 0 ? incomingWeak : fallbackWeak;

    if (!skillsForBooster.length) {
      res.status(400).json({ error: "No weak skills available for booster" });
      return;
    }

    const booster = await getOpenAI().generateRemedialBooster({
      topic: topic.trim(),
      weakSkills: skillsForBooster,
      userId: authContext.userId,
    });

    const updatedState = await updateLearnerState(authContext.userId, {
      history: {
        passedModules: learnerState.history.passedModules,
        failedModules: learnerState.history.failedModules,
        commonErrors: Array.from(
          new Set([...skillsForBooster, ...(learnerState.history.commonErrors ?? [])]),
        ).slice(0, 10),
      },
    });

    res.status(200).json({
      booster,
      learnerState: updatedState,
      attemptsRemaining: 3 - (attemptState.attempts + 1),
    });
  } catch (error) {
    logger.error("adaptiveBooster error:", error);
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
