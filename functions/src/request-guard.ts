import type { Request } from "express";
import { getApps, initializeApp } from "firebase-admin/app";
import { Timestamp, getFirestore } from "firebase-admin/firestore";
import type { Auth } from "firebase-admin/auth";
import * as logger from "firebase-functions/logger";

interface RateLimitRecord {
  count: number;
  windowStart: Timestamp;
}

export interface AuthContext {
  userId?: string;
  tokenUid?: string;
}

if (!getApps().length) {
  initializeApp();
}

const RATE_LIMIT_COLLECTION = "rate_limits";
const firestore = getFirestore();

export async function authenticateRequest(
  req: Request,
  authClient: Auth,
): Promise<AuthContext> {
  const authorization = req.headers.authorization;
  if (!authorization?.startsWith("Bearer ")) {
    return {};
  }

  const token = authorization.replace("Bearer ", "").trim();
  if (!token) {
    return {};
  }

  try {
    const decoded = await authClient.verifyIdToken(token, true);
    return {
      userId: decoded.uid,
      tokenUid: decoded.uid,
    };
  } catch (error) {
    logger.warn("Failed to verify ID token", {
      error: error instanceof Error ? error.message : String(error),
    });
    return {};
  }
}

const DAILY_LIMIT_COLLECTION = "user_daily_calls";

export async function enforceRateLimit(options: {
  key: string;
  limit: number;
  windowSeconds: number;
  userId?: string;
  userDailyCap?: number;
}): Promise<void> {
  const { key, limit, windowSeconds, userId, userDailyCap } = options;
  if (!key) {
    return;
  }

  const docRef = firestore.collection(RATE_LIMIT_COLLECTION).doc(key);
  const now = Timestamp.now();
  const windowStart = Timestamp.fromMillis(
    now.toMillis() - windowSeconds * 1000,
  );

  await firestore.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(docRef);
    if (!snapshot.exists) {
      transaction.set(docRef, {
        count: 1,
        windowStart: now,
        createdAt: now,
        updatedAt: now,
      });
      return;
    }

    const data = snapshot.data() as RateLimitRecord;
    let count = data.count;
    let start = data.windowStart;
    if (start.toMillis() < windowStart.toMillis()) {
      count = 0;
      start = now;
    }

    count += 1;
    if (count > limit) {
      throw new Error("RATE_LIMIT_EXCEEDED");
    }

    transaction.update(docRef, {
      count,
      windowStart: start,
      updatedAt: now,
    });
  });

  if (userId && userDailyCap && userDailyCap > 0) {
    await enforceDailyUserLimit(userId, userDailyCap);
  }
}

export function resolveRateLimitKey(req: Request, userId?: string): string {
  if (userId) {
    return `user_${userId}`;
  }

  const forwardedFor = req.headers["x-forwarded-for"];
  if (typeof forwardedFor === "string" && forwardedFor.length > 0) {
    return `ip_${forwardedFor.split(",")[0]?.trim() ?? "unknown"}`;
  }

  const ip = req.ip || req.socket.remoteAddress || "unknown";
  return `ip_${ip}`;
}

async function enforceDailyUserLimit(userId: string, cap: number): Promise<void> {
  const docRef = firestore.collection(DAILY_LIMIT_COLLECTION).doc(userId);
  const now = Timestamp.now();
  const today = new Date(now.toMillis());
  const dayKey = [
    today.getUTCFullYear(),
    `${today.getUTCMonth() + 1}`.padStart(2, "0"),
    `${today.getUTCDate()}`.padStart(2, "0"),
  ].join("-");

  await firestore.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(docRef);
    let count = 0;
    let storedDay = dayKey;

    if (snapshot.exists) {
      const data = snapshot.data() ?? {};
      storedDay = typeof data.dayKey === "string" ? data.dayKey : dayKey;
      if (storedDay === dayKey) {
        count = typeof data.count === "number" ? data.count : 0;
      } else {
        count = 0;
        storedDay = dayKey;
      }
    }

    count += 1;
    if (count > cap) {
      throw new Error("DAILY_LIMIT_EXCEEDED");
    }

    transaction.set(
      docRef,
      {
        count,
        dayKey: storedDay,
        updatedAt: now,
      },
      { merge: true },
    );
  });
}
