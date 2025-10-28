import { https, logger } from "firebase-functions/v2";
import type { Request, Response } from "express";
import { randomUUID } from "node:crypto";
import { initializeApp } from "firebase-admin/app";
import { getAuth, type Auth } from "firebase-admin/auth";
import {
  getFirestore,
  Timestamp,
  type DocumentReference,
} from "firebase-admin/firestore";
import { z } from "zod";

// Initialise Admin SDK once per instance to reuse connections.
const app = initializeApp();
const db = getFirestore(app, "aelion");
const defaultAuthClient = getAuth(app);
let authClient: Auth = defaultAuthClient;

const MAX_BODY_BYTES = 1 * 1024 * 1024;
const PROVIDER_LOG_MAX_CHARS = 512;

const emulatorFlag = (process.env.FUNCTIONS_EMULATOR ?? "")
  .toString()
  .toLowerCase();
const isEmulatorEnv = emulatorFlag === "true" || emulatorFlag === "1";
const allowedOriginsList = (process.env.ALLOWED_ORIGINS ?? "")
  .split(",")
  .map((origin) => origin.trim())
  .filter((origin) => origin.length > 0);
const allowedOriginsSet = new Set(allowedOriginsList);
const allowAllOrigins = isEmulatorEnv || allowedOriginsSet.size === 0;

const outlineRequestSchema = z.object({
  topic: z
    .string()
    .trim()
    .min(3, "Topic must be at least 3 characters long."),
  depth: z.enum(["intro", "medium", "deep"]),
  lang: z.preprocess(
    (value) =>
      typeof value === "string" ? value.trim().toLowerCase() : value,
    z.string().min(2, "Language must be at least 2 characters long.").default("en")
  ),
  band: z.enum(["beginner", "intermediate", "advanced"]).optional(),
});

const TtlDuration = {
  intro: 7 * 24 * 60 * 60,
  medium: 3 * 24 * 60 * 60,
  deep: 1 * 24 * 60 * 60,
} as const;

const QUIZ_RATE_WINDOW_MS = 5 * 60 * 1000;
const QUIZ_SESSION_TTL_MS = 60 * 60 * 1000;
const QUIZ_NUM_QUESTIONS = 10;
const QUIZ_CHOICES_PER_QUESTION = 4;
const HAS_OPENAI_KEY = Boolean(process.env.OPENAI_API_KEY?.trim());

const SEARCH_EVENT_COOLDOWN_MS = 30 * 1000;
const TRENDING_WINDOW_MS = 24 * 60 * 60 * 1000;
const TRENDING_RESULT_LIMIT = 20;
const TRENDING_MAX_EVENTS_TO_SCAN = 500;

type PlacementBand = "beginner" | "intermediate" | "advanced";

const bandToDepthMap: Record<PlacementBand, OutlineRequest["depth"]> = {
  beginner: "intro",
  intermediate: "medium",
  advanced: "deep",
};

const depthToBandMap: Record<OutlineRequest["depth"], PlacementBand> = {
  intro: "beginner",
  medium: "intermediate",
  deep: "advanced",
};

const quizStartSchema = z.object({
  topic: z
    .string()
    .trim()
    .min(3, "Topic must be at least 3 characters long."),
  lang: z.enum(["en", "es"]),
});

const quizGradeSchema = z.object({
  quizId: z.string().trim().min(6, "quizId must be provided."),
  answers: z
    .array(
      z.object({
        id: z.string().trim().min(1, "answer id is required."),
        choiceIndex: z.number().int().min(0).max(QUIZ_CHOICES_PER_QUESTION - 1),
      })
    )
    .min(1, "At least one answer must be provided."),
});

const trackSearchSchema = z.object({
  topic: z.string().trim().min(2, "Topic must be at least two characters."),
  lang: z.enum(["en", "es"]).default("en"),
});

const aiQuizResponseSchema = z.object({
  questions: z
    .array(
      z.object({
        id: z.string().trim().min(1),
        text: z.string().trim().min(5),
        choices: z.array(z.string().trim().min(1)).length(QUIZ_CHOICES_PER_QUESTION),
        correctAnswerIndex: z.number().int().min(0).max(QUIZ_CHOICES_PER_QUESTION - 1),
      })
    )
    .min(QUIZ_NUM_QUESTIONS),
});

type OutlineRequest = z.infer<typeof outlineRequestSchema>;

type CacheDocument = {
  outline?: unknown;
  createdAt?: Timestamp;
  expiresAt?: Timestamp | { _seconds?: number; _nanoseconds?: number } | null;
  lang?: string;
  depth?: OutlineRequest["depth"];
  topic?: string;
  ttlSec?: number;
  version?: number;
  band?: PlacementBand;
};

type StoredQuizQuestion = {
  id: string;
  text: string;
  choices: string[];
  correctAnswerIndex: number;
};

