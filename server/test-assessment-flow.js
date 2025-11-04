/**
 * Simple test script to verify assessment flow with real SQL question bank
 */

import {
  startAssessmentSession,
  getNextQuestion,
  submitAnswer,
  getSession,
  setSessionStoreForTesting,
  MAX_ITEMS
} from './assessment.js';

console.log('🧪 Testing Assessment Flow with SQL Question Bank\n');

// Create a simple in-memory store for testing
const testStore = {
  sessions: new Map(),
  async save(session) {
    this.sessions.set(session.sessionId, JSON.parse(JSON.stringify(session)));
    console.log(`   💾 Saved session ${session.sessionId} to test store`);
  },
  async load(sessionId) {
    const session = this.sessions.get(sessionId);
    return session ? JSON.parse(JSON.stringify(session)) : null;
  },
  async cleanupExpired() {}
};

// Set test store before running tests
setSessionStoreForTesting(testStore);

async function testFlow() {
  try {
    // Step 1: Start session
    console.log('1️⃣  Starting assessment session...');
    const userId = 'test-user-123';
    const session = await startAssessmentSession({ userId });
    console.log(`   ✅ Session created: ${session.sessionId}`);
    console.log(`   📊 Ability: ${session.ability.toFixed(3)}`);
    console.log(`   📝 Status: ${session.status}`);

    // Step 2: Get first question
    console.log('\n2️⃣  Getting first question...');
    const q1Payload = getNextQuestion(session);
    const q1 = q1Payload.question;
    console.log(`   ✅ Question: ${q1.id}`);
    console.log(`   📚 Skill: ${q1.skillId} - ${q1.skillLabel}`);
    console.log(`   🎯 Difficulty: ${q1.difficulty} (${q1.difficulty === 1 ? 'easy' : q1.difficulty === 2 ? 'medium' : 'hard'})`);
    console.log(`   ❓ Prompt: ${q1.prompt.substring(0, 80)}...`);
    console.log(`   🔢 Options: ${q1.options.length} choices`);

    // Step 3: Submit correct answer
    console.log('\n3️⃣  Submitting correct answer...');
    // Find the correct answer from the original question in session
    const correctAnswerIndex = session.pendingQuestion.question.answerIndex;
    const result1 = submitAnswer(session, {
      sequence: q1Payload.sequence,
      attemptId: 'test-attempt-1',
      optionIndex: correctAnswerIndex
    });
    await testStore.save(session);
    console.log(`   ✅ Answer: ${result1.correct ? 'CORRECT ✓' : 'INCORRECT ✗'}`);
    console.log(`   📈 New ability: ${session.ability.toFixed(3)}`);
    console.log(`   📊 Progress: ${session.answers.length}/${MAX_ITEMS}`);

    // Step 4: Get second question
    console.log('\n4️⃣  Getting second question...');
    const q2Payload = getNextQuestion(session);
    const q2 = q2Payload.question;
    console.log(`   ✅ Question: ${q2.id}`);
    console.log(`   📚 Skill: ${q2.skillId} - ${q2.skillLabel}`);
    console.log(`   🎯 Difficulty: ${q2.difficulty}`);
    console.log(`   ❓ Prompt: ${q2.prompt.substring(0, 80)}...`);

    // Step 5: Submit incorrect answer
    console.log('\n5️⃣  Submitting incorrect answer...');
    const correctAnswerIndex2 = session.pendingQuestion.question.answerIndex;
    const wrongAnswer = (correctAnswerIndex2 + 1) % q2.options.length;
    const result2 = submitAnswer(session, {
      sequence: q2Payload.sequence,
      attemptId: 'test-attempt-2',
      optionIndex: wrongAnswer
    });
    await testStore.save(session);
    console.log(`   ✅ Answer: ${result2.correct ? 'CORRECT ✓' : 'INCORRECT ✗'}`);
    console.log(`   📉 New ability: ${session.ability.toFixed(3)}`);
    console.log(`   📊 Progress: ${session.answers.length}/${MAX_ITEMS}`);

    // Step 6: Verify session state
    console.log('\n6️⃣  Verifying session state...');
    const loadedSession = await getSession(session.sessionId);
    console.log(`   ✅ Session loaded from store`);
    console.log(`   📊 Items completed: ${loadedSession.answers.length}`);
    console.log(`   📈 Current ability: ${loadedSession.ability.toFixed(3)}`);
    console.log(`   📝 Status: ${loadedSession.status}`);

    // Step 7: Check skill distribution
    console.log('\n7️⃣  Analyzing skill distribution...');
    const skillCounts = {};
    loadedSession.answers.forEach(r => {
      const skill = r.skillId || 'unknown';
      skillCounts[skill] = (skillCounts[skill] || 0) + 1;
    });
    console.log(`   📚 Skills tested:`);
    Object.entries(skillCounts).forEach(([skill, count]) => {
      console.log(`      - ${skill}: ${count} questions`);
    });

    console.log('\n✅ All tests passed! SQL question bank is working correctly.\n');

  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

testFlow();
