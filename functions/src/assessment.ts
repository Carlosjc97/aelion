import { readFileSync } from "node:fs";
import { join } from "node:path";
import * as logger from "firebase-functions/logger";

interface IRTParams {
  a: number; // discrimination
  b: number; // difficulty
  c: number; // guessing
}

interface Question {
  id: string;
  module: string;
  module_name: string;
  type: string;
  difficulty: string;
  irt_params: IRTParams;
  question: string;
  options: string[];
  correct_answer: number;
  explanation: string;
  context: string;
  tags: string[];
}

interface QuestionBank {
  metadata: {
    track: string;
    version: string;
    language: string;
    total_questions: number;
    generated_date: string;
    author: string;
  };
  questions: Question[];
}

const questionBanks: Map<string, QuestionBank> = new Map();

/**
 * Load question bank from JSON file
 */
export function loadQuestionBank(language: string): QuestionBank {
  const lang = language.toLowerCase() === "es" ? "es" : "en";
  const cached = questionBanks.get(lang);
  if (cached) {
    return cached;
  }

  try {
    const dataPath = join(__dirname, "..", "data", `question-bank-${lang}.json`);
    const raw = readFileSync(dataPath, "utf-8");
    const bank: QuestionBank = JSON.parse(raw);

    logger.info(`Loaded question bank: ${lang} with ${bank.questions.length} questions`);
    questionBanks.set(lang, bank);
    return bank;
  } catch (error) {
    logger.error(`Failed to load question bank for ${lang}:`, error);
    throw new Error(`Question bank not available for language: ${lang}`);
  }
}

/**
 * Calculate IRT probability of correct response
 * P(correct) = c + (1 - c) / (1 + exp(-a * (theta - b)))
 */
function irtProbability(theta: number, params: IRTParams): number {
  const { a, b, c } = params;
  const exponent = -a * (theta - b);
  return c + (1 - c) / (1 + Math.exp(exponent));
}

/**
 * Select initial calibration questions using stratified sampling
 * Returns 10 questions across difficulty levels
 */
export function selectCalibrationQuestions(
  bank: QuestionBank,
  numQuestions = 10
): Question[] {
  const questions = bank.questions;

  // Stratify by difficulty
  const easy = questions.filter(q => q.irt_params.b < -0.5);
  const medium = questions.filter(q => q.irt_params.b >= -0.5 && q.irt_params.b <= 0.5);
  const hard = questions.filter(q => q.irt_params.b > 0.5);

  // Select distribution: 3 easy, 4 medium, 3 hard
  const selected: Question[] = [];

  // Shuffle and take
  const shuffleAndTake = (arr: Question[], n: number) => {
    const shuffled = [...arr].sort(() => Math.random() - 0.5);
    return shuffled.slice(0, Math.min(n, shuffled.length));
  };

  selected.push(...shuffleAndTake(easy, 3));
  selected.push(...shuffleAndTake(medium, 4));
  selected.push(...shuffleAndTake(hard, 3));

  // Final shuffle to randomize order
  return selected.sort(() => Math.random() - 0.5).slice(0, numQuestions);
}

/**
 * Grade quiz and estimate theta using Maximum Likelihood Estimation
 */
