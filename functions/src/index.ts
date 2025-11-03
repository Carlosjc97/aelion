import { onRequest } from "firebase-functions/v2/https";
import type { Request, Response } from "express";
import { getApps, initializeApp } from "firebase-admin/app";
import { getAuth, Auth } from "firebase-admin/auth";
import { getFirestore, Firestore, Timestamp } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import * as logger from "firebase-functions/logger";
import { z } from "zod";
import { createHash } from "node:crypto";

if (!getApps().length) {
  initializeApp();
}

let authClient: Auth = getAuth();
const firestore: Firestore = getFirestore();
const storage = getStorage();

interface OutlineTemplateLesson {
  id: string;
  title: string;
  summary: string;
  objective?: string;
  type: string;
  durationMinutes: number;
}

interface OutlineTemplateModule {
  id: string;
  title: string;
  summary: string;
  lessons: OutlineTemplateLesson[];
}

interface OutlineTemplate {
  slug: string;
  topic: string;
  goal: string;
  language: string;
  estimatedHours: number;
  modules: OutlineTemplateModule[];
}

interface OutlineResolutionInput {
  topic: string;
  goal?: string;
  language: string;
  depth: string;
  band: string;
  userId: string;
}

interface OutlineResponseLesson {
  id: string;
  title: string;
  summary: string;
  objective?: string;
  type: string;
  durationMinutes: number;
  content: string;
}

interface OutlineResponseModule {
  moduleId: string;
  title: string;
  summary: string;
  lessons: OutlineResponseLesson[];
  locked: boolean;
  progress: { completed: number; total: number };
}

interface OutlineResponseBody {
  topic: string;
  goal: string;
  language: string;
  depth: string;
  band: string;
  outline: OutlineResponseModule[];
  source: string;
  estimated_hours: number;
  cacheExpiresAt: number;
  meta: Record<string, unknown>;
}

interface TrendingTopic {
  topicKey: string;
  topic: string;
  count: number;
  band?: string;
  modules?: number;
}

type AnalyticsEndpoint = "outline" | "trending";
type AnalyticsStatus = "ok" | "error" | "rate_limited";

interface AnalyticsCallCounters {
  firestoreReads: number;
  firestoreWrites: number;
  storageMetadataChecks: number;
  storageDownloads: number;
  storageReadBytes: number;
}

interface AnalyticsCostSample {
  endpoint: AnalyticsEndpoint;
  status: AnalyticsStatus;
  userType: "anonymous" | "authenticated";
  latencyMs: number;
  request: Record<string, unknown>;
  response?: Record<string, unknown>;
  counters: AnalyticsCallCounters;
  error?: string;
}

interface OutlineResolutionResult {
  body: OutlineResponseBody;
  counters: AnalyticsCallCounters;
  resolution: "firestore" | "storage" | "template";
}

interface TrendingResolutionResult {
  topics: TrendingTopic[];
  windowHours: number;
  source: string;
  counters: AnalyticsCallCounters;
  resolution: "aggregate" | "events" | "fallback";
}

const ANALYTICS_SAMPLE_RATE = Math.min(
  1,
  Math.max(0, Number(process.env.ANALYTICS_SAMPLE_RATE ?? "0.35")),
);

function createCounters(): AnalyticsCallCounters {
  return {
    firestoreReads: 0,
    firestoreWrites: 0,
    storageMetadataChecks: 0,
    storageDownloads: 0,
    storageReadBytes: 0,
  };
}

function shouldSampleAnalytics(): boolean {
  if (ANALYTICS_SAMPLE_RATE <= 0) {
    return false;
  }
  if (ANALYTICS_SAMPLE_RATE >= 1) {
    return true;
  }
  return Math.random() < ANALYTICS_SAMPLE_RATE;
}

async function logAnalyticsCost(sample: AnalyticsCostSample): Promise<void> {
  if (!shouldSampleAnalytics()) {
    return;
  }
  try {
    await firestore.collection("analytics_costs").add({
      ...sample,
      createdAt: Timestamp.now(),
    });
  } catch (error) {
    logger.debug("Failed to persist analytics_costs sample", error as Error);
  }
}

