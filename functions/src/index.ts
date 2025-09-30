import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { z } from "zod";

admin.initializeApp();
const db = admin.firestore();

const ReqSchema = z.object({
  topic: z.string().min(2),
  lang: z.enum(["es", "en"]).default("es"),
  depth: z.enum(["intro", "medium", "deep"]).default("deep"),
});

const ttlByDepth: Record<string, number> = {
  intro: 7 * 24 * 3600,
  medium: 3 * 24 * 3600,
  deep: 24 * 3600,
};

// Importante: NO retornar res.json(...). Solo llamarlo.
// La firma del handler debe ser Promise<void> o void.
export const outline = functions
  .region("us-east4")
  .https.onRequest(async (req: functions.https.Request, res: functions.Response): Promise<void> => {
    try {
      const input = req.method === "GET" ? req.query : req.body;
      const parsed = ReqSchema.safeParse(input);
      if (!parsed.success) {
        res.status(400).json({ error: parsed.error.issues });
        return;
      }

      const { topic, lang, depth } = parsed.data;
      const cacheKey = `${lang}:${depth}:${String(topic).toLowerCase()}`;
      const now = Date.now();

      // Cache hit?
      const doc = await db.collection("cache_outline").doc(cacheKey).get();
      if (doc.exists) {
        const d = doc.data()!;
        const createdAtMs =
          d.createdAt?.toMillis?.() ??
          (typeof d.createdAt === "number" ? d.createdAt : 0);
        const ttl = d.ttlSec ?? ttlByDepth[depth] ?? 86400;

        if (now - createdAtMs < ttl * 1000) {
          functions.logger.info("outline_cache_hit", { cacheKey, depth, lang });
          res.set("Cache-Control", "public, max-age=300");
          res.json({ source: "cache", ...d.payload });
          return;
        }
      }

      // TODO: integrar proveedor IA aquí (OpenAI/Vertex) si aplica.
      const payload = {
        outline: [
          `Introduction to ${topic}`,
          "Core concepts",
          "Practice tasks",
          "Next steps",
        ],
        topic,
        lang,
        depth,
      };

      await db.collection("cache_outline").doc(cacheKey).set({
        createdAt: admin.firestore.Timestamp.fromMillis(now),
        ttlSec: ttlByDepth[depth] ?? 86400,
        payload,
      });

      await db.collection("observability").add({
        route: "outline",
        ts: admin.firestore.FieldValue.serverTimestamp(),
        user: req.headers["x-user-id"] ?? "anon",
        tokens_in: 0,
        tokens_out: 0,
        cost_usd: 0,
        cached: false,
      });

      res.set("Cache-Control", "public, max-age=60");
      res.json({ source: "fresh", ...payload });
      return;
    } catch (e: any) {
      functions.logger.error("outline_error", { message: e?.message });
      res.status(500).json({ error: e?.message ?? "internal" });
      return;
    }
  });