type SearchEventDoc = {
  userId: string;
  topic: string;
  topicKey: string;
  lang: "en" | "es";
  ts: Timestamp;
};

type SearchEventMetaDoc = {
  userId: string;
  topicKey: string;
  lang: "en" | "es";
  lastTs: Timestamp;
};

class CooldownError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "CooldownError";
  }
}

type QuizSessionDoc = {
  quizId: string;
  userId: string;
  topic: string;
  lang: "en" | "es";
  questions: StoredQuizQuestion[];
  createdAt: Timestamp;
  expiresAt: Timestamp;
};

function getRequestOrigin(req: Request): string | undefined {
  const origin = req.headers.origin;
  return typeof origin === "string" ? origin : undefined;
}

function resolveCorsOrigin(origin: string | undefined): string {
  if (allowAllOrigins) {
    return "*";
  }
  if (!origin || origin.length === 0) {
    return "null";
  }
  return allowedOriginsSet.has(origin) ? origin : "null";
}

function applyCors(res: Response, origin: string | undefined) {
  const resolvedOrigin = resolveCorsOrigin(origin);
  res.setHeader("Access-Control-Allow-Origin", resolvedOrigin);
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.setHeader(
    "Access-Control-Allow-Headers",
    "Content-Type, Authorization, X-Trace-Id"
  );
  res.setHeader("Access-Control-Max-Age", "3600");
  res.setHeader("Vary", "Origin");
}

function handlePreflight(req: Request, res: Response, origin: string | undefined) {
  if (req.method !== "OPTIONS") {
    return false;
  }
  applyCors(res, origin);
  res.status(204).send();
  return true;
}

function sendError(
  res: Response,
  origin: string | undefined,
  status: number,
  code: string,
  message: string,
  extras?: Record<string, unknown>
) {
  applyCors(res, origin);
  res.status(status).json({
    error: code,
    message,
    ...(extras ?? {}),
  });
}

type ParsedPayloadResult =
  | { success: true; data: unknown }
  | {
      success: false;
      status: number;
      code: string;
      message: string;
      details?: Record<string, unknown>;
    };

function parseJsonPayload(req: Request): ParsedPayloadResult {
  const payloadTooLarge: ParsedPayloadResult = {
    success: false as const,
    status: 413,
    code: "PayloadTooLarge",
    message: "Request body cannot exceed 1MB.",
    details: {
      limitBytes: MAX_BODY_BYTES,
    },
  };

  const requestWithRawBody = req as Request & { rawBody?: Buffer };
  const rawBodyBuffer = requestWithRawBody.rawBody;
  if (rawBodyBuffer && rawBodyBuffer.length > MAX_BODY_BYTES) {
    return payloadTooLarge;
  }

  const contentLengthHeader = req.headers["content-length"];
  const declaredLength = Array.isArray(contentLengthHeader)
    ? Number.parseInt(contentLengthHeader[0] ?? "", 10)
    : typeof contentLengthHeader === "string"
      ? Number.parseInt(contentLengthHeader, 10)
      : undefined;
  if (
    typeof declaredLength === "number" &&
    Number.isFinite(declaredLength) &&
    declaredLength > MAX_BODY_BYTES
  ) {
    return payloadTooLarge;
  }

  if (req.body && typeof req.body === "object" && !Buffer.isBuffer(req.body)) {
    return { success: true as const, data: req.body };
  }

  let raw: string | undefined;
  if (typeof req.body === "string") {
    if (Buffer.byteLength(req.body, "utf8") > MAX_BODY_BYTES) {
      return payloadTooLarge;
    }
    raw = req.body;
  } else if (Buffer.isBuffer(req.body)) {
    if (req.body.length > MAX_BODY_BYTES) {
      return payloadTooLarge;
    }
    raw = req.body.toString("utf8");
  } else if (rawBodyBuffer && rawBodyBuffer.length > 0) {
    raw = rawBodyBuffer.toString("utf8");
  }

  if (!raw || raw.trim().length === 0) {
    return {
      success: false as const,
      status: 400,
      code: "EmptyBody",
      message: "Request body cannot be empty.",
    };
  }

  try {
    const data = JSON.parse(raw);
    return { success: true as const, data };
  } catch (error) {
    const errorMessage =
      error instanceof Error ? error.message : "Unknown JSON parse error";
    return {
      success: false as const,
      status: 400,
      code: "InvalidJson",
      message: "Invalid JSON payload.",
      details: { cause: errorMessage },
    };
  }
}

