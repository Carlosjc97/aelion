#!/usr/bin/env node
/**
 * Secret Manager Integration Script
 * Loads secrets from Google Cloud Secret Manager for production deployments
 *
 * Usage:
 *   node scripts/secrets-manager.js load    - Load all secrets to .env
 *   node scripts/secrets-manager.js verify  - Verify secrets exist in Secret Manager
 *   node scripts/secrets-manager.js rotate  - Display rotation instructions
 */

import { SecretManagerServiceClient } from '@google-cloud/secret-manager';
import { writeFileSync } from 'node:fs';
import { join } from 'node:path';

const client = new SecretManagerServiceClient();
const PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT || 'edaptia';

// Secrets configuration
const SECRETS = [
  { name: 'OPENAI_API_KEY', required: true },
  { name: 'ASSESSMENT_HMAC_KEYS', required: true },
  { name: 'FIREBASE_SERVICE_ACCOUNT', required: false }, // Optional for local dev
];

/**
 * Retrieves a secret value from Secret Manager
 * @param {string} secretName - Name of the secret
 * @returns {Promise<string>} Secret value
 */
async function getSecret(secretName) {
  try {
    const name = `projects/${PROJECT_ID}/secrets/${secretName}/versions/latest`;
    const [version] = await client.accessSecretVersion({ name });
    const payload = version.payload?.data?.toString('utf8');

    if (!payload) {
      throw new Error(`Secret ${secretName} is empty`);
    }

    return payload;
  } catch (error) {
    console.error(`Error accessing secret ${secretName}:`, error.message);
    throw error;
  }
}

/**
 * Loads all secrets from Secret Manager to .env file
 */
async function loadSecrets() {
  console.log('Loading secrets from Secret Manager...');

  const envVars = [];

  for (const secret of SECRETS) {
    try {
      const value = await getSecret(secret.name);
      envVars.push(`${secret.name}=${value}`);
      console.log(`✓ Loaded ${secret.name}`);
    } catch (error) {
      if (secret.required) {
        console.error(`✗ Failed to load required secret ${secret.name}`);
        process.exit(1);
      } else {
        console.warn(`⚠ Skipped optional secret ${secret.name}`);
      }
    }
  }

  const envPath = join(process.cwd(), '.env');
  writeFileSync(envPath, envVars.join('\n') + '\n');
  console.log(`\n✓ Secrets written to ${envPath}`);
}

/**
 * Verifies all required secrets exist in Secret Manager
 */
async function verifySecrets() {
  console.log('Verifying secrets in Secret Manager...\n');

  let allValid = true;

  for (const secret of SECRETS) {
    try {
      await getSecret(secret.name);
      console.log(`✓ ${secret.name} exists`);
    } catch (error) {
      if (secret.required) {
        console.error(`✗ Required secret ${secret.name} NOT FOUND`);
        allValid = false;
      } else {
        console.warn(`⚠ Optional secret ${secret.name} not found`);
      }
    }
  }

  if (!allValid) {
    console.error('\n❌ Some required secrets are missing');
    process.exit(1);
  }

  console.log('\n✓ All required secrets are configured');
}

/**
 * Displays instructions for rotating secrets
 */
function displayRotationInstructions() {
  console.log(`
🔄 SECRET ROTATION GUIDE

Follow these steps to rotate secrets safely:

1. OPENAI_API_KEY:
   - Generate new key in OpenAI dashboard
   - Test new key in staging environment
   - Update Secret Manager:
     gcloud secrets versions add OPENAI_API_KEY --data-file=-
   - Deploy to production
   - Revoke old key after 24h monitoring period

2. ASSESSMENT_HMAC_KEYS:
   - Generate new key: node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
   - Append to existing keys (comma-separated for rotation period)
   - Update Secret Manager:
     gcloud secrets versions add ASSESSMENT_HMAC_KEYS --data-file=-
   - Deploy to production
   - Monitor for 7 days
   - Remove old key from list

3. FIREBASE_SERVICE_ACCOUNT:
   - Create new service account in Firebase Console
   - Download JSON key
   - Update Secret Manager:
     gcloud secrets versions add FIREBASE_SERVICE_ACCOUNT --data-file=service-account.json
   - Deploy to production
   - Disable old service account after 24h

IMPORTANT:
- Always test in staging first
- Keep old keys active during rotation period
- Monitor logs for authentication errors
- Document rotation dates in docs/RUNBOOK.md
  `);
}

// CLI Handler
const command = process.argv[2];

switch (command) {
  case 'load':
    await loadSecrets();
    break;
  case 'verify':
    await verifySecrets();
    break;
  case 'rotate':
    displayRotationInstructions();
    break;
  default:
    console.log(`
Usage: node scripts/secrets-manager.js [command]

Commands:
  load    - Load all secrets from Secret Manager to .env
  verify  - Verify all required secrets exist
  rotate  - Display secret rotation instructions
    `);
    process.exit(1);
}
