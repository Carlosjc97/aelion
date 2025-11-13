import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { cleanupExpiredCache } from "./cache-service";

const SECRET_HEADER = "x-cloudscheduler-secret";

export const cleanupAiCache = onRequest({ cors: false }, async (req, res) => {
  if (req.method !== "GET") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  const cronSecret = process.env.CRON_SECRET ?? "dev-secret";
  const providedSecretHeader = req.headers[SECRET_HEADER];
  const providedSecret = Array.isArray(providedSecretHeader)
    ? providedSecretHeader[0]
    : providedSecretHeader;

  if (!providedSecret || providedSecret !== cronSecret) {
    logger.warn("Unauthorized cleanup attempt", { ip: req.ip });
    res.status(401).json({ error: "Unauthorized" });
    return;
  }

  logger.info("Starting scheduled cache cleanup");

  try {
    const deletedCount = await cleanupExpiredCache();

    logger.info("Cache cleanup completed", { deletedCount });

    res.status(200).json({
      success: true,
      deletedCount,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    logger.error("Cache cleanup failed", error);
    res.status(500).json({ error: "Cleanup failed" });
  }
});