function summarizeOutlineResponse(body: OutlineResponseBody): Record<string, unknown> {
  const moduleCount = body.outline.length;
  const lessonCount = body.outline.reduce(
    (accumulator, module) => accumulator + module.lessons.length,
    0,
  );
  return {
    source: body.source,
    modules: moduleCount,
    lessons: lessonCount,
    estimatedHours: body.estimated_hours,
    cacheExpiresAt: body.cacheExpiresAt,
  };
}

export const __test = {
  summarizeOutlineResponse,
  shouldSampleAnalytics,
  createCounters,
};

const OutlineRequestSchema = z.object({
  topic: z.string().min(3, "topic"),
  language: z.string().optional(),
  lang: z.string().optional(),
  depth: z.string().optional(),
  band: z.string().optional(),
  goal: z.string().optional(),
});

type OutlineRequestInput = z.infer<typeof OutlineRequestSchema>;

const FALLBACK_OUTLINES: Record<string, OutlineTemplate> = {
  "sql-marketing": {
    slug: "sql-marketing",
    topic: "SQL for Marketing",
    goal: "Use SQL to analyse and optimise marketing initiatives",
    language: "en",
    estimatedHours: 14,
    modules: [
      {
        id: "fundamentals",
        title: "SQL fundamentals for marketing",
        summary: "Ground yourself on SQL concepts applied to marketing KPIs.",
        lessons: [
          {
            id: "intro",
            title: "Why SQL matters for marketing",
            summary: "Review real cases of funnels and attribution.",
            objective: "Connect SQL with day-to-day marketing decisions.",
            type: "lesson",
            durationMinutes: 18,
          },
          {
            id: "model",
            title: "Modelling leads and campaigns",
            summary: "Design a relational schema to track omni-channel campaigns.",
            objective: "Create a minimum relational model.",
            type: "workshop",
            durationMinutes: 26,
          },
          {
            id: "segmentation",
            title: "Segmentation with SELECT",
            summary: "Build behaviour-based audiences.",
            objective: "Apply combined filters and logical operators.",
            type: "practice",
            durationMinutes: 24,
          },
        ],
      },
      {
        id: "analytics",
        title: "Campaign analytics",
        summary: "Measure performance and iterate using SQL.",
        lessons: [
          {
            id: "kpis",
            title: "Acquisition KPIs",
            summary: "Calculate CPL, CPA and ROI using SQL.",
            objective: "Automate KPI calculations with aggregations.",
            type: "exercise",
            durationMinutes: 28,
          },
          {
            id: "retention",
            title: "Retention cohorts",
            summary: "Extract cohorts and analyse engagement.",
            objective: "Detect opportunities by cohort.",
            type: "practice",
            durationMinutes: 35,
          },
        ],
      },
    ],
  },
  default: {
    slug: "default",
    topic: "Guided learning",
    goal: "Adopt a continuous learning framework",
    language: "en",
    estimatedHours: 10,
    modules: [
      {
        id: "foundations",
        title: "Conceptual base for {TOPIC}",
        summary: "Understand context and opportunities.",
        lessons: [
          {
            id: "context",
            title: "Context and quick wins",
            summary: "Identify immediate impact for {TOPIC}.",
            objective: "Spot early wins.",
            type: "lesson",
            durationMinutes: 20,
          },
          {
            id: "dataset",
            title: "Preparing the dataset",
            summary: "Define data sources and ensure quality.",
            objective: "Guarantee reliable data.",
            type: "workshop",
            durationMinutes: 24,
          },
        ],
      },
      {
        id: "application",
        title: "Practical application of {TOPIC}",
        summary: "Bring theory into a real case.",
        lessons: [
          {
            id: "project",
            title: "Guided project",
            summary: "Execute a step-by-step exercise.",
            objective: "Gain confidence through execution.",
            type: "practice",
            durationMinutes: 32,
          },
          {
            id: "measurement",
            title: "Metrics and tracking",
            summary: "Define indicators to iterate.",
            objective: "Measure continuous impact.",
            type: "lesson",
            durationMinutes: 22,
          },
        ],
      },
    ],
  },
};