function createCacheKey({
  topic,
  depth,
  lang,
  band,
}: {
  topic: string;
  depth: OutlineRequest["depth"];
  lang: string;
  band?: PlacementBand;
}) {
  const normalizedLang = lang.trim().toLowerCase();
  const normalizedDepth = band ? bandToDepthMap[band] : depth;
  const cacheSegment = band ?? normalizedDepth;
  return `outline-${normalizedLang}-${cacheSegment}-${topic
    .toLowerCase()
    .replace(/\s+/g, "-")
    .replace(/[^a-z0-9\-]/g, "")}`;
}

function coerceTimestamp(value: unknown) {
  if (!value) {
    return null;
  }

  if (value instanceof Timestamp) {
    return value;
  }

  if (
    typeof (value as { toMillis?: () => number }).toMillis === "function" &&
    Number.isFinite((value as { toMillis: () => number }).toMillis())
  ) {
    try {
      return Timestamp.fromMillis(
        (value as { toMillis: () => number }).toMillis()
      );
    } catch {
      // Fall through to other coercions.
    }
  }

  const seconds =
    (value as { _seconds?: number })._seconds ??
    (value as { seconds?: number }).seconds;
  if (typeof seconds === "number" && Number.isFinite(seconds)) {
    return Timestamp.fromMillis(seconds * 1000);
  }

  if (typeof value === "number" && Number.isFinite(value)) {
    return Timestamp.fromMillis(value);
  }

  if (typeof value === "string") {
    const millis = Number.parseInt(value, 10);
    if (Number.isFinite(millis)) {
      return Timestamp.fromMillis(millis);
    }
  }

  return null;
}

function normalizeSearchLang(value: string | undefined): "en" | "es" {
  const normalized = value?.trim().toLowerCase();
  return normalized === "es" ? "es" : "en";
}

function normalizeTopicKey(topic: string): string {
  return topic
    .trim()
    .toLowerCase()
    .replace(/\s+/g, "-")
    .replace(/[^a-z0-9\-]/g, "");
}

export function extractBearerToken(req: Request): string | null {
  const headerValue = req.headers.authorization ?? req.headers.Authorization;
  const normalizedHeader = Array.isArray(headerValue)
    ? headerValue[0]
    : headerValue;
  if (typeof normalizedHeader !== "string") {
    return null;
  }

  const match = normalizedHeader.match(/^Bearer\s+(.+)$/i);
  if (!match) {
    return null;
  }

  const token = match[1]?.trim();
  return token && token.length > 0 ? token : null;
}

export async function resolveUserId(req: Request): Promise<string> {
  const token = extractBearerToken(req);
  if (!token) {
    return "anonymous";
  }

  try {
    const decoded = await authClient.verifyIdToken(token);
    const uid = decoded?.uid?.trim();
    return uid && uid.length > 0 ? uid : "anonymous";
  } catch (error) {
    const errorMessage =
      error instanceof Error ? error.message : "Unknown token verification error";
    logger.warn("ID token verification failed", { errorMessage });
    return "anonymous";
  }
}

export function setAuthClientForTesting(fakeAuth: Auth) {
  authClient = fakeAuth;
}

export function resetAuthClientForTesting() {
  authClient = defaultAuthClient;
}

function sanitizeProviderPayload(payload: string): string {
  const truncated =
    payload.length > PROVIDER_LOG_MAX_CHARS
      ? `${payload.slice(0, PROVIDER_LOG_MAX_CHARS)}...`
      : payload;
  return truncated
    .replace(
      /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/gi,
      "[REDACTED_EMAIL]"
    )
    .replace(
      /\b(\+?\d{1,2}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}\b/g,
      "[REDACTED_PHONE]"
    );
}