export function gradeQuiz(
  questions: Question[],
  answers: Map<string, number>
): {
  theta: number;
  scorePct: number;
  responseCorrectness: boolean[];
  band: string;
  suggestedDepth: string;
} {
  // Calculate correctness
  const responseCorrectness: boolean[] = [];
  let correctCount = 0;

  questions.forEach((q, idx) => {
    const userAnswer = answers.get(q.id);
    const isCorrect = userAnswer === q.correct_answer;

    // Detailed logging for first 3 questions
    if (idx < 3) {
      logger.info(`Grading Q${idx + 1}`, {
        qid: q.id,
        userAnswer,
        userAnswerType: typeof userAnswer,
        correctAnswer: q.correct_answer,
        correctAnswerType: typeof q.correct_answer,
        isCorrect,
        strictEquals: userAnswer === q.correct_answer,
        looseEquals: userAnswer == q.correct_answer,
      });
    }

    responseCorrectness.push(isCorrect);
    if (isCorrect) correctCount++;
  });

  const scorePct = Math.round((correctCount / questions.length) * 100);

  // Estimate theta using simple iterative MLE
  let theta = 0.0; // Start at average ability
  const maxIterations = 20;
  const tolerance = 0.01;

  for (let iter = 0; iter < maxIterations; iter++) {
    let numerator = 0;
    let denominator = 0;

    questions.forEach((q, idx) => {
      const { a, b, c } = q.irt_params;
      const prob = irtProbability(theta, q.irt_params);
      const correct = responseCorrectness[idx];

      // Derivative of log-likelihood
      const pStar = (prob - c) / (1 - c);
      const weight = a * pStar * (1 - pStar);

      if (correct) {
        numerator += weight * (1 - prob) / prob;
        denominator += weight;
      } else {
        numerator -= weight * prob / (1 - prob);
        denominator += weight;
      }
    });

    if (denominator === 0) break;

    const delta = numerator / denominator;
    theta += delta;

    if (Math.abs(delta) < tolerance) break;
  }

  // Clamp theta to reasonable range
  theta = Math.max(-3, Math.min(3, theta));

  // Determine band based on theta
  let band: string;
  if (theta > 1.5) {
    band = "senior";
  } else if (theta > 0.5) {
    band = "mid-level";
  } else if (theta > -0.5) {
    band = "junior";
  } else {
    band = "beginner";
  }

  // Suggested depth
  const suggestedDepth = theta > 1.0 ? "deep" : theta > -0.5 ? "medium" : "intro";

  return {
    theta,
    scorePct,
    responseCorrectness,
    band,
    suggestedDepth,
  };
}

/**
 * Generate quiz session ID
 */
export function generateQuizId(): string {
  return `quiz_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
}

/**
 * Select module gate questions (7 questions from specific module)
 * Used for end-of-module quizzes
 */
export function selectModuleQuestions(
  bank: QuestionBank,
  moduleId: string,
  numQuestions = 7
): Question[] {
  // Filter questions by module
  const moduleQuestions = bank.questions.filter(q => q.module === moduleId);

  if (moduleQuestions.length === 0) {
    throw new Error(`No questions found for module: ${moduleId}`);
  }

  // Stratify by difficulty
  const easy = moduleQuestions.filter(q => q.difficulty === "easy");
  const medium = moduleQuestions.filter(q => q.difficulty === "medium");
  const hard = moduleQuestions.filter(q => q.difficulty === "hard");

  // Select distribution: 2 easy, 3 medium, 2 hard (for 7 questions)
  const selected: Question[] = [];

  const shuffleAndTake = (arr: Question[], n: number) => {
    const shuffled = [...arr].sort(() => Math.random() - 0.5);
    return shuffled.slice(0, Math.min(n, shuffled.length));
  };

  selected.push(...shuffleAndTake(easy, 2));
  selected.push(...shuffleAndTake(medium, 3));
  selected.push(...shuffleAndTake(hard, 2));

  // Final shuffle to randomize order
  return selected.sort(() => Math.random() - 0.5).slice(0, Math.min(numQuestions, selected.length));
}

/**
 * Grade module quiz (simple score-based, not IRT)
 * Requires ≥70% to pass
 */
export function gradeModuleQuiz(
  questions: Question[],
  answers: Map<string, number>
): {
  score: number;
  scorePct: number;
  passed: boolean;
  responseCorrectness: boolean[];
  incorrectQuestions: string[];
} {
  const responseCorrectness: boolean[] = [];
  const incorrectQuestions: string[] = [];
  let correctCount = 0;

  questions.forEach((q) => {
    const userAnswer = answers.get(q.id);
    const isCorrect = userAnswer === q.correct_answer;
    responseCorrectness.push(isCorrect);

    if (isCorrect) {
      correctCount++;
    } else {
      incorrectQuestions.push(q.id);
    }
  });

  const scorePct = Math.round((correctCount / questions.length) * 100);
  const passed = scorePct >= 70;

  return {
    score: correctCount,
    scorePct,
    passed,
    responseCorrectness,
    incorrectQuestions,
  };
}
