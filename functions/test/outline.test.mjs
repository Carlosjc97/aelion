import test from 'node:test';
import assert from 'node:assert/strict';

import { slugifyTopic, __test } from '../lib/index.js';

test('slugifyTopic removes diacritics and normalises delimiters', () => {
  assert.equal(slugifyTopic('   Análisis SQL Avanzado!!!  '), 'analisis-sql-avanzado');
  assert.equal(slugifyTopic('Marketing & Growth 101'), 'marketing-growth-101');
});

test('summarizeOutlineResponse reports module and lesson counts', () => {
  const outlineResponse = {
    topic: 'SQL',
    goal: 'Master SQL',
    language: 'en',
    depth: 'medium',
    band: 'intermediate',
    outline: [
      {
        moduleId: 'fundamentals',
        title: 'Fundamentals',
        summary: 'Basics',
        lessons: [
          {
            id: 'l1',
            title: 'Intro',
            summary: 'Overview',
            type: 'lesson',
            durationMinutes: 20,
            content: 'Intro content',
          },
        ],
        locked: false,
        progress: { completed: 0, total: 1 },
      },
      {
        moduleId: 'practice',
        title: 'Practice',
        summary: 'Hands on',
        lessons: [
          {
            id: 'l2',
            title: 'Queries',
            summary: 'Practice queries',
            type: 'lesson',
            durationMinutes: 25,
            content: 'Practice content',
          },
          {
            id: 'l3',
            title: 'Joins',
            summary: 'Practice joins',
            type: 'lesson',
            durationMinutes: 30,
            content: 'Joins content',
          },
        ],
        locked: true,
        progress: { completed: 0, total: 2 },
      },
    ],
    source: 'curated',
    estimated_hours: 8,
    cacheExpiresAt: Date.now() + 3600 * 1000,
    meta: {},
  };

  const summary = __test.summarizeOutlineResponse(outlineResponse);
  assert.equal(summary.modules, 2);
  assert.equal(summary.lessons, 3);
  assert.equal(summary.source, 'curated');
  assert.equal(summary.estimatedHours, 8);
});

test('createCounters starts at zero for all fields', () => {
  const counters = __test.createCounters();
  assert.deepEqual(counters, {
    firestoreReads: 0,
    firestoreWrites: 0,
    storageMetadataChecks: 0,
    storageDownloads: 0,
    storageReadBytes: 0,
  });
});
