import { onRequest } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";
import { initializeApp, applicationDefault } from "firebase-admin/app";
import { getFirestore, Timestamp, FieldValue } from "firebase-admin/firestore";
import { z } from "zod";

// Admin SDK (modular, ESM)
const app = initializeApp({ credential: applicationDefault() });
const db = getFirestore(app);

// Validación de entrada
const ReqSchema = z.object({
  topic: z.string().min(2),
  lang: z.enum(["es", "en"]).default("es"),
  depth: z.enum(["intro", "medium", "deep"]).default("deep"),
});

// TTL por profundidad
const ttlByDepth: Record<string, number> = {
  intro: 7 * 24 * 3600,
  medium: 3 * 24 * 3600,
  deep: 24 * 3600,
};

// Cloud Function v2 con región us-east4
export const outline = onRequest({ region: "us-east4" }, async (req, res) => {
  try {
    // (Opcional) CORS si llamas desde web con otro origen:
    // res.set("Access-Control-Allow-Origin", "*");
    // res.set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-User-Id");
    // if (req.method === "OPTIONS") { res.status(204).send(""); return; }

    const input = req.method === "GET" ? req.query : req.body;
    const parsed = ReqSchema.safeParse(input);
    if (!parsed.success) {
      res.status(400).json({ error: parsed.error.issues });
      return;
    }

    const { topic, lang, depth } = parsed.data;
    const cacheKey = `${lang}:${depth}:${String(topic).toLowerCase()}`;
    const now = Date.now();

    // Cache hit
    const doc = await db.collection("cache_outline").doc(cacheKey).get();
    if (doc.exists) {
      const d = doc.data()!;
      const createdAtMs =
        typeof d.createdAt === "number"
          ? d.createdAt
          : typeof (d.createdAt as any)?.toMillis === "function"
          ? (d.createdAt as any).toMillis()
          : 0;
      const ttl = d.ttlSec ?? ttlByDepth[depth] ?? 86400;

      if (now - createdAtMs < ttl * 1000) {
        logger.info("outline_cache_hit", { cacheKey, depth, lang });
        res.set("Cache-Control", "public, max-age=300");
        res.json({ source: "cache", ...d.payload });
        return;
      }
    }

    // TODO: integrar proveedor IA si aplica
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
      createdAt: Timestamp.fromMillis(now),
      ttlSec: ttlByDepth[depth] ?? 86400,
      payload,
    });

    await db.collection("observability").add({
      route: "outline",
      ts: FieldValue.serverTimestamp(),
      user: (req.headers["x-user-id"] as string) ?? "anon",
      tokens_in: 0,
      tokens_out: 0,
      cost_usd: 0,
      cached: false,
    });

    res.set("Cache-Control", "public, max-age=60");
    res.json({ source: "fresh", ...payload });
    return;
  } catch (e: any) {
    logger.error("outline_error", { message: e?.message });
    res.status(500).json({ error: e?.message ?? "internal" });
    return;
  }
});
