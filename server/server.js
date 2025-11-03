import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import nodeFetch from 'node-fetch';
import {
  EARLY_STOP_CONFIDENCE,
  EARLY_STOP_ITEM,
  MAX_ITEMS,
  finishSession as finishAssessmentSession,
  getNextQuestion,
  getSession,
  getSessionState,
  persistSession,
  startAssessmentSession,
  submitAnswer,
  buildSummary,
} from './assessment.js';
import {
  attachResponseTimestamp,
  enforceRateLimits,
  issueServerTimestamp,
  requireSignedTimestamp,
} from './security.js';

dotenv.config();

const fetchImpl = typeof globalThis.fetch === 'function' ? globalThis.fetch : nodeFetch;

const app = express();

const rawAllowedOrigins =
  process.env.SERVER_ALLOWED_ORIGINS ?? process.env.ALLOWED_ORIGINS ?? '';
const allowedOriginList = rawAllowedOrigins
  .split(',')
  .map((origin) => origin.trim())
  .filter((origin) => origin.length > 0);
const allowedOriginSet = new Set(allowedOriginList);
const isTestEnv = process.env.NODE_ENV === 'test';

if (allowedOriginSet.size === 0) {
  throw new Error(
    'SERVER_ALLOWED_ORIGINS must be configured (comma-separated) for every environment.'
  );
}

const corsOptions = {
  origin(origin, callback) {
    if (origin && allowedOriginSet.has(origin)) {
      return callback(null, true);
    }
    if (!origin && isTestEnv) {
      return callback(null, true);
    }
    return callback(new Error('forbidden_origin'));
  },
  allowedHeaders: [
    'Content-Type',
    'X-Server-Timestamp',
    'X-Server-Signature',
    'Authorization',
  ],
  exposedHeaders: ['X-Revision', 'X-Server-Timestamp', 'X-Server-Signature'],
  credentials: true,
  optionsSuccessStatus: 204,
};

const corsMiddleware = cors(corsOptions);

app.use((req, res, next) => {
  corsMiddleware(req, res, (err) => {
    if (err) {
      res.status(403).json({ error: 'forbidden_origin' });
      return;
    }
    next();
  });
});

app.use(attachResponseTimestamp);
app.use(express.json());
app.use((req, res, next) => {
  res.set('X-Revision', process.env.ROLLOUT || 'dev');
  next();
});

const OPENAI_ENDPOINT = 'https://api.openai.com/v1/chat/completions';
const DEFAULT_OPENAI_MODEL = process.env.OPENAI_MODEL || 'gpt-4o-mini';
const PORT = process.env.PORT || 8787;

function handleRateLimitError(res, error, scope) {
  if (error && typeof error.code === 'string' && error.code.startsWith('rate_limit')) {
    return res
      .status(error.status ?? 429)
      .json({ error: error.code, scope });
  }
  console.error(`[${scope}] rate limit check failed:`, error);
  return res.status(500).json({ error: 'server_error' });
}

function sanitizeApiKey(raw) {
  if (typeof raw !== 'string') {
    throw new Error('invalid_api_key');
  }

  const normalized = raw
    .trim()
    .replace(/^Bearer\s+/i, '')
    .replace(/^"(.*)"$/, '$1')
    .replace(/\r|\n/g, '');

  if (!normalized.startsWith('sk-')) {
    throw new Error('invalid_api_key');
  }

  return normalized;
}