const FALLBACK_TRENDING: Record<string, TrendingTopic[]> = {
  en: [
    { topicKey: "sql_marketing", topic: "SQL for Marketing", count: 28, band: "intermediate", modules: 6 },
    { topicKey: "growth_analytics", topic: "Growth Analytics", count: 19, band: "advanced", modules: 8 },
    { topicKey: "email_personalization", topic: "Email Personalization", count: 16, band: "beginner", modules: 4 },
  ],
  es: [
    { topicKey: "sql_marketing", topic: "SQL para Marketing", count: 31, band: "intermedio", modules: 6 },
    { topicKey: "analitica_crecimiento", topic: "Analitica de Crecimiento", count: 22, band: "avanzado", modules: 7 },
    { topicKey: "segmentacion_crm", topic: "Segmentacion CRM", count: 18, band: "intermedio", modules: 5 },
  ],
  default: [
    { topicKey: "data_storytelling", topic: "Data Storytelling", count: 15 },
    { topicKey: "automation_basics", topic: "Automation Basics", count: 12 },
  ],
};

const RATE_BUCKETS = new Map<string, { count: number; resetAt: number }>();
const RATE_WINDOW_MS = 60_000;
const ANON_OUTLINE_LIMIT = 10;
const AUTH_OUTLINE_LIMIT = 80;
const ANON_TRENDING_LIMIT = 20;
const AUTH_TRENDING_LIMIT = 120;

class RateLimitError extends Error {
  retryAfter: number;

  constructor(message: string, retryAfter: number) {
    super(message);
    this.name = "RateLimitError";
    this.retryAfter = retryAfter;
  }
}

export function extractBearerToken(req: Request): string | null {
  const header = req.headers.authorization ?? req.headers.Authorization;
  if (!header || typeof header !== "string") {
    return null;
  }
  const match = header.match(/Bearer\s+(.+)/i);
  return match ? match[1].trim() : null;
}

export async function resolveUserId(req: Request): Promise<string> {
  const token = extractBearerToken(req);
  if (!token) {
    return "anonymous";
  }
  try {
    const decoded = await authClient.verifyIdToken(token);
    return decoded?.uid ?? "anonymous";
  } catch (error) {
    logger.debug("Failed to verify ID token", error as Error);
    return "anonymous";
  }
}

export function setAuthClientForTesting(client: Auth) {
  authClient = client;
}

export function resetAuthClientForTesting() {
  authClient = getAuth();
}

function fingerprintRequest(req: Request): string {
  const forwarded = req.headers["x-forwarded-for"];
  const ip = Array.isArray(forwarded)
    ? forwarded[0]
    : typeof forwarded === "string"
    ? forwarded.split(",")[0]?.trim()
    : req.ip;
  const userAgent = req.headers["user-agent"] ?? "unknown";
  const acceptLanguage = req.headers["accept-language"] ?? "";
  const raw = `${ip ?? "unknown"}|${userAgent}|${acceptLanguage}`;
  return createHash("sha1").update(raw).digest("hex");
}

function enforceRateLimit(scope: string, key: string, limit: number) {
  const bucketKey = `${scope}:${key}`;
  const now = Date.now();
  const bucket = RATE_BUCKETS.get(bucketKey);
  if (!bucket || bucket.resetAt <= now) {
    RATE_BUCKETS.set(bucketKey, { count: 1, resetAt: now + RATE_WINDOW_MS });
    return;
  }
  if (bucket.count >= limit) {
    throw new RateLimitError("rate_limit", bucket.resetAt - now);
  }
  bucket.count += 1;
  RATE_BUCKETS.set(bucketKey, bucket);
}

export function slugifyTopic(topic: string): string {
  const slug = topic
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
  return slug.length ? slug : "outline";
}

