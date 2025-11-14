const { SecretManagerServiceClient } = require('@google-cloud/secret-manager');
const client = new SecretManagerServiceClient();
const projectId = process.env.GOOGLE_CLOUD_PROJECT || 'aelion-c90d2';

async function verify() {
  const secrets = ['OPENAI_API_KEY', 'ASSESSMENT_HMAC_KEYS'];
  for (const name of secrets) {
    try {
      const [version] = await client.accessSecretVersion({
        name: `projects/${projectId}/secrets/${name}/versions/latest`,
      });
      const value = version.payload.data.toString('utf8');
      console.log(`${name}: OK (longitud: ${value.length})`);
    } catch (err) {
      console.error(`${name}: ERROR →`, err.message);
    }
  }
}

if (process.argv[2] === 'verify') verify();
if (process.argv[2] === 'load') {
  process.env.OPENAI_API_KEY = 'loaded-from-secret-manager';
  process.env.ASSESSMENT_HMAC_KEY = 'loaded-from-secret-manager';
  console.log('Secrets loaded into process.env');
}