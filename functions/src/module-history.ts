// ============================================================
// MODULE HISTORY SERVICE
// Manages storage and retrieval of generated module metadata
// for progressive learning and context-aware module generation
// ============================================================

import { getFirestore, FieldValue } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

const firestore = getFirestore();

/**
 * Compact module metadata for history tracking
 */
export interface ModuleHistoryEntry {
  moduleNumber: number;
  title: string;
  lessonTitles: string[];
  skillsTargeted: string[];
  generatedAt: number;
  durationMinutes?: number;
}

/**
 * Save a generated module to history
 */
export async function saveModuleToHistory(
  userId: string,
  topic: string,
  moduleData: {
    moduleNumber: number;
    title: string;
    lessons: Array<{ title: string }>;
    skillsTargeted: string[];
    durationMinutes?: number;
  }
): Promise<void> {
  const topicKey = normalizeTopicKey(topic);
  const docId = `${topicKey}_m${moduleData.moduleNumber}`;

  try {
    await firestore
      .collection("users")
      .doc(userId)
      .collection("module_history")
      .doc(docId)
      .set(
        {
          topic: topic.trim(),
          moduleNumber: moduleData.moduleNumber,
          title: moduleData.title,
          lessonTitles: moduleData.lessons.map((l) => l.title),
          skillsTargeted: moduleData.skillsTargeted || [],
          durationMinutes: moduleData.durationMinutes,
          generatedAt: FieldValue.serverTimestamp(),
        },
        { merge: false }
      );

    logger.info(
      `[ModuleHistory] Saved M${moduleData.moduleNumber} for user ${userId}, topic "${topic}"`
    );
  } catch (error) {
    logger.error(
      `[ModuleHistory] Failed to save M${moduleData.moduleNumber}:`,
      error
    );
    // Don't throw - history saving is non-critical
  }
}

/**
 * Get module history for a topic up to a specific module number
 */
export async function getModuleHistory(
  userId: string,
  topic: string,
  upToModuleNumber: number
): Promise<ModuleHistoryEntry[]> {
  const topicKey = normalizeTopicKey(topic);

  try {
    const snapshot = await firestore
      .collection("users")
      .doc(userId)
      .collection("module_history")
      .where("topic", "==", topic.trim())
      .get();

    const history: ModuleHistoryEntry[] = [];

    snapshot.forEach((doc) => {
      const data = doc.data();
      const moduleNumber = data.moduleNumber as number;

      if (moduleNumber < upToModuleNumber) {
        history.push({
          moduleNumber,
          title: data.title || `Module ${moduleNumber}`,
          lessonTitles: Array.isArray(data.lessonTitles)
            ? data.lessonTitles
            : [],
          skillsTargeted: Array.isArray(data.skillsTargeted)
            ? data.skillsTargeted
            : [],
          generatedAt:
            data.generatedAt?.toMillis?.() || data.generatedAt || Date.now(),
          durationMinutes: data.durationMinutes,
        });
      }
    });

    // Sort by module number ascending
    history.sort((a, b) => a.moduleNumber - b.moduleNumber);

    logger.info(
      `[ModuleHistory] Loaded ${history.length} modules for user ${userId}, topic "${topic}"`
    );

    return history;
  } catch (error) {
    logger.error("[ModuleHistory] Failed to load history:", error);
    return []; // Return empty on error - generation can continue without history
  }
}

/**
 * Format module history for inclusion in GPT prompts
 * Returns a compact, readable summary of previous modules
 */
export function formatHistoryForPrompt(
  history: ModuleHistoryEntry[]
): string {
  if (history.length === 0) {
    return "";
  }

  const lines = ["\n\nMÓDULOS YA COMPLETADOS POR EL USUARIO:"];

  history.forEach((module) => {
    const lessonList =
      module.lessonTitles.length > 0
        ? module.lessonTitles.join(", ")
        : "Sin lecciones registradas";
    const skillList =
      module.skillsTargeted.length > 0
        ? module.skillsTargeted.join(", ")
        : "Sin skills registradas";

    lines.push(`\nM${module.moduleNumber}: "${module.title}"`);
    lines.push(`  Lecciones: ${lessonList}`);
    lines.push(`  Skills cubiertos: ${skillList}`);
  });

  lines.push(
    "\n\nIMPORTANTE: El nuevo módulo debe CONTINUAR y PROFUNDIZAR desde donde terminaron los módulos anteriores."
  );
  lines.push(
    "NO repitas temas, conceptos o lecciones que ya fueron cubiertos en los módulos anteriores."
  );
  lines.push(
    "Asume que el usuario ya domina los conceptos base de los módulos completados."
  );
  lines.push("Enfócate en expandir, profundizar y aplicar conceptos más avanzados.");

  return lines.join("\n");
}

/**
 * Normalize topic to use as Firestore key
 */
function normalizeTopicKey(topic: string): string {
  return topic
    .trim()
    .toLowerCase()
    .replace(/\s+/g, "_")
    .replace(/[^a-z0-9_]/g, "");
}

/**
 * Clean up old module history (optional maintenance function)
 * Can be called periodically to remove very old entries
 */
export async function cleanupOldHistory(
  userId: string,
  olderThanDays: number = 90
): Promise<number> {
  const cutoffDate = Date.now() - olderThanDays * 24 * 60 * 60 * 1000;
  let deleted = 0;

  try {
    const snapshot = await firestore
      .collection("users")
      .doc(userId)
      .collection("module_history")
      .where("generatedAt", "<", cutoffDate)
      .get();

    const batch = firestore.batch();

    snapshot.forEach((doc) => {
      batch.delete(doc.ref);
      deleted++;
    });

    if (deleted > 0) {
      await batch.commit();
      logger.info(
        `[ModuleHistory] Cleaned up ${deleted} old entries for user ${userId}`
      );
    }

    return deleted;
  } catch (error) {
    logger.error("[ModuleHistory] Failed to cleanup old history:", error);
    return 0;
  }
}