function normalizeLanguage(language?: string): string {
  const value = (language ?? "en").toLowerCase();
  if (value.startsWith("es")) return "es";
  if (value.startsWith("pt")) return "pt";
  return "en";
}

function normalizeDepth(depth?: string): string {
  const value = (depth ?? "medium").toLowerCase();
  if (value.startsWith("intro")) return "intro";
  if (value.startsWith("deep") || value.startsWith("advance")) return "deep";
  return "medium";
}

function normalizeBand(band?: string): string {
  const value = (band ?? "intermediate").toLowerCase();
  if (value.includes("begin")) return "beginner";
  if (value.includes("advance")) return "advanced";
  return "intermediate";
}

async function loadOutlineFromFirestore(
  slug: string,
  counters?: AnalyticsCallCounters,
): Promise<Record<string, unknown> | null> {
  try {
    if (counters) {
      counters.firestoreReads += 1;
    }
    const doc = await firestore.collection("course_outlines").doc(slug).get();
    if (!doc.exists) {
      return null;
    }
    return doc.data() ?? null;
  } catch (error) {
    logger.warn(`Failed to load outline ${slug} from Firestore`, error as Error);
    return null;
  }
}

async function loadOutlineFromStorage(
  slug: string,
  counters?: AnalyticsCallCounters,
): Promise<Record<string, unknown> | null> {
  try {
    const bucket = storage.bucket();
    const file = bucket.file(`outlines/${slug}.json`);
    if (counters) {
      counters.storageMetadataChecks += 1;
    }
    const [exists] = await file.exists();
    if (!exists) {
      return null;
    }
    const [buffer] = await file.download();
    if (counters) {
      counters.storageDownloads += 1;
      counters.storageReadBytes += buffer.length;
    }
    return JSON.parse(buffer.toString("utf-8"));
  } catch (error) {
    logger.warn(`Failed to load outline ${slug} from storage`, error as Error);
    return null;
  }
}

function cloneTemplate(template: OutlineTemplate): OutlineTemplate {
  return JSON.parse(JSON.stringify(template)) as OutlineTemplate;
}

function applyDepthToLessons(lessons: OutlineTemplateLesson[], depth: string): OutlineTemplateLesson[] {
  if (depth === "deep") {
    return lessons;
  }
  const limit = depth === "intro" ? Math.min(2, lessons.length) : Math.min(4, lessons.length);
  return lessons.slice(0, limit);
}

function buildModuleProgress(lessons: OutlineTemplateLesson[], band: string, index: number): { completed: number; total: number } {
  const total = lessons.length;
  if (total === 0) {
    return { completed: 0, total: 0 };
  }
  if (band === "beginner" && index === 0) {
    return { completed: Math.max(1, Math.floor(total / 2)), total };
  }
  return { completed: 0, total };
}

function adaptTemplateToResponse(template: OutlineTemplate, input: OutlineResolutionInput, slug: string): OutlineResponseBody {
  const modules: OutlineResponseModule[] = template.modules.map((module, index) => {
    const trimmedLessons = applyDepthToLessons(module.lessons, input.depth);
    const adaptedLessons: OutlineResponseLesson[] = trimmedLessons.map((lesson) => ({
      id: `${module.id}-${lesson.id}`,
      title: lesson.title.replace("{TOPIC}", input.topic),
      summary: lesson.summary.replace("{TOPIC}", input.topic),
      objective: lesson.objective?.replace("{TOPIC}", input.topic),
      type: lesson.type,
      durationMinutes: lesson.durationMinutes,
      content: lesson.summary.replace("{TOPIC}", input.topic),
    }));

    return {
      moduleId: module.id,
      title: module.title.replace("{TOPIC}", input.topic),
      summary: module.summary.replace("{TOPIC}", input.topic),
      lessons: adaptedLessons,
      locked: index >= 1,
      progress: buildModuleProgress(trimmedLessons, input.band, index),
    };
  });

  const estimatedMinutes = modules
    .flatMap((mod) => mod.lessons)
    .map((lesson) => lesson.durationMinutes ?? 20)
    .reduce((sum, value) => sum + value, 0);
  const depthMultiplier = input.depth === "deep" ? 1.2 : input.depth === "intro" ? 0.75 : 1;
  const estimatedHours = Math.max(4, Math.round((estimatedMinutes / 60) * depthMultiplier));

  const goal = input.goal && input.goal.trim().length > 0 ? input.goal.trim() : template.goal;

  return {
    topic: input.topic,
    goal,
    language: input.language,
    depth: input.depth,
    band: input.band,
    outline: modules,
    source: "curated+llm",
    estimated_hours: estimatedHours,
    cacheExpiresAt: Date.now() + 60 * 60 * 1000,
    meta: {
      slug,
      templateSlug: template.slug,
      pipelineVersion: "curated/2025-11-02",
      curatedLanguage: template.language,
      userId: input.userId,
    },
  };
}