export const placementQuizStart = https.onRequest(
  {
    cors: false,
    region: "us-east4",
  },
  async (req, res) => {
    const origin = getRequestOrigin(req);
    if (handlePreflight(req, res, origin)) {
      return;
    }

    applyCors(res, origin);
    if (req.method !== "POST") {
      sendError(res, origin, 405, "MethodNotAllowed", "Only POST is supported.");
      return;
    }

    const payload = parseJsonPayload(req);
    if (!payload.success) {
      logger.warn("Received invalid JSON payload", {
        code: payload.code,
        message: payload.message,
        details: payload.details,
      });

      sendError(res, origin, payload.status, payload.code, payload.message, {
        details: payload.details,
      });
      return;
    }

    const parseResult = quizStartSchema.safeParse(payload.data);
    if (!parseResult.success) {
      const flattened = parseResult.error.flatten();
      logger.warn("Quiz start validation failed", { errors: flattened });
      sendError(res, origin, 400, "ValidationError", "Request validation failed.", {
        errors: flattened,
      });
      return;
    }

    const { topic, lang } = parseResult.data;
    const userId = await resolveUserId(req);

    try {
      const nowMillis = Date.now();
      const nowTimestamp = Timestamp.fromMillis(nowMillis);
      const cutoff = Timestamp.fromMillis(nowMillis - QUIZ_RATE_WINDOW_MS);

      const recentSessions = await db
        .collection("quiz_sessions")
        .where("userId", "==", userId)
        .where("createdAt", ">=", cutoff)
        .limit(1)
        .get();

      if (!recentSessions.empty) {
        logger.warn("Placement quiz rate limited", { userId, topic });
        sendError(res, origin, 429, "TooManyRequests", "Please wait a few minutes before starting another placement quiz.");
        return;
      }

      const questions = await generatePlacementQuizQuestions(topic, lang);
      const quizId = randomUUID();
      const expiresAt = Timestamp.fromMillis(nowMillis + QUIZ_SESSION_TTL_MS);

      const sessionDoc: QuizSessionDoc = {
        quizId,
        userId,
        topic,
        lang,
        questions,
        createdAt: nowTimestamp,
        expiresAt,
      };

      await db.collection("quiz_sessions").doc(quizId).set(sessionDoc);

      logger.info("Placement quiz started", {
        quizId,
        userId,
        topic,
        lang,
        questionCount: questions.length,
      });

      const publicQuestions = questions.map((question) => ({
        id: question.id,
        text: question.text,
        choices: question.choices,
      }));

      res.status(200).json({
        quizId,
        expiresAt: expiresAt.toMillis(),
        policy: {
          maxMinutes: 15,
          numQuestions: QUIZ_NUM_QUESTIONS,
        },
        questions: publicQuestions,
      });
    } catch (error) {
      logger.error("Failed to start placement quiz", {
        error,
        topic,
        userId,
      });
      sendError(res, origin, 500, "InternalError", "Failed to start placement quiz.");
    }
  }
);

export const placementQuizGrade = https.onRequest(
  {
    cors: false,
    region: "us-east4",
  },
  async (req, res) => {
    const origin = getRequestOrigin(req);
    if (handlePreflight(req, res, origin)) {
      return;
    }

    applyCors(res, origin);
    if (req.method !== "POST") {
      sendError(res, origin, 405, "MethodNotAllowed", "Only POST is supported.");
      return;
    }

    const payload = parseJsonPayload(req);
    if (!payload.success) {
      logger.warn("Received invalid JSON payload while grading quiz", {
        code: payload.code,
        message: payload.message,
        details: payload.details,
      });

      sendError(res, origin, payload.status, payload.code, payload.message, {
        details: payload.details,
      });
      return;
    }

    const parseResult = quizGradeSchema.safeParse(payload.data);
    if (!parseResult.success) {
      const flattened = parseResult.error.flatten();
      logger.warn("Quiz grade validation failed", { errors: flattened });
      sendError(res, origin, 400, "ValidationError", "Request validation failed.", {
        errors: flattened,
      });
      return;
    }

    const { quizId, answers } = parseResult.data;
    const requestingUserId = await resolveUserId(req);

    try {
      const sessionSnap = await db.collection("quiz_sessions").doc(quizId).get();
      if (!sessionSnap.exists) {
        sendError(res, origin, 404, "NotFound", "Quiz session not found.");
        return;
      }

      const sessionData = sessionSnap.data() as QuizSessionDoc | undefined;
      if (!sessionData) {
        sendError(res, origin, 404, "NotFound", "Quiz session is unavailable.");
        return;
      }

      const expiresAt = coerceTimestamp(sessionData.expiresAt);
      if (!expiresAt || expiresAt.toMillis() <= Date.now()) {
        sendError(res, origin, 404, "NotFound", "Quiz session has expired.");
        return;
      }

      const questionMap = new Map(sessionData.questions.map((question) => [question.id, question]));
      let correctAnswers = 0;
      for (const answer of answers) {
        const question = questionMap.get(answer.id);
        if (!question) {
          continue;
        }
        if (question.correctAnswerIndex === answer.choiceIndex) {
          correctAnswers += 1;
        }
      }

      const totalQuestions =
        sessionData.questions.length > 0 ? sessionData.questions.length : QUIZ_NUM_QUESTIONS;
      const scorePct = Math.round((correctAnswers / totalQuestions) * 100);

      let band: PlacementBand;
      if (scorePct >= 80) {
        band = "advanced";
      } else if (scorePct >= 50) {
        band = "intermediate";
      } else {
        band = "beginner";
      }

      const suggestedDepth = bandToDepthMap[band];

      const recommendRegenerate = await shouldRecommendRegenerate({
        topic: sessionData.topic,
        lang: sessionData.lang,
        band,
        depth: suggestedDepth,
      });

      logger.info("Placement quiz graded", {
        quizId,
        userId: sessionData.userId,
        requestedBy: requestingUserId,
        band,
        scorePct,
        recommendRegenerate,
      });

      res.status(200).json({
        band,
        scorePct,
        recommendRegenerate,
        suggestedDepth,
      });
    } catch (error) {
      logger.error("Failed to grade placement quiz", {
        error,
        quizId,
        requestedBy: requestingUserId,
      });
      sendError(res, origin, 500, "InternalError", "Failed to grade placement quiz.");
    }
  }
);

