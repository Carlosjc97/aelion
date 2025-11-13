/**
 * Cache Service - Firestore-based caching for AI-generated content
 *
 * Reduces OpenAI costs by caching common content with aggressive TTLs
 */

import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { createHash } from "node:crypto";

if (!getApps().length) {
  initializeApp();
}

const db = getFirestore();
const CACHE_COLLECTION = "ai_cache";

interface CacheEntry {
  key: string;
  content: any; // JSON content from OpenAI
  createdAt: Timestamp;
  expiresAt: Timestamp;
  metadata: {
    model: string;
    tokens?: number;
    lang: string;
    topic: string;
    type: "quiz" | "module" | "lesson";
  };
}

/**
 * Generate cache key from parameters
 */
export function generateCacheKey(params: {
  type: "quiz" | "module" | "lesson";
  topic: string;
  lang: string;
  level?: string;
  moduleNumber?: number;
  concept?: string;
}): string {
  const { type, topic, lang, level, moduleNumber, concept } = params;

  const parts = [type, topic, lang];
  if (level) parts.push(level);
  if (moduleNumber !== undefined) parts.push(`m${moduleNumber}`);
  if (concept) parts.push(concept);

  // Create hash for consistent key
  const raw = parts.join("_").toLowerCase().replace(/\s+/g, "-");
  return raw;
}

/**
 * Get content from cache
 * Returns null if cache miss or expired
 */
export async function getCached(key: string): Promise<any | null> {
  try {
    const docRef = db.collection(CACHE_COLLECTION).doc(key);
    const doc = await docRef.get();

    if (!doc.exists) {
      logger.debug("Cache miss", { key });
      return null;
    }

    const data = doc.data() as CacheEntry;

    // Check expiration
    const now = Timestamp.now();
    if (data.expiresAt.toMillis() < now.toMillis()) {
      logger.info("Cache expired", { key, expiresAt: data.expiresAt.toDate() });
      // Delete expired entry
      await docRef.delete();
      return null;
    }

    logger.info("Cache hit", {
      key,
      createdAt: data.createdAt.toDate(),
      expiresAt: data.expiresAt.toDate(),
    });

    return data.content;
  } catch (error) {
    logger.error("Cache read error", {
      key,
      error: error instanceof Error ? error.message : String(error),
    });
    return null; // Fail open - proceed without cache
  }
}

/**
 * Set content in cache with TTL
 */
export async function setCached(
  key: string,
  content: any,
  ttlDays: number,
  metadata: CacheEntry["metadata"]
): Promise<void> {
  try {
    const now = Timestamp.now();
    const expiresAt = Timestamp.fromMillis(now.toMillis() + ttlDays * 24 * 60 * 60 * 1000);

    const entry: CacheEntry = {
      key,
      content,
      createdAt: now,
      expiresAt,
      metadata,
    };

    await db.collection(CACHE_COLLECTION).doc(key).set(entry);

    logger.info("Cache set", {
      key,
      ttlDays,
      expiresAt: expiresAt.toDate(),
      type: metadata.type,
    });
  } catch (error) {
    logger.error("Cache write error", {
      key,
      error: error instanceof Error ? error.message : String(error),
    });
    // Don't throw - caching is best-effort
  }
}

/**
 * Invalidate cache entry manually
 */
export async function invalidateCache(key: string): Promise<void> {
  try {
    await db.collection(CACHE_COLLECTION).doc(key).delete();
    logger.info("Cache invalidated", { key });
  } catch (error) {
    logger.error("Cache invalidation error", {
      key,
      error: error instanceof Error ? error.message : String(error),
    });
  }
}

/**
 * Cleanup expired entries (run periodically via Cloud Scheduler)
 */
export async function cleanupExpiredCache(): Promise<number> {
  try {
    const now = Timestamp.now();
    const snapshot = await db.collection(CACHE_COLLECTION)
      .where("expiresAt", "<", now)
      .limit(100)
      .get();

    if (snapshot.empty) {
      logger.info("No expired cache entries to clean");
      return 0;
    }

    const batch = db.batch();
    snapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();

    logger.info("Cleaned up expired cache", { count: snapshot.size });
    return snapshot.size;
  } catch (error) {
    logger.error("Cache cleanup error", {
      error: error instanceof Error ? error.message : String(error),
    });
    return 0;
  }
}

/**
 * Get cache statistics
 */
export async function getCacheStats(): Promise<{
  totalEntries: number;
  byType: Record<string, number>;
  byLang: Record<string, number>;
  oldestEntry: Date | null;
  newestEntry: Date | null;
}> {
  try {
    const snapshot = await db.collection(CACHE_COLLECTION).get();

    const byType: Record<string, number> = {};
    const byLang: Record<string, number> = {};
    let oldestEntry: Timestamp | undefined;
    let newestEntry: Timestamp | undefined;

    snapshot.docs.forEach(doc => {
      const data = doc.data() as CacheEntry;

      // Count by type
      const type = data.metadata.type;
      byType[type] = (byType[type] || 0) + 1;

      // Count by lang
      const lang = data.metadata.lang;
      byLang[lang] = (byLang[lang] || 0) + 1;

      // Track oldest/newest
      if (!oldestEntry || data.createdAt.toMillis() < oldestEntry.toMillis()) {
        oldestEntry = data.createdAt;
      }
      if (!newestEntry || data.createdAt.toMillis() > newestEntry.toMillis()) {
        newestEntry = data.createdAt;
      }
    });

    return {
      totalEntries: snapshot.size,
      byType,
      byLang,
      oldestEntry: oldestEntry?.toDate() || null,
      newestEntry: newestEntry?.toDate() || null,
    };
  } catch (error) {
    logger.error("Failed to get cache stats", {
      error: error instanceof Error ? error.message : String(error),
    });
    throw error;
  }
}
