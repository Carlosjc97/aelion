import crypto from 'node:crypto';

const TOLERANCE_MS = 120 * 1000;
const RATE_WINDOW_MS = 60 * 1000;
const RATE_LIMIT = 45;

const keyCache = {
  parsed: null,
  raw: null,
};

const rateBuckets = new Map();
const MIN_KEY_BYTES = 32;

function resolveRawHmacKeys() {
  const configured = process.env.ASSESSMENT_HMAC_KEYS;
  if (configured && configured.trim().length > 0) {
    return configured;
  }
  throw new Error(
    'ASSESSMENT_HMAC_KEYS must be set to at least one non-empty key'
  );
}

function getHmacKeys() {
  const raw = resolveRawHmacKeys();
  if (keyCache.raw === raw && Array.isArray(keyCache.parsed)) {
    return keyCache.parsed;
  }

  const keys = raw
    .split(',')
    .map((entry) => entry.trim())
    .filter(Boolean);

  if (!keys.length) {
    throw new Error(
      'ASSESSMENT_HMAC_KEYS must provide at least one non-empty key',
    );
  }

  for (const key of keys) {
    if (Buffer.byteLength(key, 'utf8') < MIN_KEY_BYTES) {
      throw new Error(
        `ASSESSMENT_HMAC_KEYS entries must be at least ${MIN_KEY_BYTES} bytes`,
      );
    }
  }

  keyCache.raw = raw;
  keyCache.parsed = keys;
  return keys;
}

function getPrimaryKey() {
  return getHmacKeys()[0];
}

function signValue(value, key = getPrimaryKey()) {
  return crypto.createHmac('sha256', key).update(String(value)).digest('hex');
}

function verifySignature(value, signature) {
  if (!signature || typeof signature !== 'string') {
    return false;
  }

  const keys = getHmacKeys();
  return keys.some((key) => {
    const expected = signValue(value, key);
    try {
      const expectedBuffer = Buffer.from(expected, 'hex');
      const providedBuffer = Buffer.from(signature, 'hex');
      if (expectedBuffer.length !== providedBuffer.length) {
        return false;
      }
      return crypto.timingSafeEqual(expectedBuffer, providedBuffer);
    } catch {
      return false;
    }
  });
}

function issueServerTimestamp() {
  const timestamp = Math.floor(Date.now() / 1000);
  const signature = signValue(timestamp);
  return {
    timestamp,
    signature,
    toleranceSeconds: Math.floor(TOLERANCE_MS / 1000),
  };
}

function requireSignedTimestamp(req, res, next) {
  const tsHeader = req.get('x-server-timestamp');
  const sigHeader = req.get('x-server-signature');

  if (!tsHeader || !sigHeader) {
    return res.status(401).json({ error: 'timestamp_required' });
  }

  const timestamp = Number(tsHeader);
  if (!Number.isFinite(timestamp) || timestamp <= 0) {
    return res.status(401).json({ error: 'invalid_timestamp' });
  }

  if (!verifySignature(timestamp, sigHeader)) {
    return res.status(401).json({ error: 'invalid_signature' });
  }

  const drift = Math.abs(Date.now() - timestamp * 1000);
  if (drift > TOLERANCE_MS) {
    return res.status(401).json({ error: 'timestamp_out_of_range' });
  }

  req.requestTimestamp = timestamp;
  return next();
}

function attachResponseTimestamp(req, res, next) {
  const payload = issueServerTimestamp();
  res.set('X-Server-Timestamp', String(payload.timestamp));
  res.set('X-Server-Signature', payload.signature);
  res.locals.serverTimestamp = payload;
  next();
}

function resetKeyCacheForTests() {
  keyCache.raw = null;
  keyCache.parsed = null;
}

function hashIp(req) {
  const forwarded = req.headers['x-forwarded-for'];
  const original =
    typeof forwarded === 'string' && forwarded.trim()
      ? forwarded.split(',')[0].trim()
      : req.ip || req.connection?.remoteAddress || 'unknown';

  return signValue(original, getPrimaryKey());
}

function pruneBucket(events, now) {
  const threshold = now - RATE_WINDOW_MS;
  while (events.length && events[0] < threshold) {
    events.shift();
  }
}

function recordRateHit(key, now) {
  if (!key) {
    return { allowed: true, count: 0 };
  }

  const bucket = rateBuckets.get(key) ?? [];
  pruneBucket(bucket, now);

  if (bucket.length >= RATE_LIMIT) {
    return { allowed: false, count: bucket.length };
  }

  bucket.push(now);
  rateBuckets.set(key, bucket);
  return { allowed: true, count: bucket.length };
}

function enforceRateLimits(req, context = {}) {
  const now = Date.now();

  const identities = [
    { type: 'ip', value: hashIp(req) },
    { type: 'session', value: context.sessionId || context.session?.sessionId },
    {
      type: 'user',
      value: context.userId || context.session?.userId || null,
    },
  ];

  for (const identity of identities) {
    if (!identity.value) {
      continue;
    }
    const key = `${identity.type}:${identity.value}`;
    const result = recordRateHit(key, now);
    if (!result.allowed) {
      const error = new Error(`rate_limit_${identity.type}`);
      error.status = 429;
      error.code = `rate_limit_${identity.type}`;
      throw error;
    }
  }
}

export {
  TOLERANCE_MS,
  issueServerTimestamp,
  requireSignedTimestamp,
  attachResponseTimestamp,
  enforceRateLimits,
  signValue,
  verifySignature,
  resetKeyCacheForTests,
};
