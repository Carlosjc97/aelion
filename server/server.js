import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import nodeFetch from 'node-fetch';

dotenv.config();

const fetchImpl = typeof globalThis.fetch === 'function' ? globalThis.fetch : nodeFetch;

const app = express();

app.use(cors({ origin: '*' }));
app.use(express.json());
app.use((req, res, next) => {
  res.set('X-Revision', process.env.ROLLOUT || 'dev');
  next();
});

const OPENAI_ENDPOINT = 'https://api.openai.com/v1/chat/completions';
const DEFAULT_OPENAI_MODEL = process.env.OPENAI_MODEL || 'gpt-4o-mini';
const PORT = process.env.PORT || 8787;

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

app.get('/health', (_req, res) => {
  res.json({ ok: true });
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