async function resolveOutlineDocument(input: OutlineResolutionInput): Promise<OutlineResolutionResult> {
  const counters = createCounters();
  const slug = slugifyTopic(input.topic);

  const fromFirestore = await loadOutlineFromFirestore(slug, counters);
  if (fromFirestore) {
    const response = { ...fromFirestore } as Record<string, unknown>;
    const outline = response.outline;
    if (!Array.isArray(outline) || outline.length === 0) {
      const template = cloneTemplate(FALLBACK_OUTLINES[slug] ?? FALLBACK_OUTLINES.default);
      const body = adaptTemplateToResponse(template, input, slug);
      return {
        body,
        counters,
        resolution: "template",
      };
    }
    response.topic = input.topic;
    response.goal = input.goal ?? (response.goal as string) ?? `Apply ${input.topic}`;
    response.language = input.language;
    response.depth = input.depth;
    response.band = input.band;
    response.cacheExpiresAt = Date.now() + 60 * 60 * 1000;
    response.meta = {
      ...(response.meta as Record<string, unknown> | undefined),
      slug,
      resolvedAt: Date.now(),
      userId: input.userId,
    };
    response.source = (response.source as string | undefined) ?? "curated";
    response.estimated_hours = (response.estimated_hours as number | undefined) ?? Math.max(4, Math.round(outline.length * 2.5));
    return {
      body: response as unknown as OutlineResponseBody,
      counters,
      resolution: "firestore",
    };
  }

  const fromStorage = await loadOutlineFromStorage(slug, counters);
  if (fromStorage) {
    const response = { ...fromStorage } as Record<string, unknown>;
    const outline = response.outline;
    if (Array.isArray(outline) && outline.length > 0) {
      response.topic = input.topic;
      response.goal = input.goal ?? (response.goal as string) ?? `Apply ${input.topic}`;
      response.language = input.language;
      response.depth = input.depth;
      response.band = input.band;
      response.cacheExpiresAt = Date.now() + 60 * 60 * 1000;
      response.meta = {
        ...(response.meta as Record<string, unknown> | undefined),
        slug,
        resolvedAt: Date.now(),
        userId: input.userId,
      };
      response.source = (response.source as string | undefined) ?? "storage";
      response.estimated_hours = (response.estimated_hours as number | undefined) ?? Math.max(4, Math.round(outline.length * 2.5));
      return {
        body: response as unknown as OutlineResponseBody,
        counters,
        resolution: "storage",
      };
    }
  }

  const template = cloneTemplate(FALLBACK_OUTLINES[slug] ?? FALLBACK_OUTLINES.default);
  const body = adaptTemplateToResponse(template, input, slug);
  return {
    body,
    counters,
    resolution: "template",
  };
}

