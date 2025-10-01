import { https, logger } from "firebase-functions/v2";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { z } from "zod";

// Initialize Firebase Admin SDK
initializeApp();
const db = getFirestore();

// Zod schema for request body validation
const outlineRequestSchema = z.object({
  topic: z.string().min(3, "Topic must be at least 3 characters long."),
  depth: z.enum(["intro", "medium", "deep"]),
  lang: z.string().optional().default("en"),
});

// TTL in seconds based on depth
const TtlDuration = {
  intro: 7 * 24 * 60 * 60, // 7 days
  medium: 3 * 24 * 60 * 60, // 3 days
  deep: 1 * 24 * 60 * 60,   // 1 day
};

// --- Main HTTPS Callable Function ---
export const outline = https.onRequest(
  { cors: true }, // Enable CORS for web clients
  async (req, res) => {
    // 1. Validate request method and body
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    const parseResult = outlineRequestSchema.safeParse(req.body);
    if (!parseResult.success) {
      logger.warn("Invalid request body", { errors: parseResult.error.flatten() });
      res.status(400).json({ error: "Invalid request body", details: parseResult.error.flatten() });
      return;
    }

    const { topic, depth, lang } = parseResult.data;
    const userId = req.headers["x-user-id"] as string | undefined; // Assume user ID is passed in headers if available
    const cacheKey = `outline-${lang}-${depth}-${topic.toLowerCase().replace(/\s+/g, "-")}`;
    const cacheRef = db.collection("cache_outline").doc(cacheKey);

    try {
      // 2. Check for a valid cache entry
      const cacheDoc = await cacheRef.get();
      if (cacheDoc.exists) {
        const cacheData = cacheDoc.data();
        const now = Timestamp.now();
        if (cacheData && cacheData.expiresAt.toMillis() > now.toMillis()) {
          logger.info(`[Cache HIT] for key: ${cacheKey}`, { userId });

          // Log to observability collection
          await logObservability({
            topic,
            depth,
            lang,
            userId,
            cached: true,
          });

          res.status(200).json({
            source: "cache",
            outline: cacheData.outline,
          });
          return;
        }
      }
      logger.info(`[Cache MISS] for key: ${cacheKey}`, { userId });

      // 3. Generate fresh (demo) content if no valid cache
      // TODO: Replace with actual AI provider call
      const demoOutline = generateDemoOutline(topic, depth);
      const newExpiresAt = Timestamp.fromMillis(Date.now() + TtlDuration[depth] * 1000);

      // 4. Store the new content in the cache
      await cacheRef.set({
        outline: demoOutline,
        createdAt: Timestamp.now(),
        expiresAt: newExpiresAt,
        ttlSec: TtlDuration[depth],
      });

      // Log to observability collection
      await logObservability({
        topic,
        depth,
        lang,
        userId,
        cached: false,
        // Placeholder cost/token data
        estCostUsd: 0.0001,
        tokensIn: topic.length * 2,
        tokensOut: JSON.stringify(demoOutline).length,
      });

      res.status(200).json({
        source: "fresh",
        outline: demoOutline,
      });
    } catch (error) {
      logger.error("Error processing /outline request", { error, topic, userId });
      res.status(500).send("Internal Server Error");
    }
  }
);

// --- Helper Functions ---

/**
 * Generates a deterministic demo outline for testing.
 */
function generateDemoOutline(topic: string, depth: string) {
  const itemCount = depth === "intro" ? 3 : depth === "medium" ? 5 : 7;
  return Array.from({ length: itemCount }, (_, i) => ({
    title: `Section ${i + 1}: Introduction to ${topic}`,
    description: `A detailed look into the basics of section ${i + 1} of ${topic}.`,
    duration_minutes: (i + 1) * 5,
  }));
}

/**
 * Logs request metadata to the observability collection.
 */
async function logObservability(data: {
  topic: string;
  depth: string;
  lang: string;
  userId?: string;
  cached: boolean;
  estCostUsd?: number;
  tokensIn?: number;
  tokensOut?: number;
}) {
  try {
    await db.collection("observability").add({
      route: "outline",
      ts: Timestamp.now(),
      user: data.userId ?? "anonymous",
      cached: data.cached,
      params: { topic: data.topic, depth: data.depth, lang: data.lang },
      cost_usd: data.estCostUsd ?? 0,
      tokens_in: data.tokensIn ?? 0,
      tokens_out: data.tokensOut ?? 0,
    });
  } catch(error) {
      logger.error("Failed to write to observability collection", { error });
  }
}