export const outline = https.onRequest(
  {
    cors: false,
    region: "us-east4", // AGREGA ESTO
  },
  async (req, res) => {
    const origin = getRequestOrigin(req);
    if (handlePreflight(req, res, origin)) {
      return;
    }

    applyCors(res, origin);
    if (req.method !== "POST") {
      sendError(res, origin, 405, "MethodNotAllowed", "Only POST is supported.");
      return;
    }

    const payload = parseJsonPayload(req);
    if (!payload.success) {
      logger.warn("Received invalid JSON payload", {
        code: payload.code,
        message: payload.message,
        details: payload.details,
      });

      sendError(res, origin, payload.status, payload.code, payload.message, {
        details: payload.details,
      });
      return;
    }

    const parseResult = outlineRequestSchema.safeParse(payload.data);
    if (!parseResult.success) {
      const flattened = parseResult.error.flatten();
      logger.warn("Request validation failed", { errors: flattened });
      sendError(res, origin, 400, "ValidationError", "Request validation failed.", {
        errors: flattened,
      });
      return;
    }

    const { topic, lang } = parseResult.data;
    const requestedDepth = parseResult.data.depth;
    const requestedBand = parseResult.data.band;
    const normalizedDepth = requestedBand
      ? bandToDepthMap[requestedBand]
      : requestedDepth;
    const effectiveBand = requestedBand ?? depthToBandMap[normalizedDepth];
    const userId = await resolveUserId(req);
    const cacheKey = createCacheKey({
      topic,
      depth: normalizedDepth,
      lang,
      band: requestedBand,
    });
    const cacheRef = db.collection("cache_outline").doc(cacheKey);
    const now = Timestamp.now();
    const nowMillis = now.toMillis();

    try {
      const cachedOutline = await readFromCache(cacheRef, nowMillis);
      if (cachedOutline) {
        logger.info("outline cache hit", {
          cacheKey,
          userId,
          ttlRemainingMs: cachedOutline.expiresAtMillis - nowMillis,
        });

        await logObservability({
          topic,
          depth: normalizedDepth,
          lang,
          userId,
          cached: true,
          cacheKey,
          outlineSize: Array.isArray(cachedOutline.outline)
            ? cachedOutline.outline.length
            : undefined,
          band: effectiveBand,
        });

        res.status(200).json({
          source: "cache",
          outline: cachedOutline.outline,
          cacheExpiresAt: cachedOutline.expiresAtMillis,
          band: effectiveBand,
        });
        return;
      }
    } catch (error) {
      logger.error("Cache lookup failed; continuing with fresh generation", {
        cacheKey,
        topic,
        depth: normalizedDepth,
        error,
      });
    }

    try {
      logger.info("outline cache miss", {
        cacheKey,
        userId,
        topic,
        depth: normalizedDepth,
        band: effectiveBand,
      });

      const outlinePayload = generateDemoOutline(topic, normalizedDepth);
      const expiresAt = Timestamp.fromMillis(
        nowMillis + TtlDuration[normalizedDepth] * 1000
      );

      await writeCache(cacheRef, {
        outline: outlinePayload,
        createdAt: now,
        expiresAt,
        lang,
        depth: normalizedDepth,
        topic,
        ttlSec: TtlDuration[normalizedDepth],
        version: 1,
        band: effectiveBand,
      });

      await logObservability({
        topic,
        depth: normalizedDepth,
        lang,
        userId,
        cached: false,
        cacheKey,
        outlineSize: outlinePayload.length,
        estCostUsd: 0.0001,
        tokensIn: topic.length * 2,
        tokensOut: JSON.stringify(outlinePayload).length,
        band: effectiveBand,
      });

      res.status(200).json({
        source: "fresh",
        outline: outlinePayload,
        cacheExpiresAt: expiresAt.toMillis(),
        band: effectiveBand,
      });
    } catch (error) {
      logger.error("Error processing /outline request", {
        error,
        topic,
        userId,
      });
      sendError(res, origin, 500, "InternalError", "Failed to generate outline.");
    }
  }
);

// Alias para rewrites /api/** en Hosting
export const api = outline;

