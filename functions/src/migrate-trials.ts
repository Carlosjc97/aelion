import { getApps, initializeApp } from 'firebase-admin/app';
import { FieldValue, Timestamp, getFirestore } from 'firebase-admin/firestore';

if (!getApps().length) {
  initializeApp();
}

const firestore = getFirestore();

export async function migrateExistingTrialUsers(): Promise<void> {
  const snapshot = await firestore
    .collection('users')
    .where('entitlements.trialEndsAt', '>', new Date())
    .get();

  for (const doc of snapshot.docs) {
    const data = doc.data() ?? {};
    const entitlements = data.entitlements ?? {};
    const trialEndsAt = entitlements.trialEndsAt ?? data.trialEndsAt;
    if (!trialEndsAt) {
      continue;
    }

    const trialTimestamp =
      trialEndsAt instanceof Timestamp
        ? trialEndsAt
        : Timestamp.fromDate(new Date(trialEndsAt));

    await doc.ref.update({
      'entitlements.isPremium': true,
      'entitlements.migrated': true,
      'entitlements.migratedAt': FieldValue.serverTimestamp(),
      'entitlements.subscriptionExpiresAt': trialTimestamp,
      'entitlements.migrationType': 'trial_to_premium_grace',
    });

    console.log(`Migrated user ${doc.id}`);
  }
}

if (require.main === module) {
  migrateExistingTrialUsers()
    .then(() => {
      console.log('Migration complete');
      process.exit(0);
    })
    .catch((error) => {
      console.error('Migration failed', error);
      process.exit(1);
    });
}
