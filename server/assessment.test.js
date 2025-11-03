import test, { beforeEach } from 'node:test';
import assert from 'node:assert/strict';

import {
  startAssessmentSession,
  getSession,
  getNextQuestion,
  submitAnswer,
  persistSession,
  setSessionStoreForTesting,
  __serializeSessionForTests,
  __deserializeSessionForTests,
  __clearSessionCacheForTests,
} from './assessment.js';

const memoryStore = new Map();

setSessionStoreForTesting({
  async save(session) {
    const serialized = __serializeSessionForTests(session);
    const cloned = JSON.parse(JSON.stringify(serialized));
    memoryStore.set(session.sessionId, cloned);
  },
  async load(sessionId) {
    const record = memoryStore.get(sessionId);
    if (!record) {
      return null;
    }
    const cloned = JSON.parse(JSON.stringify(record));
    return __deserializeSessionForTests(cloned);
  },
});

beforeEach(() => {
  memoryStore.clear();
  __clearSessionCacheForTests();
});

test('startAssessmentSession persists sessions to the store', async () => {
  const session = await startAssessmentSession({
    userId: 'tester-1',
    topic: 'SQL marketing',
  });

  assert.equal(memoryStore.size, 1);

  __clearSessionCacheForTests();
  const reloaded = await getSession(session.sessionId);
  assert.ok(reloaded);
  assert.equal(reloaded.sessionId, session.sessionId);
  assert.equal(reloaded.userId, 'tester-1');
});

test('IRT ability updates react to correct and incorrect answers', async () => {
  const session = await startAssessmentSession({
    userId: 'tester-2',
    topic: 'SQL analytics',
  });
  const sessionId = session.sessionId;

  const initialAbility = session.ability ?? 0;

  const firstQuestion = getNextQuestion(session);
  await persistSession(session);
  assert.ok(firstQuestion);

  const firstPendingQuestion = session.pendingQuestion?.question;
  assert.ok(firstPendingQuestion);
  const correctIndex = firstPendingQuestion.answerIndex;
  submitAnswer(session, {
    sequence: firstQuestion.sequence,
    attemptId: 'attempt-1',
    optionIndex: correctIndex,
  });
  await persistSession(session);

  const abilityAfterCorrect = session.ability ?? 0;
  assert.ok(
    abilityAfterCorrect > initialAbility,
    `ability should increase after correct answer (was ${initialAbility}, now ${abilityAfterCorrect})`
  );

  const secondQuestion = getNextQuestion(session);
  await persistSession(session);
  assert.ok(secondQuestion);

  const abilityBeforeWrong = session.ability ?? 0;
  const secondPendingQuestion = session.pendingQuestion?.question;
  assert.ok(secondPendingQuestion);
  const wrongIndex =
    (secondPendingQuestion.answerIndex + 1) %
    secondPendingQuestion.options.length;

  submitAnswer(session, {
    sequence: secondQuestion.sequence,
    attemptId: 'attempt-2',
    optionIndex: wrongIndex,
  });
  await persistSession(session);

  const abilityAfterWrong = session.ability ?? 0;
  assert.ok(
    abilityAfterWrong < abilityBeforeWrong,
    `ability should decrease after wrong answer (was ${abilityBeforeWrong}, now ${abilityAfterWrong})`
  );

  __clearSessionCacheForTests();
  const persisted = await getSession(sessionId);
  assert.ok(persisted);
  assert.equal(persisted.sessionId, sessionId);
  assert.equal(persisted.ability, session.ability);
});