export const trackSearch = https.onRequest(
  {
    cors: false,
    region: "us-east4",
  },
  async (req, res) => {
    const origin = getRequestOrigin(req);
    if (handlePreflight(req, res, origin)) {
      return;
    }

    applyCors(res, origin);
    if (req.method !== "POST") {
      sendError(res, origin, 405, "MethodNotAllowed", "Only POST is supported.");
      return;
    }

    const payload = parseJsonPayload(req);
    if (!payload.success) {
      logger.warn("Received invalid JSON payload for trackSearch", {
        code: payload.code,
        message: payload.message,
        details: payload.details,
      });

      sendError(res, origin, payload.status, payload.code, payload.message, {
        details: payload.details,
      });
      return;
    }

    const validation = trackSearchSchema.safeParse(payload.data);
    if (!validation.success) {
      const flattened = validation.error.flatten();
      logger.warn("trackSearch validation failed", { errors: flattened });
      sendError(res, origin, 400, "ValidationError", "Request validation failed.", {
        errors: flattened,
      });
      return;
    }

    const { topic, lang } = validation.data;
    const normalizedTopic = topic.trim();
    const topicKey = normalizeTopicKey(normalizedTopic);
    if (!topicKey) {
      sendError(
        res,
        origin,
        400,
        "ValidationError",
        "Topic must contain alphanumeric characters."
      );
      return;
    }

    const searchLang = normalizeSearchLang(lang);
    const userId = await resolveUserId(req);

    const nowMillis = Date.now();
    const nowTimestamp = Timestamp.fromMillis(nowMillis);
    const metaKey = `${userId}|${topicKey}|${searchLang}`;
    const metaRef = db.collection("search_events_meta").doc(metaKey);
    const eventRef = db.collection("search_events").doc();

    try {
      await db.runTransaction(async (tx) => {
        const metaSnap = await tx.get(metaRef);
        if (metaSnap.exists) {
          const metaData = metaSnap.data() as Partial<SearchEventMetaDoc> | undefined;
          const lastTs = metaData?.lastTs ? coerceTimestamp(metaData.lastTs) : null;
          if (lastTs && nowMillis - lastTs.toMillis() < SEARCH_EVENT_COOLDOWN_MS) {
            throw new CooldownError("Search tracking cooldown active.");
          }
        }

        tx.set(
          metaRef,
          {
            userId,
            topicKey,
            lang: searchLang,
            lastTs: nowTimestamp,
          },
          { merge: true }
        );

        tx.set(
          eventRef,
          {
            userId,
            topic: normalizedTopic,
            topicKey,
            lang: searchLang,
            ts: nowTimestamp,
          } as SearchEventDoc
        );
      });

      logger.info("Recorded search event", {
        userId,
        topicKey,
        lang: searchLang,
      });

      res.status(202).json({
        recorded: true,
        cooldownSeconds: SEARCH_EVENT_COOLDOWN_MS / 1000,
      });
    } catch (error) {
      if (error instanceof CooldownError) {
        logger.debug("trackSearch rate limited", { userId, topicKey });
        sendError(res, origin, 429, "TooManyRequests", "Please wait before tracking this topic again.");
        return;
      }

      logger.error("Failed to record search event", {
        error,
        userId,
        topic: normalizedTopic,
        lang: searchLang,
      });
      sendError(res, origin, 500, "InternalError", "Failed to record search event.");
    }
  }
);

export const trending = https.onRequest(
  {
    cors: false,
    region: "us-east4",
  },
  async (req, res) => {
    const origin = getRequestOrigin(req);
    if (handlePreflight(req, res, origin)) {
      return;
    }

    applyCors(res, origin);
    if (req.method !== "GET") {
      sendError(res, origin, 405, "MethodNotAllowed", "Only GET is supported.");
      return;
    }

    const rawLangParam = Array.isArray(req.query.lang) ? req.query.lang[0] : req.query.lang;
    const langParam =
      typeof rawLangParam === "string" ? rawLangParam.trim().toLowerCase() : "";
    if (!langParam) {
      sendError(res, origin, 400, "ValidationError", 'Query parameter "lang" is required.');
      return;
    }
    const normalizedLang = normalizeSearchLang(langParam);

    const cutoffMillis = Date.now() - TRENDING_WINDOW_MS;

    try {
      const snapshot = await db
        .collection("search_events")
        .where("lang", "==", normalizedLang)
        .orderBy("ts", "desc")
        .limit(TRENDING_MAX_EVENTS_TO_SCAN)
        .get();

      const counts = new Map<
        string,
        { count: number; latestTopic: string; latestTs: number }
      >();

      for (const doc of snapshot.docs) {
        const data = doc.data() as Partial<SearchEventDoc> | undefined;
        if (!data) {
          continue;
        }

        const ts = coerceTimestamp(data.ts);
        if (!ts || ts.toMillis() < cutoffMillis) {
          continue;
        }

        const topicRaw = data.topic?.toString() ?? "";
        const trimmedTopic = topicRaw.trim();
        if (!trimmedTopic) {
          continue;
        }

        const topicKey =
          typeof data.topicKey === "string" && data.topicKey.trim().length > 0
            ? data.topicKey
            : normalizeTopicKey(trimmedTopic);
        if (!topicKey) {
          continue;
        }

        const existing = counts.get(topicKey);
        const tsMillis = ts.toMillis();
        if (existing) {
          existing.count += 1;
          if (tsMillis > existing.latestTs) {
            existing.latestTs = tsMillis;
            existing.latestTopic = trimmedTopic;
          }
        } else {
          counts.set(topicKey, {
            count: 1,
            latestTopic: trimmedTopic,
            latestTs: tsMillis,
          });
        }
      }

      const topics = Array.from(counts.entries())
        .map(([topicKey, value]) => ({
          topicKey,
          topic: value.latestTopic,
          count: value.count,
          latestTs: value.latestTs,
        }))
        .sort((a, b) => {
          if (b.count !== a.count) {
            return b.count - a.count;
          }
          return b.latestTs - a.latestTs;
        })
        .slice(0, TRENDING_RESULT_LIMIT)
        .map(({ topicKey, topic, count }) => ({
          topicKey,
          topic,
          count,
        }));

      logger.info("Computed trending topics", {
        lang: normalizedLang,
        windowHours: TRENDING_WINDOW_MS / (60 * 60 * 1000),
        resultCount: topics.length,
      });

      res.status(200).json({
        lang: normalizedLang,
        windowHours: TRENDING_WINDOW_MS / (60 * 60 * 1000),
        topics,
      });
    } catch (error) {
      logger.error("Failed to compute trending topics", {
        error,
        lang: normalizedLang,
      });
      sendError(res, origin, 500, "InternalError", "Failed to compute trending topics.");
    }
  }
);

