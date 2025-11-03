import { randomUUID } from 'node:crypto';
import { getApps, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const MAX_ITEMS = 68;
const EARLY_STOP_ITEM = 8;
const EARLY_STOP_CONFIDENCE = 0.72;
const MIN_EARLY_RESPONSES = 4;
const SESSION_TTL_MS = 45 * 60 * 1000; // 45 minutes
const ABILITY_MIN = -3;
const ABILITY_MAX = 3;
const PRIOR_DIFFICULTY_WEIGHT = 1.0;
const PRIOR_CORRECT_WEIGHT = PRIOR_DIFFICULTY_WEIGHT / 2;
const DEFAULT_GUESS_PENALTY = 0.15;
const DEFAULT_GUESS_LATENCY_THRESHOLD_MS = 800;
const IRT_PARAMS_BY_DIFFICULTY = new Map([
  [
    1,
    {
      a: 0.95,
      b: -0.8,
      c: 0.2,
    },
  ],
  [
    2,
    {
      a: 1.1,
      b: 0,
      c: 0.18,
    },
  ],
  [
    3,
    {
      a: 1.35,
      b: 0.8,
      c: 0.25,
    },
  ],
]);
const ABILITY_UPDATE_STEP = 0.4;

const firestoreApp = getApps().length ? getApps()[0] : initializeApp();
const firestore = getFirestore(firestoreApp);
const sessionsCollection = firestore.collection('assessment_sessions');

const defaultSessionStore = {
  async save(session) {
    const payload = serializeSession(session);
    await sessionsCollection.doc(session.sessionId).set(payload);
  },
  async load(sessionId) {
    const snapshot = await sessionsCollection.doc(sessionId).get();
    if (!snapshot.exists) {
      return null;
    }
    return deserializeSession(snapshot.data());
  },
  async cleanupExpired(now = Date.now()) {
    const cutoff = new Date(now);
    const expiredSnapshot = await sessionsCollection
      .where('status', '==', 'active')
      .where('expiresAt', '<=', cutoff)
      .orderBy('expiresAt', 'asc')
      .limit(25)
      .get();

    const updates = [];
    expiredSnapshot.forEach((doc) => {
      const data = doc.data();
      updates.push(
        sessionsCollection.doc(doc.id).update({
          status: 'expired',
          finishedAt: new Date(now),
        }),
      );
    });

    if (updates.length) {
      await Promise.allSettled(updates);
    }
  },
};

let sessionStore = defaultSessionStore;
function getIrtParamsForQuestion(question) {
  const params = question?.irt;
  if (
    params &&
    typeof params.a === 'number' &&
    typeof params.b === 'number' &&
    typeof params.c === 'number'
  ) {
    return {
      a: params.a,
      b: params.b,
      c: params.c,
    };
  }
  const fallback =
    IRT_PARAMS_BY_DIFFICULTY.get(question?.difficulty) ??
    IRT_PARAMS_BY_DIFFICULTY.get(2);
  return { ...fallback };
}

function irtProbability(theta, params) {
  const { a, b, c } = params;
  return c + (1 - c) / (1 + Math.exp(-a * (theta - b)));
}

const WARMUP_CONFIDENCE_THRESHOLD = 0.55;
const WARMUP_RECENT_WINDOW = 3;
const WARMUP_FAILURE_THRESHOLD = 2;

const difficultyWeight = new Map([
  [1, 0.45],
  [2, 0.7],
  [3, 0.9],
]);

const SKILLS = [
  { id: 'numeracy', label: 'Numeracy' },
  { id: 'logic', label: 'Razonamiento' },
  { id: 'data', label: 'Data Literacy' },
  { id: 'communication', label: 'Comunicaci\u00f3n' },
];

function buildInitialSkillStats() {
  return new Map(
    SKILLS.map((skill) => [
      skill.id,
      {
        total: 0,
        correct: 0,
        totalDifficulty: 0,
        correctDifficulty: 0,
      },
    ])
  );
}

function serializeSession(session) {
  return {
    sessionId: session.sessionId,
    status: session.status,
    createdAt: session.createdAt,
    updatedAt: session.updatedAt,
    expiresAt: session.expiresAt,
    finishedAt: session.finishedAt ?? null,
    finishReason: session.finishReason ?? null,
    userId: session.userId,
    topic: session.topic,
    courseId: session.courseId,
    answers: session.answers,
    pendingQuestion: session.pendingQuestion,
    usedQuestionIds: Array.from(session.usedQuestionIds ?? []),
    nextSequence: session.nextSequence,
    ability: session.ability,
    confidence: session.confidence,
    level: session.level,
    correctCount: session.correctCount,
    totalDifficultySum: session.totalDifficultySum,
    correctDifficultySum: session.correctDifficultySum,
    skillStats: Array.from(session.skillStats?.entries() ?? []),
    attemptCache: Array.from(session.attemptCache?.entries() ?? []),
    scoring: session.scoring,
    lastSkillId: session.lastSkillId ?? null,
    recentAnswers: Array.isArray(session.recentAnswers)
      ? session.recentAnswers.map((value) => Boolean(value))
      : [],
  };
}

function deserializeSession(data = {}) {
  const skillStats = buildInitialSkillStats();
  const storedStats = Array.isArray(data.skillStats) ? data.skillStats : [];
  for (const entry of storedStats) {
    if (Array.isArray(entry) && entry.length === 2 && skillStats.has(entry[0])) {
      const stats = entry[1] ?? {};
      skillStats.set(entry[0], {
        total: Number(stats.total) || 0,
        correct: Number(stats.correct) || 0,
        totalDifficulty: Number(stats.totalDifficulty) || 0,
        correctDifficulty: Number(stats.correctDifficulty) || 0,
      });
    }
  }

  const attemptCacheEntries = Array.isArray(data.attemptCache) ? data.attemptCache : [];
  const attemptCache = new Map(
    attemptCacheEntries
      .filter((entry) => Array.isArray(entry) && entry.length === 2)
      .map(([key, value]) => [key, value])
  );

  const recentAnswers = Array.isArray(data.recentAnswers)
    ? data.recentAnswers.map((value) => Boolean(value))
    : [];

  return {
    sessionId: data.sessionId,
    status: data.status ?? 'active',
    createdAt: data.createdAt ?? new Date().toISOString(),
    updatedAt: data.updatedAt ?? new Date().toISOString(),
    expiresAt:
      data.expiresAt ?? new Date(Date.now() + SESSION_TTL_MS).toISOString(),
    finishedAt: data.finishedAt ?? null,
    finishReason: data.finishReason ?? null,
    userId: data.userId ?? null,
    topic: data.topic ?? null,
    courseId: data.courseId ?? null,
    answers: Array.isArray(data.answers) ? data.answers : [],
    pendingQuestion: data.pendingQuestion ?? null,
    usedQuestionIds: new Set(
      Array.isArray(data.usedQuestionIds) ? data.usedQuestionIds : []
    ),
    nextSequence:
      typeof data.nextSequence === 'number' && Number.isFinite(data.nextSequence)
        ? data.nextSequence
        : 1,
    ability:
      typeof data.ability === 'number' && Number.isFinite(data.ability)
        ? data.ability
        : 0,
    confidence:
      typeof data.confidence === 'number' && Number.isFinite(data.confidence)
        ? data.confidence
        : 0,
    level: typeof data.level === 'string' ? data.level : 'B\u00e1sico',
    correctCount:
      typeof data.correctCount === 'number' && Number.isFinite(data.correctCount)
        ? data.correctCount
        : 0,
    totalDifficultySum:
      typeof data.totalDifficultySum === 'number' &&
      Number.isFinite(data.totalDifficultySum)
        ? data.totalDifficultySum
        : 0,
    correctDifficultySum:
      typeof data.correctDifficultySum === 'number' &&
      Number.isFinite(data.correctDifficultySum)
        ? data.correctDifficultySum
        : 0,
    skillStats,
    attemptCache,
    scoring: normalizeScoring(data.scoring ?? {}),
    lastSkillId: data.lastSkillId ?? null,
    recentAnswers,
  };
}

async function persistSession(session) {
  if (!session || !session.sessionId) {
    throw new Error('Cannot persist session without sessionId');
  }
  await sessionStore.save(session);
}

async function loadSessionFromStore(sessionId) {
  const stored = await sessionStore.load(sessionId);
  if (!stored) {
    return null;
  }
  return stored;
}

function setSessionStoreForTesting(store) {
  if (
    !store ||
    typeof store.save !== 'function' ||
    typeof store.load !== 'function'
  ) {
    throw new Error('Invalid session store provided');
  }
  sessionStore = {
    save: store.save.bind(store),
    load: store.load.bind(store),
    cleanupExpired:
      typeof store.cleanupExpired === 'function'
        ? store.cleanupExpired.bind(store)
        : async () => {},
  };
}

function clearSessionCacheForTesting() {
  // no-op; legacy helper retained for backward compatibility
}

const QUESTION_BANK = buildQuestionBank();

function normalizeScoring(raw = {}) {
  const guessPenalty =
    typeof raw.guessPenalty === 'number' &&
    Number.isFinite(raw.guessPenalty) &&
    raw.guessPenalty >= 0
      ? raw.guessPenalty
      : DEFAULT_GUESS_PENALTY;
  const guessLatencyThresholdMs =
    typeof raw.guessLatencyThresholdMs === 'number' &&
    Number.isFinite(raw.guessLatencyThresholdMs) &&
    raw.guessLatencyThresholdMs > 0
      ? Math.floor(raw.guessLatencyThresholdMs)
      : DEFAULT_GUESS_LATENCY_THRESHOLD_MS;

  return {
    guessPenalty,
    guessLatencyThresholdMs,
  };
}

function normalizeLatencyMs(raw) {
  if (typeof raw === 'number' && Number.isFinite(raw) && raw >= 0) {
    return Math.floor(raw);
  }
  if (typeof raw === 'string') {
    const parsed = Number(raw.trim());
    if (!Number.isNaN(parsed) && Number.isFinite(parsed) && parsed >= 0) {
      return Math.floor(parsed);
    }
  }
  return null;
}

async function startAssessmentSession(input = {}) {
  const now = Date.now();
  const sessionId = randomUUID();
  const expiresAt = new Date(now + SESSION_TTL_MS).toISOString();
  const scoring = normalizeScoring(input.scoring ?? {});

  const session = {
    sessionId,
    status: 'active',
    createdAt: new Date(now).toISOString(),
    updatedAt: new Date(now).toISOString(),
    expiresAt,
    userId:
      typeof input.userId === 'string' && input.userId.trim()
        ? input.userId.trim()
        : null,
    topic:
      typeof input.topic === 'string' && input.topic.trim()
        ? input.topic.trim()
        : null,
    courseId:
      typeof input.courseId === 'string' && input.courseId.trim()
        ? input.courseId.trim()
        : null,
    answers: [],
    pendingQuestion: null,
    usedQuestionIds: new Set(),
    nextSequence: 1,
    ability: 0,
    confidence: 0,
    level: 'B\u00e1sico',
    correctCount: 0,
    totalDifficultySum: 0,
    correctDifficultySum: 0,
    skillStats: new Map(
      SKILLS.map((skill) => [
        skill.id,
        {
          correct: 0,
          total: 0,
          correctDifficulty: 0,
          totalDifficulty: 0,
        },
      ]),
    ),
    attemptCache: new Map(),
    finishReason: null,
    scoring,
    lastSkillId: null,
    recentAnswers: [],
  };

  await persistSession(session);
  cleanupExpiredSessions().catch((error) => {
    console.error('[assessment] failed to cleanup expired sessions', error);
  });

  return session;
}

async function getSession(sessionId) {
  if (typeof sessionId !== 'string' || !sessionId.trim()) {
    return null;
  }
  const key = sessionId.trim();
  const session = await loadSessionFromStore(key);
  if (!session) {
    return null;
  }

  const now = Date.now();
  if (session.status !== 'finished' && new Date(session.expiresAt).getTime() < now) {
    finishSession(session, 'expired');
    await persistSession(session);
  }

  return session;
}

async function cleanupExpiredSessions() {
  if (typeof sessionStore.cleanupExpired === 'function') {
    await sessionStore.cleanupExpired(Date.now());
  }
}

function getNextQuestion(session) {
  if (session.status === 'finished') {
    return null;
  }

  if (session.pendingQuestion) {
    return toQuestionPayload(session.pendingQuestion);
  }

  if (session.answers.length >= MAX_ITEMS) {
    finishSession(session, 'max_items');
    return null;
  }

  const question = pickNextQuestion(session);
  if (!question) {
    finishSession(session, 'exhausted');
    return null;
  }

  session.usedQuestionIds.add(question.id);
  const sequence = session.nextSequence++;
  session.pendingQuestion = {
    sessionId: session.sessionId,
    sequence,
    assignedAt: new Date().toISOString(),
    question,
    answeredBefore: session.answers.length,
  };
  session.lastSkillId = question.skillId;
  session.updatedAt = new Date().toISOString();

  return toQuestionPayload(session.pendingQuestion);
}

function submitAnswer(session, payload) {
  if (session.status === 'finished') {
    return { finished: true, summary: buildSummary(session) };
  }

  const { sequence, attemptId, optionIndex } = payload ?? {};

  if (
    typeof sequence !== 'number' ||
    !Number.isInteger(sequence) ||
    sequence <= 0
  ) {
    throw createHttpError(400, 'invalid_sequence');
  }

  if (typeof attemptId !== 'string' || !attemptId.trim()) {
    throw createHttpError(400, 'invalid_attempt_id');
  }

  if (
    typeof optionIndex !== 'number' ||
    !Number.isInteger(optionIndex) ||
    optionIndex < 0
  ) {
    throw createHttpError(400, 'invalid_option');
  }

  const cacheKey = `${sequence}|${attemptId.trim()}`;
  if (session.attemptCache.has(cacheKey)) {
    return session.attemptCache.get(cacheKey);
  }

  const pending = session.pendingQuestion;
  if (!pending || pending.sequence !== sequence) {
    const answered = session.answers.find((item) => item.sequence === sequence);
    if (answered) {
      throw createHttpError(409, 'sequence_already_answered');
    }
    throw createHttpError(409, 'sequence_not_pending');
  }

  const { question } = pending;
  if (optionIndex >= question.options.length) {
    throw createHttpError(400, 'invalid_option');
  }

  const isCorrect = question.answerIndex === optionIndex;

  session.pendingQuestion = null;

  const diffWeight = difficultyWeight.get(question.difficulty) ?? 0.6;
  session.totalDifficultySum += diffWeight;
  if (isCorrect) {
    session.correctDifficultySum += diffWeight;
    session.correctCount += 1;
  }

  const skillStat = session.skillStats.get(question.skillId);
  skillStat.total += 1;
  skillStat.totalDifficulty += diffWeight;
  if (isCorrect) {
    skillStat.correct += 1;
    skillStat.correctDifficulty += diffWeight;
  }

  const scoring = session.scoring ?? normalizeScoring();
  const latencyMs = normalizeLatencyMs(payload?.latencyMs);
  const guessPenaltyApplied =
    latencyMs !== null && latencyMs < scoring.guessLatencyThresholdMs;

  const irtParams = getIrtParamsForQuestion(question);
  const abilityBefore = session.ability ?? 0;
  const probability = irtProbability(abilityBefore, irtParams);
  const boundedProbability = clamp(probability, 0.01, 0.99);
  const observed = isCorrect ? 1 : 0;
  const gradient =
    (irtParams.a * (observed - boundedProbability)) /
    (boundedProbability * (1 - boundedProbability));

  let abilityAfter = abilityBefore + ABILITY_UPDATE_STEP * gradient;
  if (guessPenaltyApplied) {
    abilityAfter -= scoring.guessPenalty;
  }
  abilityAfter = clamp(abilityAfter, ABILITY_MIN, ABILITY_MAX);
  const abilityDelta = abilityAfter - abilityBefore;

  session.ability = abilityAfter;
  session.recentAnswers.push(Boolean(isCorrect));
  if (session.recentAnswers.length > WARMUP_RECENT_WINDOW) {
    session.recentAnswers.shift();
  }

  const answered = session.answers.length + 1;
  const correctRate = session.correctCount / answered;
  session.confidence = computeConfidence({
    answered,
    ability: session.ability,
    correctRate,
  });
  session.level = abilityToLevel(session.ability);

  const answerRecord = {
    sequence,
    questionId: question.id,
    skillId: question.skillId,
    difficulty: question.difficulty,
    optionIndex,
    correct: isCorrect,
    latencyMs,
    guessPenaltyApplied,
    abilityDelta,
    abilityAfter: session.ability,
    answeredAt: new Date().toISOString(),
  };

  session.answers.push(answerRecord);
  session.updatedAt = answerRecord.answeredAt;

  const finished =
    session.answers.length >= MAX_ITEMS ||
    (session.answers.length >= MIN_EARLY_RESPONSES &&
      session.answers.length < EARLY_STOP_ITEM &&
      session.confidence >= EARLY_STOP_CONFIDENCE);

  if (finished) {
    const reason =
      session.answers.length >= MAX_ITEMS ? 'max_items' : 'early_stop';
    finishSession(session, reason);
  }

  const responsePayload = {
    sessionId: session.sessionId,
    sequence,
    correct: isCorrect,
    finished,
    level: session.level,
    confidence: roundDecimal(session.confidence),
    ability: roundDecimal(session.ability),
    totalAnswered: session.answers.length,
    remaining: Math.max(0, MAX_ITEMS - session.answers.length),
    latencyMs,
    guessPenaltyApplied,
    warmupEligible: shouldOfferWarmup(session),
    skillProfile: buildSkillProfile(session),
  };

  session.attemptCache.set(cacheKey, responsePayload);
  return responsePayload;
}

function finishSession(session, reason = 'manual') {
  if (session.status === 'finished') {
    return session;
  }
  session.status = 'finished';
  session.finishReason = reason;
  session.finishedAt = new Date().toISOString();
  session.pendingQuestion = null;
  session.updatedAt = session.finishedAt;
  session.confidence = session.confidence ?? 0;
  session.level = abilityToLevel(session.ability ?? 0);
  return session;
}

function getSessionState(session) {
  return {
    sessionId: session.sessionId,
    status: session.status,
    createdAt: session.createdAt,
    updatedAt: session.updatedAt,
    expiresAt: session.expiresAt,
    finishedAt: session.finishedAt ?? null,
    finishReason: session.finishReason,
    level: session.level,
    confidence: roundDecimal(session.confidence ?? 0),
    ability: roundDecimal(session.ability ?? 0),
    totalAnswered: session.answers.length,
    totalCorrect: session.correctCount,
    remaining: Math.max(0, MAX_ITEMS - session.answers.length),
    nextSequence: session.status === 'finished' ? null : session.nextSequence,
    pendingQuestion:
      session.pendingQuestion && session.status !== 'finished'
        ? toQuestionPayload(session.pendingQuestion)
        : null,
    skillProfile: buildSkillProfile(session),
    warmupEligible: shouldOfferWarmup(session),
    config: {
      maxItems: MAX_ITEMS,
      earlyStopConfidence: EARLY_STOP_CONFIDENCE,
      earlyStopItem: EARLY_STOP_ITEM,
      minEarlyResponses: MIN_EARLY_RESPONSES,
    },
  };
}

function buildSkillProfile(session) {
  return SKILLS.map((skill) => {
    const stats = session.skillStats.get(skill.id);
    const accuracy =
      stats.total > 0 ? stats.correct / stats.total : 0;
    const skillTotalWeight =
      stats.totalDifficulty + PRIOR_DIFFICULTY_WEIGHT;
    const skillCorrectWeight =
      stats.correctDifficulty + PRIOR_CORRECT_WEIGHT;
    const probability = skillCorrectWeight / skillTotalWeight;
    const abilityValue = probabilityToAbility(probability);
    const confidence = stats.total
      ? computeConfidence({
          answered: stats.total,
          ability: abilityValue,
          correctRate: accuracy,
        })
      : 0;

    return {
      skillId: skill.id,
      label: skill.label,
      total: stats.total,
      correct: stats.correct,
      accuracy: roundDecimal(accuracy),
      level: abilityToLevel(abilityValue),
      confidence: roundDecimal(confidence),
    };
  });
}

function abilityToDifficultyTarget(ability) {
  const scaled = 2 + ability / 1.5;
  return clamp(scaled, 1, 3);
}

function itemInformation(ability, question) {
  const params = getIrtParamsForQuestion(question);
  const probability = irtProbability(ability, params);
  const boundedProbability = clamp(probability, 0.01, 0.99);
  return params.a * params.a * boundedProbability * (1 - boundedProbability);
}

function pickNextQuestion(session) {
  const used = session.usedQuestionIds;
  const available = QUESTION_BANK.filter((question) => !used.has(question.id));

  if (!available.length) {
    return null;
  }

  const ability = session.ability ?? 0;
  const targetDifficulty = abilityToDifficultyTarget(ability);

  const coverageForSkill = (skillId) =>
    session.skillStats.get(skillId)?.total ?? 0;

  let minCoverage = Number.POSITIVE_INFINITY;
  for (const question of available) {
    minCoverage = Math.min(minCoverage, coverageForSkill(question.skillId));
  }

  let candidates = available.filter(
    (question) => coverageForSkill(question.skillId) === minCoverage,
  );

  const lastSkillId = session.lastSkillId;
  if (lastSkillId) {
    const withoutRepeat = candidates.filter(
      (question) => question.skillId !== lastSkillId,
    );
    if (withoutRepeat.length) {
      candidates = withoutRepeat;
    }
  }

  const sorted = [...candidates].sort((a, b) => {
    const gapA = Math.abs(a.difficulty - targetDifficulty);
    const gapB = Math.abs(b.difficulty - targetDifficulty);
    if (Math.abs(gapA - gapB) > 0.0001) {
      return gapA - gapB;
    }

    const infoA = itemInformation(ability, a);
    const infoB = itemInformation(ability, b);
    if (Math.abs(infoA - infoB) > 0.0001) {
      return infoB - infoA;
    }

    const coverageA = coverageForSkill(a.skillId);
    const coverageB = coverageForSkill(b.skillId);
    if (coverageA !== coverageB) {
      return coverageA - coverageB;
    }

    return a.index - b.index;
  });

  return sorted[0] ?? null;
}

function toQuestionPayload(pending) {
  return {
    sessionId: pending.sessionId,
    sequence: pending.sequence,
    issuedAt: pending.assignedAt,
    question: {
      id: pending.question.id,
      prompt: pending.question.prompt,
      options: pending.question.options.map((option, index) => ({
        index,
        label: option,
      })),
      skillId: pending.question.skillId,
      skillLabel: pending.question.skillLabel,
      difficulty: pending.question.difficulty,
      type: pending.question.type,
    },
    progress: {
      total: MAX_ITEMS,
      answered: pending.answeredBefore ?? 0,
      remaining: Math.max(
        0,
        MAX_ITEMS - (pending.answeredBefore ?? 0) - 1,
      ),
    },
  };
}

function computeConfidence({ answered, ability, correctRate }) {
  if (!answered || answered <= 0) {
    return 0;
  }
  const abilityProbability = abilityToProbability(ability);
  const boundedRate = clamp(correctRate, 0, 1);
  const knowledgeScore = abilityProbability * Math.min(1, answered / 5);
  const progressBoost = Math.min(1, answered / EARLY_STOP_ITEM);
  const spread = Math.sqrt(boundedRate * (1 - boundedRate));
  const stability = 1 - Math.min(0.5, spread);

  const confidence =
    knowledgeScore * 0.6 + progressBoost * 0.3 + stability * 0.1;
  return clamp(confidence, 0, 0.99);
}

function abilityToLevel(ability) {
  const value = clamp(ability, ABILITY_MIN, ABILITY_MAX);
  if (value < 0.5) {
    return 'B\u00e1sico';
  }
  if (value < 1.5) {
    return 'Intermedio';
  }
  return 'Avanzado';
}

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

function abilityToProbability(ability) {
  const bounded = clamp(ability, ABILITY_MIN, ABILITY_MAX);
  const exp = Math.exp(-bounded);
  return 1 / (1 + exp);
}

function probabilityToAbility(probability) {
  const clamped = clamp(probability, 0.01, 0.99);
  const value = Math.log(clamped / (1 - clamped));
  return clamp(value, ABILITY_MIN, ABILITY_MAX);
}

function roundDecimal(value) {
  return Math.round(value * 1000) / 1000;
}

function createHttpError(status, code) {
  const error = new Error(code);
  error.status = status;
  error.code = code;
  return error;
}

function buildQuestionBank() {
  const questions = [];
  const skillCount = SKILLS.length;

  for (let index = 0; index < MAX_ITEMS; index += 1) {
    const skill = SKILLS[index % skillCount];
    const difficulty =
      (Math.floor(index / skillCount) % 3) + 1;

    const question = createQuestion({
      index,
      skill,
      difficulty,
    });

    questions.push(question);
  }

  return questions;
}

function createQuestion({ index, skill, difficulty }) {
  switch (skill.id) {
    case 'numeracy':
      return createNumeracyQuestion(index, skill, difficulty);
    case 'logic':
      return createLogicQuestion(index, skill, difficulty);
    case 'data':
      return createDataQuestion(index, skill, difficulty);
    default:
      return createCommunicationQuestion(index, skill, difficulty);
  }
}

function createNumeracyQuestion(index, skill, difficulty) {
  const base = 8 + (index % 7) * (difficulty + 1);
  const a = base + 5 + difficulty;
  const b = base - (2 + (index % 3));
  const correct = a + b;
  const options = buildNumericOptions(correct, difficulty);
  const answerIndex = options.indexOf(correct);

  return {
    id: `Q${index + 1}`,
    index,
    prompt: `Cual es la suma de ${a} + ${b}?`,
    options: options.map((value) => value.toString()),
    answerIndex,
    difficulty,
    irt: getIrtParamsForQuestion({ difficulty }),
    skillId: skill.id,
    skillLabel: skill.label,
    type: 'multiple_choice',
    rationale: `Sumar ${a} y ${b} produce ${correct}.`,
  };
}

function createLogicQuestion(index, skill, difficulty) {
  const start = 2 + (index % 5) * (difficulty + 1);
  const step = 1 + difficulty + (index % 3);
  const missingPosition = (index % 3) + 1;
  const sequence = [];
  for (let i = 0; i < 5; i += 1) {
    if (i === missingPosition) {
      sequence.push('___');
    } else {
      const value = start + step * i;
      sequence.push(value);
    }
  }
  const correct = start + step * missingPosition;
  const distractors = [
    correct + step,
    correct - step,
    correct + step * 2,
  ];
  const options = uniqueOptions([correct, ...distractors]);
  const answerIndex = options.indexOf(correct);

  return {
    id: `Q${index + 1}`,
    index,
    prompt: `Completa la secuencia: ${sequence.join(', ')}`,
    options: options.map((value) => value.toString()),
    answerIndex,
    difficulty,
    irt: getIrtParamsForQuestion({ difficulty }),
    skillId: skill.id,
    skillLabel: skill.label,
    type: 'multiple_choice',
    rationale: `La progresion suma ${step} en cada paso, por eso el valor faltante es ${correct}.`,
  };
}

function createDataQuestion(index, skill, difficulty) {
  const values = [
    12 + (index % 4) * (difficulty + 2),
    18 + (index % 5) * (difficulty + 1),
    22 + (index % 3) * (difficulty + 2),
    16 + (index % 6),
  ];
  const sample = values.slice(0, 3 + (difficulty % 2));
  const total = sample.reduce((sum, value) => sum + value, 0);
  const average = Math.round(total / sample.length);

  const options = uniqueOptions([
    average,
    average + (2 * difficulty + 1),
    average - (difficulty + 2),
    average + 5,
  ]);
  const answerIndex = options.indexOf(average);

  return {
    id: `Q${index + 1}`,
    index,
    prompt: `Un conjunto de datos contiene los valores ${sample.join(', ')}. Cual es el promedio aproximado?`,
    options: options.map((value) => value.toString()),
    answerIndex,
    difficulty,
    irt: getIrtParamsForQuestion({ difficulty }),
    skillId: skill.id,
    skillLabel: skill.label,
    type: 'multiple_choice',
    rationale: `El promedio de ${sample.join(', ')} es ${average}.`,
  };
}

function createCommunicationQuestion(index, skill, difficulty) {
  const azul = 18 + (index % 5) * (difficulty + 1);
  const rojo = azul - (3 + difficulty);
  const verde = azul - 1;

  const prompt = [
    'Resumen del sprint:',
    `- Equipo Azul completo ${azul} historias.`,
    `- Equipo Rojo completo ${rojo} historias.`,
    `- Equipo Verde completo ${verde} historias.`,
    'Cual afirmacion esta respaldada por los datos?',
  ].join('\n');

  const options = [
    'El equipo Azul fue el que mas historias completo.',
    'El equipo Rojo supero al equipo Verde en historias completadas.',
    'El equipo Verde y el equipo Azul completaron la misma cantidad de historias.',
    'El equipo Rojo termino mas historias que el equipo Azul.',
  ];

  const answerIndex = 0;

  return {
    id: `Q${index + 1}`,
    index,
    prompt,
    options,
    answerIndex,
    difficulty,
    irt: getIrtParamsForQuestion({ difficulty }),
    skillId: skill.id,
    skillLabel: skill.label,
    type: 'multiple_choice',
    rationale: `El equipo Azul registra ${azul} historias frente a Rojo (${rojo}) y Verde (${verde}).`,
  };
}
function buildNumericOptions(correct, difficulty) {
  const offsets = [-(difficulty + 2), difficulty + 3, -3, 5 + difficulty];
  const options = new Set([correct]);

  for (const offset of offsets) {
    let candidate = correct + offset;
    if (candidate < 0) {
      candidate = Math.abs(candidate) + difficulty + 4;
    }
    options.add(candidate);
    if (options.size === 4) {
      break;
    }
  }

  while (options.size < 4) {
    options.add(correct + options.size + difficulty);
  }

  return Array.from(options).slice(0, 4);
}

function uniqueOptions(values) {
  const unique = [];
  for (const value of values) {
    if (!unique.includes(value)) {
      unique.push(value);
    }
    if (unique.length === 4) {
      break;
    }
  }

  while (unique.length < 4) {
    unique.push(unique[unique.length - 1] + 2);
  }

  return unique;
}

function shouldOfferWarmup(session) {
  if (!Array.isArray(session.recentAnswers) || session.recentAnswers.length === 0) {
    return false;
  }
  const window = session.recentAnswers.slice(
    Math.max(session.recentAnswers.length - WARMUP_RECENT_WINDOW, 0),
  );
  if (window.length < WARMUP_RECENT_WINDOW) {
    return false;
  }
  const failures = window.filter((entry) => entry === false).length;
  return (
    session.confidence < WARMUP_CONFIDENCE_THRESHOLD &&
    failures >= WARMUP_FAILURE_THRESHOLD
  );
}

function buildSummary(session) {
  return {
    sessionId: session.sessionId,
    status: session.status,
    finishReason: session.finishReason,
    totalAnswered: session.answers.length,
    totalCorrect: session.correctCount,
    level: session.level,
    confidence: roundDecimal(session.confidence ?? 0),
    ability: roundDecimal(session.ability ?? 0),
    warmupEligible: shouldOfferWarmup(session),
    skillProfile: buildSkillProfile(session),
  };
}

export {
  MAX_ITEMS,
  EARLY_STOP_CONFIDENCE,
  EARLY_STOP_ITEM,
  MIN_EARLY_RESPONSES,
  startAssessmentSession,
  getSession,
  getNextQuestion,
  submitAnswer,
  finishSession,
  getSessionState,
  createHttpError,
  buildSummary,
  persistSession,
  setSessionStoreForTesting,
  serializeSession as __serializeSessionForTests,
  deserializeSession as __deserializeSessionForTests,
  clearSessionCacheForTesting as __clearSessionCacheForTests,
};