async function resolveTrendingTopics(language: string): Promise<TrendingResolutionResult> {
  const counters = createCounters();
  const lang = language;
  try {
    const aggregateDoc = await firestore.collection("analytics_trending").doc(lang).get();
    counters.firestoreReads += 1;
    if (aggregateDoc.exists) {
      const data = (aggregateDoc.data() ?? {}) as { topics?: TrendingTopic[]; windowHours?: number };
      const topics = Array.isArray(data.topics) ? data.topics.slice(0, 20) : [];
      return {
        topics,
        windowHours: data.windowHours ?? 24,
        source: "aggregate",
        counters,
        resolution: "aggregate",
      };
    }
  } catch (error) {
    logger.debug("No aggregated trending found", error as Error);
  }

  try {
    const snapshot = await firestore
      .collection("trending")
      .where("lang", "==", lang)
      .orderBy("ts", "desc")
      .limit(40)
      .get();
    const counter = new Map<string, TrendingTopic>();
    snapshot.forEach((doc) => {
      counters.firestoreReads += 1;
      const payload = doc.data();
      const key = (payload.topicKey as string | undefined) ?? slugifyTopic((payload.topic as string | undefined) ?? "");
      if (!key) return;
      const current = counter.get(key) ?? {
        topicKey: key,
        topic: (payload.topic as string | undefined) ?? key,
        count: 0,
      };
      current.count += typeof payload.count === "number" ? payload.count : 1;
      if (typeof payload.band === "string") current.band = payload.band;
      if (typeof payload.modules === "number") current.modules = payload.modules;
      counter.set(key, current);
    });
    if (counter.size > 0) {
      const topics = Array.from(counter.values())
        .sort((a, b) => b.count - a.count)
        .slice(0, 20);
      const newest = snapshot.docs.at(0)?.get("ts") as Timestamp | undefined;
      const oldest = snapshot.docs.at(-1)?.get("ts") as Timestamp | undefined;
      const windowHours = newest && oldest ? Math.max(1, Math.round((newest.toMillis() - oldest.toMillis()) / 3_600_000)) : 24;
      return {
        topics,
        windowHours,
        source: "events",
        counters,
        resolution: "events",
      };
    }
  } catch (error) {
    logger.warn("Failed to query trending collection", error as Error);
  }

  const fallback = FALLBACK_TRENDING[lang] ?? FALLBACK_TRENDING.default;
  return {
    topics: fallback,
    windowHours: 24,
    source: "fallback",
    counters,
    resolution: "fallback",
  };
}

function sendMethodNotAllowed(res: Response, allowed: string[]) {
  res.set("Allow", allowed.join(", "));
  res.status(405).json({ error: "method_not_allowed" });
}

export const outline = onRequest({ cors: true }, async (req, res) => {
  const startedAt = Date.now();
  if (req.method === "OPTIONS") {
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.status(204).send();
    return;
  }
  if (req.method !== "POST") {
    sendMethodNotAllowed(res, ["POST"]);
    return;
  }

  const payload = typeof req.body === "string" && req.body.length > 0 ? JSON.parse(req.body) : req.body ?? {};
  const parsed = OutlineRequestSchema.safeParse(payload as OutlineRequestInput);
  if (!parsed.success) {
    res.status(400).json({ error: "invalid_request", details: parsed.error.flatten() });
    return;
  }

  const data = parsed.data;
  const topic = data.topic.trim();
  const language = normalizeLanguage(data.language ?? data.lang);
  const depth = normalizeDepth(data.depth);
  const band = normalizeBand(data.band);
  const goal = data.goal?.trim();
  const topicSlug = slugifyTopic(topic);

  let userId: string = "anonymous";
  try {
    userId = await resolveUserId(req);
    const rateKey = userId === "anonymous" ? fingerprintRequest(req) : userId;
    enforceRateLimit("outline", rateKey, userId === "anonymous" ? ANON_OUTLINE_LIMIT : AUTH_OUTLINE_LIMIT);

    const outlineResult = await resolveOutlineDocument({
      topic,
      goal,
      language,
      depth,
      band,
      userId,
    });

    res.status(200).json(outlineResult.body);

    void logAnalyticsCost({
      endpoint: "outline",
      status: "ok",
      userType: userId === "anonymous" ? "anonymous" : "authenticated",
      latencyMs: Date.now() - startedAt,
      request: {
        topicSlug,
        language,
        depth,
        band,
        goalLength: goal?.length ?? 0,
      },
      response: {
        ...summarizeOutlineResponse(outlineResult.body),
        resolution: outlineResult.resolution,
      },
      counters: outlineResult.counters,
    });
  } catch (error) {
    if (error instanceof RateLimitError) {
      res.set("Retry-After", Math.ceil(error.retryAfter / 1000).toString());
      res.status(429).json({ error: "rate_limited" });
      void logAnalyticsCost({
        endpoint: "outline",
        status: "rate_limited",
        userType: userId === "anonymous" ? "anonymous" : "authenticated",
        latencyMs: Date.now() - startedAt,
        request: {
          topicSlug,
          language,
          depth,
          band,
          goalLength: goal?.length ?? 0,
        },
        response: {
          retryAfterMs: error.retryAfter,
        },
        counters: createCounters(),
      });
      return;
    }
    logger.error("outline handler failed", error as Error);
    res.status(500).json({ error: "internal" });
    void logAnalyticsCost({
      endpoint: "outline",
      status: "error",
      userType: userId === "anonymous" ? "anonymous" : "authenticated",
      latencyMs: Date.now() - startedAt,
      request: {
        topicSlug,
        language,
        depth,
        band,
        goalLength: goal?.length ?? 0,
      },
      counters: createCounters(),
      error: error instanceof Error ? error.message : String(error),
    });
  }
});

