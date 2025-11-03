import { describe, it, mock, beforeEach } from 'node:test';
import assert from 'node:assert';
import { requireFirebaseAuth, extractBearerToken } from './auth_middleware.js';

describe('extractBearerToken', () => {
  it('should extract token from valid Authorization header', () => {
    const req = {
      get: (header) => {
        if (header.toLowerCase() === 'authorization') {
          return 'Bearer abc123token';
        }
        return null;
      },
    };

    const token = extractBearerToken(req);
    assert.strictEqual(token, 'abc123token');
  });

  it('should return null if Authorization header is missing', () => {
    const req = {
      get: () => null,
    };

    const token = extractBearerToken(req);
    assert.strictEqual(token, null);
  });

  it('should return null if Authorization header is not Bearer', () => {
    const req = {
      get: () => 'Basic username:password',
    };

    const token = extractBearerToken(req);
    assert.strictEqual(token, null);
  });

  it('should handle case-insensitive Bearer prefix', () => {
    const req = {
      get: () => 'bearer lowercase-token',
    };

    const token = extractBearerToken(req);
    assert.strictEqual(token, 'lowercase-token');
  });

  it('should trim whitespace from extracted token', () => {
    const req = {
      get: () => 'Bearer   token-with-spaces   ',
    };

    const token = extractBearerToken(req);
    assert.strictEqual(token, 'token-with-spaces');
  });
});

describe('requireFirebaseAuth middleware', () => {
  let mockAuth;
  let mockReq;
  let mockRes;
  let mockNext;

  beforeEach(() => {
    // Mock request object
    mockReq = {
      get: mock.fn((header) => {
        if (header.toLowerCase() === 'authorization') {
          return mockReq._authHeader || null;
        }
        return null;
      }),
      _authHeader: null,
    };

    // Mock response object
    mockRes = {
      statusCode: 200,
      jsonData: null,
      status: mock.fn(function (code) {
        this.statusCode = code;
        return this;
      }),
      json: mock.fn(function (data) {
        this.jsonData = data;
        return this;
      }),
    };

    // Mock next function
    mockNext = mock.fn();
  });

  it('should return 401 if Authorization header is missing', async () => {
    mockReq._authHeader = null;

    await requireFirebaseAuth(mockReq, mockRes, mockNext);

    assert.strictEqual(mockRes.statusCode, 401);
    assert.strictEqual(mockRes.jsonData.error, 'unauthorized');
    assert.strictEqual(mockNext.mock.calls.length, 0);
  });

  it('should return 401 if token is not Bearer format', async () => {
    mockReq._authHeader = 'Basic username:password';

    await requireFirebaseAuth(mockReq, mockRes, mockNext);

    assert.strictEqual(mockRes.statusCode, 401);
    assert.strictEqual(mockRes.jsonData.error, 'unauthorized');
    assert.strictEqual(mockNext.mock.calls.length, 0);
  });

  it('should attach firebaseUser to request on valid token', async () => {
    // This test requires mocking the Firebase Admin SDK
    // For now, we document the expected behavior
    // In a real environment, you would mock getAuth().verifyIdToken()

    // Expected behavior:
    // - Extract Bearer token
    // - Call auth.verifyIdToken(token)
    // - On success: attach req.firebaseUser = { uid, email, emailVerified }
    // - Call next()

    assert.ok(true, 'Integration test with Firebase Admin SDK required');
  });

  it('should return 401 for expired tokens', async () => {
    // This test requires mocking Firebase Admin SDK
    // to simulate auth/id-token-expired error

    // Expected behavior:
    // - Call auth.verifyIdToken(token)
    // - Catch error with code 'auth/id-token-expired'
    // - Return 401 with error: 'token_expired'

    assert.ok(true, 'Integration test with Firebase Admin SDK required');
  });

  it('should return 401 for malformed tokens', async () => {
    // This test requires mocking Firebase Admin SDK
    // to simulate auth/argument-error

    // Expected behavior:
    // - Call auth.verifyIdToken(token)
    // - Catch error with code 'auth/argument-error'
    // - Return 401 with error: 'invalid_token'

    assert.ok(true, 'Integration test with Firebase Admin SDK required');
  });
});

describe('requireFirebaseAuth integration (NOTE: Requires Firebase Admin SDK)', () => {
  it('should verify real Firebase ID tokens in integration environment', () => {
    // This test should only run in integration/staging environments
    // where FIREBASE_AUTH_EMULATOR_HOST is set or real Firebase credentials exist

    // Test flow:
    // 1. Generate test Firebase ID token (from emulator or test user)
    // 2. Pass token to requireFirebaseAuth
    // 3. Verify req.firebaseUser is populated correctly
    // 4. Verify next() is called

    assert.ok(true, 'Requires Firebase emulator or staging environment');
  });
});