async function callOpenAIChat(payload) {
  const key = sanitizeApiKey(process.env.OPENAI_API_KEY || '');

  const response = await fetchImpl(OPENAI_ENDPOINT, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${key}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  const bodyText = await response.text().catch(() => '');

  if (!response.ok) {
    console.error(
      '[/quiz] LLM HTTP error:',
      response.status,
      bodyText.slice(0, 2000)
    );
    throw new Error(`llm_http_${response.status}`);
  }

  try {
    return JSON.parse(bodyText);
  } catch (error) {
    console.error('[/quiz] Failed to parse LLM JSON:', bodyText.slice(0, 2000));
    throw error;
  }
}

function buildModules(topic, language) {
  const cleanedTopic = topic.trim();
  const normalizedLanguage = language.trim();
  const moduleCount = 3;
  const lessonsPerModule = 3;

  return Array.from({ length: moduleCount }, (_, moduleIndex) => {
    const moduleNumber = moduleIndex + 1;

    const lessons = Array.from({ length: lessonsPerModule }, (_, lessonIndex) => {
      const lessonNumber = lessonIndex + 1;
      return {
        id: `lesson-${moduleNumber}-${lessonNumber}`,
        title: `Lesson ${moduleNumber}.${lessonNumber} - ${cleanedTopic}`,
        language: normalizedLanguage,
      };
    });

    return {
      id: `module-${moduleNumber}`,
      title: `Module ${moduleNumber}: ${cleanedTopic}`,
      locked: moduleIndex > 0,
      lessons,
    };
  });
}

function buildBypassQuiz(numQuestions, topic, language) {
  const normalizedTopic = topic.trim();
  const normalizedLanguage = language.trim();
  return Array.from({ length: numQuestions }, (_, index) => {
    const questionNumber = index + 1;
    const seed = questionNumber % 4;
    const correctIndex = seed % 4;
    const options = Array.from({ length: 4 }, (_, optionIndex) => {
      return `Option ${optionIndex + 1} for ${normalizedTopic}`;
    });

    return {
      question: `Question ${questionNumber} about ${normalizedTopic} (${normalizedLanguage})`,
      options,
      answer: options[correctIndex],
    };
  });
}

app.post('/assessment/start', requireSignedTimestamp, async (req, res) => {
  try {
    enforceRateLimits(req, { userId: req.body?.userId });
  } catch (error) {
    return handleRateLimitError(res, error, '/assessment/start');
  }

  try {
    const session = await startAssessmentSession(req.body ?? {});
    const snapshot = getSessionState(session);
    res.status(201).json({
      sessionId: snapshot.sessionId,
      status: snapshot.status,
      createdAt: snapshot.createdAt,
      expiresAt: snapshot.expiresAt,
      level: snapshot.level,
      confidence: snapshot.confidence,
      ability: snapshot.ability,
      totalAnswered: snapshot.totalAnswered,
      remaining: snapshot.remaining,
      config: snapshot.config,
    });
  } catch (error) {
    console.error('[/assessment/start] failed:', error);
    res.status(400).json({ error: 'bad_request' });
  }
});

app.get('/assessment/:sessionId/state', requireSignedTimestamp, async (req, res) => {
  const session = await getSession(req.params.sessionId);
  if (!session) {
    return res.status(404).json({ error: 'session_not_found' });
  }

  try {
    enforceRateLimits(req, { session });
  } catch (error) {
    return handleRateLimitError(res, error, '/assessment/state');
  }

  res.json(getSessionState(session));
});

app.get('/assessment/:sessionId/next', requireSignedTimestamp, async (req, res) => {
  const session = await getSession(req.params.sessionId);
  if (!session) {
    return res.status(404).json({ error: 'session_not_found' });
  }

  try {
    enforceRateLimits(req, { session });
  } catch (error) {
    return handleRateLimitError(res, error, '/assessment/next');
  }

  try {
    const payload = getNextQuestion(session);
    await persistSession(session);

    if (!payload) {
      if (session.status === 'finished') {
        return res.status(409).json({
          error: 'session_completed',
          summary: buildSummary(session),
        });
      }
      return res.status(409).json({ error: 'no_more_questions' });
    }

    res.json({
      ...payload,
      config: {
        maxItems: MAX_ITEMS,
        earlyStopConfidence: EARLY_STOP_CONFIDENCE,
        earlyStopItem: EARLY_STOP_ITEM,
      },
    });
  } catch (error) {
    console.error('[/assessment/:sessionId/next] failed:', error);
    res.status(500).json({ error: 'server_error' });
  }
});

app.post('/assessment/:sessionId/answer', requireSignedTimestamp, async (req, res) => {
  const session = await getSession(req.params.sessionId);
  if (!session) {
    return res.status(404).json({ error: 'session_not_found' });
  }

  try {
    enforceRateLimits(req, { session });
  } catch (error) {
    return handleRateLimitError(res, error, '/assessment/answer');
  }

  try {
    const result = submitAnswer(session, req.body ?? {});
    await persistSession(session);
    res.json(result);
  } catch (error) {
    if (error && error.code) {
      return res.status(error.status ?? 400).json({ error: error.code });
    }
    console.error('[/assessment/:sessionId/answer] failed:', error);
    res.status(500).json({ error: 'server_error' });
  }
});

app.post('/assessment/:sessionId/finish', requireSignedTimestamp, async (req, res) => {
  const session = await getSession(req.params.sessionId);
  if (!session) {
    return res.status(404).json({ error: 'session_not_found' });
  }

  try {
    enforceRateLimits(req, { session });
  } catch (error) {
    return handleRateLimitError(res, error, '/assessment/finish');
  }

  const reason =
    typeof req.body?.reason === 'string' && req.body.reason.trim()
      ? req.body.reason.trim()
      : 'manual';
  finishAssessmentSession(session, reason);
  await persistSession(session);
  res.json(buildSummary(session));
});

app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

app.get('/server/timestamp', (_req, res) => {
  const payload = issueServerTimestamp();
  res.json(payload);
});

app.post('/outline', (req, res) => {
  const { topic, goal, language, level } = req.body ?? {};

  if (
    typeof topic !== 'string' ||
    !topic.trim() ||
    typeof goal !== 'string' ||
    !goal.trim() ||
    typeof language !== 'string' ||
    !language.trim()
  ) {
    return res.status(400).json({ error: 'bad_request' });
  }

  const cleanedTopic = topic.trim();
  const cleanedGoal = goal.trim();
  const cleanedLanguage = language.trim();
  const levelCandidate =
    typeof level === 'string' && level.trim() ? level.trim().toLowerCase() : '';

  const normalizedLevel = ['beginner', 'intermediate', 'advanced'].includes(
    levelCandidate
  )
    ? levelCandidate
    : 'beginner';

  const modules = buildModules(cleanedTopic, cleanedLanguage);
  const hoursPerModule =
    normalizedLevel === 'advanced'
      ? 5
      : normalizedLevel === 'intermediate'
      ? 4
      : 3;

  res.json({
    topic: cleanedTopic,
    level: normalizedLevel,
    estimated_hours: modules.length * hoursPerModule,
    modules,
    goal: cleanedGoal,
    language: cleanedLanguage,
  });
});

app.post('/quiz', async (req, res) => {
  const { topic, moduleTitle, numQuestions, language } = req.body ?? {};

  const chosenTopic =
    typeof topic === 'string' && topic.trim()
      ? topic.trim()
      : typeof moduleTitle === 'string' && moduleTitle.trim()
      ? moduleTitle.trim()
      : '';

  if (
    !chosenTopic ||
    typeof numQuestions !== 'number' ||
    Number.isNaN(numQuestions) ||
    numQuestions <= 0 ||
    typeof language !== 'string' ||
    !language.trim()
  ) {
    return res.status(400).json({ error: 'bad_request' });
  }

  const numericQuestions = Math.floor(numQuestions);
  const cleanedLanguage = language.trim();

  try {
    if (process.env.LLM_BYPASS === '1') {
      const questions = buildBypassQuiz(
        numericQuestions,
        chosenTopic,
        cleanedLanguage
      );
      return res.json({ questions });
    }

    const payload = {
      model: DEFAULT_OPENAI_MODEL,
      messages: [
        {
          role: 'system',
          content:
            'You are an educational assistant that must reply with valid JSON only.',
        },
        {
          role: 'user',
          content: [
            `Generate ${numericQuestions} multiple-choice questions about "${chosenTopic}" in ${cleanedLanguage}.`,
            'Return a pure JSON array with no extra text.',
            'Each item must be an object with question (string), options (array of 4 strings), and answer (string matching one of the options).',
          ].join(' '),
        },
      ],
      temperature: 0.4,
    };

    const data = await callOpenAIChat(payload);
    const content = data?.choices?.[0]?.message?.content ?? '';

    let questions;
    try {
      questions = JSON.parse(content);
    } catch {
      console.error('[/quiz] Non-JSON response from LLM:', content.slice(0, 2000));
      throw new Error('invalid_llm_payload');
    }

    if (!Array.isArray(questions)) {
      console.error('[/quiz] LLM payload is not an array:', content.slice(0, 2000));
      throw new Error('invalid_llm_payload');
    }

    return res.json({ questions });
  } catch (error) {
    console.error('[/quiz] LLM error:', error.message);
    return res.status(500).json({ error: 'server_error' });
  }
});

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`[server] listening on http://localhost:${PORT}`);
  });
}

export default app;
