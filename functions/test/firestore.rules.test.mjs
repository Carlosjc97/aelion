import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rulesPath = join(__dirname, '../../firestore.rules');
const RULES_SOURCE = readFileSync(rulesPath, 'utf8');

function extractBlock(pattern) {
  const match = RULES_SOURCE.match(pattern);
  return match ? match[0] : '';
}

test('firestore rules expose adaptiveState as read-only for owners', () => {
  assert.ok(
    RULES_SOURCE.includes("match /adaptiveState/{docId}"),
    'adaptiveState block missing',
  );
  const block = extractBlock(/match \/adaptiveState\/\{docId\} {[\s\S]*?}/);
  assert.ok(block.includes("docId == 'summary'"), 'adaptiveState read guard missing docId filter');
  assert.ok(block.includes('allow write: if false;'), 'adaptiveState write guard missing');
});

test('firestore rules lock adaptiveCheckpoints collection', () => {
  assert.ok(
    RULES_SOURCE.includes("match /adaptiveCheckpoints/{docId}"),
    'adaptiveCheckpoints block missing',
  );
  const block = extractBlock(/match \/adaptiveCheckpoints\/\{docId\} {[\s\S]*?}/);
  assert.ok(block.includes('allow read: if false;'), 'adaptiveCheckpoints read guard missing');
  assert.ok(block.includes('allow write: if false;'), 'adaptiveCheckpoints write guard missing');
});
