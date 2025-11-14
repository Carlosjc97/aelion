/**
 * Quiz session stores - now persisted in Firestore to survive function restarts.
 * Memory cache kept for performance on repeated reads.
 */

import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

if (!getApps().length) {
  initializeApp();
}

const firestore = getFirestore();

export interface PlacementQuizSession {
  quizId: string;
  topic: string;
  language: string;
  userId?: string;
  createdAt: number;
  expiresAt: number;
  questions: Array<{
    id: string;
    question: string;
    options: string[];
    correct_answer: number;
    difficulty: string;
    module: string;
    module_name: string;
    type: string;
    explanation: string;
    context: string;
    tags: string[];
    irt_params: {
      a: number;
      b: number;
      c: number;
    };
  }>;
}

export interface ModuleQuizSession {
  quizId: string;
  moduleId: string;
  moduleNumber: number;
  topic: string;
  language: string;
  createdAt: number;
  expiresAt: number;
  userId?: string;
  questions: Array<{
    id: string;
    question: string;
    options: string[];
    correct_answer: number;
    tags?: string[];
  }>;
}

// Memory cache for performance (still useful for same-instance repeated reads)
export const placementQuizSessions = new Map<string, PlacementQuizSession>();
export const moduleQuizSessions = new Map<string, ModuleQuizSession>();

/**
 * Save placement quiz session to Firestore and memory cache
 */
export async function savePlacementSession(session: PlacementQuizSession): Promise<void> {
  try {
    // Save to Firestore
    await firestore
      .collection("quiz_sessions")
      .doc(`placement_${session.quizId}`)
      .set({
        ...session,
        createdAt: Timestamp.fromMillis(session.createdAt),
        expiresAt: Timestamp.fromMillis(session.expiresAt),
      });

    // Also cache in memory
    placementQuizSessions.set(session.quizId, session);

    logger.info(`Saved placement session ${session.quizId} to Firestore`);
  } catch (error) {
    logger.error(`Failed to save placement session ${session.quizId}:`, error);
    throw error;
  }
}

/**
 * Get placement quiz session from memory cache or Firestore
 */
export async function getPlacementSession(quizId: string): Promise<PlacementQuizSession | null> {
  // Check memory cache first
  const cached = placementQuizSessions.get(quizId);
  if (cached) {
    return cached;
  }

  // Fetch from Firestore
  try {
    const doc = await firestore
      .collection("quiz_sessions")
      .doc(`placement_${quizId}`)
      .get();

    if (!doc.exists) {
      return null;
    }

    const data = doc.data();
    if (!data) {
      return null;
    }

    const session: PlacementQuizSession = {
      ...data,
      createdAt: data.createdAt instanceof Timestamp ? data.createdAt.toMillis() : data.createdAt,
      expiresAt: data.expiresAt instanceof Timestamp ? data.expiresAt.toMillis() : data.expiresAt,
    } as PlacementQuizSession;

    // Cache in memory for next time
    placementQuizSessions.set(quizId, session);

    return session;
  } catch (error) {
    logger.error(`Failed to get placement session ${quizId}:`, error);
    return null;
  }
}

/**
 * Save module quiz session to Firestore and memory cache
 */
export async function saveModuleSession(session: ModuleQuizSession): Promise<void> {
  try {
    await firestore
      .collection("quiz_sessions")
      .doc(`module_${session.quizId}`)
      .set({
        ...session,
        createdAt: Timestamp.fromMillis(session.createdAt),
        expiresAt: Timestamp.fromMillis(session.expiresAt),
      });

    moduleQuizSessions.set(session.quizId, session);

    logger.info(`Saved module session ${session.quizId} to Firestore`);
  } catch (error) {
    logger.error(`Failed to save module session ${session.quizId}:`, error);
    throw error;
  }
}

/**
 * Get module quiz session from memory cache or Firestore
 */
export async function getModuleSession(quizId: string): Promise<ModuleQuizSession | null> {
  const cached = moduleQuizSessions.get(quizId);
  if (cached) {
    return cached;
  }

  try {
    const doc = await firestore
      .collection("quiz_sessions")
      .doc(`module_${quizId}`)
      .get();

    if (!doc.exists) {
      return null;
    }

    const data = doc.data();
    if (!data) {
      return null;
    }

    const session: ModuleQuizSession = {
      ...data,
      createdAt: data.createdAt instanceof Timestamp ? data.createdAt.toMillis() : data.createdAt,
      expiresAt: data.expiresAt instanceof Timestamp ? data.expiresAt.toMillis() : data.expiresAt,
    } as ModuleQuizSession;

    moduleQuizSessions.set(quizId, session);

    return session;
  } catch (error) {
    logger.error(`Failed to get module session ${quizId}:`, error);
    return null;
  }
}

/**
 * Delete module quiz session from both Firestore and memory
 */
export async function deleteModuleSession(quizId: string): Promise<void> {
  try {
    await firestore
      .collection("quiz_sessions")
      .doc(`module_${quizId}`)
      .delete();

    moduleQuizSessions.delete(quizId);

    logger.info(`Deleted module session ${quizId}`);
  } catch (error) {
    logger.error(`Failed to delete module session ${quizId}:`, error);
  }
}