async function generatePlacementQuizQuestions(
  topic: string,
  lang: "en" | "es"
): Promise<StoredQuizQuestion[]> {
  if (!HAS_OPENAI_KEY) {
    return generateDeterministicQuizQuestions(topic, lang);
  }

  try {
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        temperature: 0.3,
        messages: [
          {
            role: "system",
            content:
              "You are a helpful learning assistant that produces multiple choice placement quizzes. " +
              "Respond ONLY with valid JSON matching the requested schema.",
          },
          {
            role: "user",
            content: [
              "Generate a placement quiz with exactly 10 multiple choice questions.",
              `Topic: ${topic}`,
              `Language: ${lang === "es" ? "Spanish" : "English"}`,
              "Each question must contain:",
              '- "id": short identifier',
              '- "text": question text in the requested language',
              '- "choices": array of 4 distinct answers in the requested language',
              "- \"correctAnswerIndex\": index (0-3) of the correct choice",
              "Return JSON: {\"questions\":[{...}]} with no extra commentary.",
            ].join("\n"),
          },
        ],
      }),
    });

    if (!response.ok) {
      const errorPayload = await response.text();
      logger.error("OpenAI quiz generation failed", {
        status: response.status,
        body: sanitizeProviderPayload(errorPayload),
      });
      return generateDeterministicQuizQuestions(topic, lang);
    }

    const raw = (await response.json()) as {
      choices?: Array<{ message?: { content?: string } }>;
    };
    const content = raw?.choices?.[0]?.message?.content;
    if (typeof content !== "string") {
      logger.warn("OpenAI response missing content; falling back to deterministic quiz");
      return generateDeterministicQuizQuestions(topic, lang);
    }

    const cleaned = content
      .replace(/```json/gi, "")
      .replace(/```/g, "")
      .trim();

    const parsed = JSON.parse(cleaned);
    const validation = aiQuizResponseSchema.safeParse(parsed);
    if (!validation.success) {
      logger.warn("AI quiz response failed validation", {
        errors: validation.error.flatten(),
      });
      return generateDeterministicQuizQuestions(topic, lang);
    }

    const aiData = validation.data;
    const aiQuestions = aiData.questions
      .slice(0, QUIZ_NUM_QUESTIONS)
      .map<StoredQuizQuestion>((question, index) => ({
        id: question.id && question.id.trim().length > 0 ? question.id : `ai-${index + 1}`,
        text: question.text,
        choices: [...question.choices],
        correctAnswerIndex: question.correctAnswerIndex,
      }));

    return aiQuestions;
  } catch (error) {
    logger.error("Exception while generating quiz questions with OpenAI", { error });
    return generateDeterministicQuizQuestions(topic, lang);
  }
}

function generateDeterministicQuizQuestions(
  topic: string,
  lang: "en" | "es"
): StoredQuizQuestion[] {
  const localized = lang === "es";
  const topicLabel = localized ? `sobre ${topic}` : `about ${topic}`;
  const basePrompt = localized ? "Pregunta" : "Question";
  const choiceTemplates = localized
    ? ["Concepto clave", "Ejemplo practico", "Situacion real", "Definicion alternativa"]
    : ["Core concept", "Practical example", "Real-world scenario", "Alternative definition"];

  return Array.from({ length: QUIZ_NUM_QUESTIONS }, (_, index) => {
    const questionNumber = index + 1;
    const choices = choiceTemplates.map(
      (template, choiceIndex) =>
        `${template} ${localized ? "para" : "for"} ${topic} (${choiceIndex + 1})`
    );
    return {
      id: `static-${questionNumber}`,
      text: `${basePrompt} ${questionNumber} ${topicLabel}`,
      choices,
      correctAnswerIndex: 0,
    };
  });
}

