import test from 'node:test';
import assert from 'node:assert/strict';
import supertest from 'supertest';

async function loadFreshApp() {
  const module = await import(`./server.js?cacheBust=${Date.now()}-${Math.random()}`);
  return module.default;
}

test('allows requests from whitelisted origins', async (t) => {
  process.env.NODE_ENV = 'test';
  process.env.SERVER_ALLOWED_ORIGINS = 'http://allowed.test';
  process.env.ASSESSMENT_HMAC_KEYS =
    '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

  const app = await loadFreshApp();

  const response = await supertest(app)
    .get('/health')
    .set('Origin', 'http://allowed.test')
    .expect(200);

  assert.equal(response.body.ok, true);
  assert.equal(response.headers['access-control-allow-origin'], 'http://allowed.test');
});

test('rejects requests from non-whitelisted origins', async (t) => {
  process.env.NODE_ENV = 'test';
  process.env.SERVER_ALLOWED_ORIGINS = 'http://allowed.test';
  process.env.ASSESSMENT_HMAC_KEYS =
    '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

  const app = await loadFreshApp();

  const response = await supertest(app)
    .get('/health')
    .set('Origin', 'http://evil.test')
    .expect(403);

  assert.equal(response.body.error, 'forbidden_origin');
});
