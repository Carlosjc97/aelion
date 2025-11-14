import { getApps, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

// Initialize Firebase Admin SDK if not already initialized
if (!getApps().length) {
  initializeApp();
}

const auth = getAuth();

/**
 * Extracts Bearer token from Authorization header
 * @param {import('express').Request} req - Express request object
 * @returns {string|null} The extracted token or null
 */
function extractBearerToken(req) {
  const authHeader = req.get('authorization') || req.get('Authorization');
  if (!authHeader || typeof authHeader !== 'string') {
    return null;
  }

  const match = authHeader.match(/^Bearer\s+(.+)$/i);
  return match ? match[1].trim() : null;
}

/**
 * Middleware that verifies Firebase ID token and attaches user info to request
 * @param {import('express').Request} req - Express request object
 * @param {import('express').Response} res - Express response object
 * @param {import('express').NextFunction} next - Express next function
 */
async function requireFirebaseAuth(req, res, next) {
  const token = extractBearerToken(req);

  if (!token) {
    return res.status(401).json({
      error: 'unauthorized',
      message: 'Firebase ID token required in Authorization header'
    });
  }

  try {
    const decodedToken = await auth.verifyIdToken(token);

    // Attach user info to request for downstream use
    req.firebaseUser = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      emailVerified: decodedToken.email_verified,
    };

    return next();
  } catch (error) {
    console.error('[requireFirebaseAuth] Token verification failed:', error.message);

    // Determine specific error type
    if (error.code === 'auth/id-token-expired') {
      return res.status(401).json({
        error: 'token_expired',
        message: 'Firebase ID token has expired'
      });
    }

    if (error.code === 'auth/argument-error') {
      return res.status(401).json({
        error: 'invalid_token',
        message: 'Malformed Firebase ID token'
      });
    }

    return res.status(401).json({
      error: 'unauthorized',
      message: 'Invalid Firebase ID token'
    });
  }
}

export { requireFirebaseAuth, extractBearerToken };