export const trending = onRequest({ cors: true }, async (req, res) => {
  const startedAt = Date.now();
  if (req.method === "OPTIONS") {
    res.set("Access-Control-Allow-Methods", "GET, OPTIONS");
    res.status(204).send();
    return;
  }
  if (req.method !== "GET") {
    sendMethodNotAllowed(res, ["GET"]);
    return;
  }

  const language = normalizeLanguage(typeof req.query.lang === "string" ? (req.query.lang as string) : undefined);

  let userId: string = "anonymous";
  try {
    userId = await resolveUserId(req);
    const rateKey = userId === "anonymous" ? fingerprintRequest(req) : userId;
    enforceRateLimit("trending", rateKey, userId === "anonymous" ? ANON_TRENDING_LIMIT : AUTH_TRENDING_LIMIT);
    const { topics, windowHours, source, counters, resolution } = await resolveTrendingTopics(language);
    res.status(200).json({
      lang: language,
      windowHours,
      generatedAt: Date.now(),
      topics,
      source,
    });
    void logAnalyticsCost({
      endpoint: "trending",
      status: "ok",
      userType: userId === "anonymous" ? "anonymous" : "authenticated",
      latencyMs: Date.now() - startedAt,
      request: {
        language,
      },
      response: {
        source,
        resolution,
        topics: topics.length,
        windowHours,
      },
      counters,
    });
  } catch (error) {
    if (error instanceof RateLimitError) {
      res.set("Retry-After", Math.ceil(error.retryAfter / 1000).toString());
      res.status(429).json({ error: "rate_limited" });
      void logAnalyticsCost({
        endpoint: "trending",
        status: "rate_limited",
        userType: userId === "anonymous" ? "anonymous" : "authenticated",
        latencyMs: Date.now() - startedAt,
        request: {
          language,
        },
        response: {
          retryAfterMs: error.retryAfter,
        },
        counters: createCounters(),
      });
      return;
    }
    logger.error("trending handler failed", error as Error);
    const fallback = FALLBACK_TRENDING[language] ?? FALLBACK_TRENDING.default;
    res.status(200).json({
      lang: language,
      windowHours: 24,
      generatedAt: Date.now(),
      topics: fallback,
      source: "fallback",
    });
    void logAnalyticsCost({
      endpoint: "trending",
      status: "error",
      userType: userId === "anonymous" ? "anonymous" : "authenticated",
      latencyMs: Date.now() - startedAt,
      request: {
        language,
      },
      counters: createCounters(),
      error: error instanceof Error ? error.message : String(error),
    });
  }
});

export const api = outline;