async function shouldRecommendRegenerate(params: {
  topic: string;
  lang: string;
  band: PlacementBand;
  depth: OutlineRequest["depth"];
}): Promise<boolean> {
  const { topic, lang, band, depth } = params;
  const normalizedLang = lang.toLowerCase();
  try {
    const primaryKey = createCacheKey({
      topic,
      depth,
      lang: normalizedLang,
      band,
    });

    const cacheCollection = db.collection("cache_outline");
    let snapshot = await cacheCollection.doc(primaryKey).get();
    if (!snapshot.exists) {
      const fallbackKey = createCacheKey({
        topic,
        depth,
        lang: normalizedLang,
      });
      if (fallbackKey !== primaryKey) {
        snapshot = await cacheCollection.doc(fallbackKey).get();
      }
      if (!snapshot.exists) {
        return true;
      }
    }

    const data = snapshot.data() as CacheDocument | undefined;
    if (!data) {
      return true;
    }

    const expiresAt = coerceTimestamp(data.expiresAt);
    if (!expiresAt || expiresAt.toMillis() <= Date.now()) {
      return true;
    }

    const cachedDepth = (data.depth ?? depth) as OutlineRequest["depth"];
    const cachedBand = data.band ?? depthToBandMap[cachedDepth];
    return cachedBand !== band;
  } catch (error) {
    logger.error("Failed to evaluate regenerate recommendation", {
      error,
      topic,
      lang,
      band,
    });
    return true;
  }
}

function generateDemoOutline(topic: string, depth: keyof typeof TtlDuration) {
  const itemCount = depth === "intro" ? 3 : depth === "medium" ? 5 : 7;
  return Array.from({ length: itemCount }, (_, i) => ({
    title: `Section ${i + 1}: Introduction to ${topic}`,
    description: `A detailed look into the basics of section ${i + 1} of ${topic}.`,
    duration_minutes: (i + 1) * 5,
  }));
}

async function logObservability(data: {
  topic: string;
  depth: keyof typeof TtlDuration;
  lang: string;
  userId?: string;
  cached: boolean;
  estCostUsd?: number;
  tokensIn?: number;
  tokensOut?: number;
  cacheKey?: string;
  outlineSize?: number;
  band?: PlacementBand;
}) {
  try {
    await db.collection("observability").add({
      route: "outline",
      ts: Timestamp.now(),
      user: data.userId ?? "anonymous",
      cached: data.cached,
      params: {
        topic: data.topic,
        depth: data.depth,
        lang: data.lang,
        band: data.band,
      },
      cost_usd: data.estCostUsd ?? 0,
      tokens_in: data.tokensIn ?? 0,
      tokens_out: data.tokensOut ?? 0,
      cache_key: data.cacheKey,
      outline_size: data.outlineSize,
    });
  } catch (error) {
    logger.error("Failed to write to observability collection", { error });
  }
}

async function readFromCache(
  cacheRef: DocumentReference<CacheDocument>,
  nowMillis: number
): Promise<{ outline: unknown[]; expiresAtMillis: number } | null> {
  try {
    const snapshot = await cacheRef.get();
    if (!snapshot.exists) {
      return null;
    }

    const data = snapshot.data() ?? {};
    const expiresAt = coerceTimestamp(data.expiresAt);
    if (!expiresAt) {
      logger.warn("Cache document missing expiresAt; treating as miss", {
        cacheRef: cacheRef.id,
      });
      return null;
    }

    if (expiresAt.toMillis() <= nowMillis) {
      logger.info("Cache document expired", { cacheRef: cacheRef.id });
      return null;
    }

    if (!Array.isArray(data.outline)) {
      logger.warn("Cache document outline payload invalid", {
        cacheRef: cacheRef.id,
        outlineType: typeof data.outline,
      });
      return null;
    }

    return {
      outline: data.outline as unknown[],
      expiresAtMillis: expiresAt.toMillis(),
    };
  } catch (error) {
    logger.error("Failed to read cache document", {
      cacheRef: cacheRef.id,
      error,
    });
    return null;
  }
}

async function writeCache(
  cacheRef: DocumentReference<CacheDocument>,
  payload: CacheDocument
): Promise<void> {
  try {
    await cacheRef.set(payload);
  } catch (error) {
    logger.error("Failed to write outline cache", {
      cacheRef: cacheRef.id,
      error,
    });
  }
}




