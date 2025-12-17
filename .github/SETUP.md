# GitHub Repository Setup Guide

This guide helps you set up the Edaptia repository on GitHub with all necessary secrets and configurations.

## 1. Create GitHub Repository

1. Go to https://github.com/Edaptia/Edaptia
2. Ensure the repository is **Private**
3. Clone if needed:
```bash
git clone https://github.com/Edaptia/Edaptia.git
```

## 2. Configure GitHub Secrets

Go to: **Settings → Secrets and variables → Actions → New repository secret**

### Required Secrets

#### `FIREBASE_TOKEN`
This token allows GitHub Actions to deploy to Firebase.

**Generate the token:**
```bash
firebase login:ci
```

This will:
1. Open a browser for Firebase login
2. Generate a token after successful authentication
3. Display the token in terminal

**Copy the entire token** and add it as a GitHub secret named `FIREBASE_TOKEN`.

#### `OPENAI_API_KEY` (Optional - for local dev)
If you want to run tests that use OpenAI locally, add this secret.
Get it from: https://platform.openai.com/api-keys

## 3. Configure Branch Protection (Optional but Recommended)

Go to: **Settings → Branches → Add rule**

**Branch name pattern:** `main`

Enable:
- ✅ Require a pull request before merging
- ✅ Require status checks to pass before merging
  - Add required checks: `flutter`, `functions`
- ✅ Do not allow bypassing the above settings

## 4. Push Code to GitHub

```bash
# Ensure you're on main branch
git checkout main

# Add all files
git add .

# Commit
git commit -m "feat: initial commit with landing page and CI/CD"

# Push to GitHub
git push -u origin main
```

## 5. Verify CI/CD Pipeline

After pushing:
1. Go to **Actions** tab in GitHub
2. You should see the CI workflow running
3. All checks (flutter, functions) should pass ✅
4. On merge to `main`, deploy job will run automatically

## 6. Monitor Deployments

### View GitHub Actions Logs
- Go to **Actions** tab
- Click on any workflow run
- Expand each job to see detailed logs

### View Firebase Deploy Status
```bash
firebase deploy:status
```

Or check Firebase Console:
- https://console.firebase.google.com/project/aelion-c90d2

## 7. Local Development Setup

After cloning the repo, set up your local environment:

### Flutter
```bash
flutter pub get
flutter run
```

### Functions
```bash
cd functions
npm install

# Create .env file with:
# OPENAI_API_KEY=your_key_here

npm run build
npm test
```

### Firebase Emulators (Optional)
```bash
firebase emulators:start
```

## 8. Troubleshooting

### CI Failing on `flutter build appbundle`

If you get signing errors, the CI will still pass the analyze & test steps. The build step is informational only in CI.

For local release builds:
```bash
flutter build appbundle --release
```

You'll need to configure signing in `android/app/build.gradle` and provide a keystore.

### Deploy Job Not Running

Ensure:
- You pushed to `main` branch (not a PR)
- `FIREBASE_TOKEN` secret is configured
- The flutter and functions jobs passed

### Functions Build Failing

Ensure `functions/.env` exists locally with:
```
OPENAI_API_KEY=sk-...
```

In production, this is configured as a Firebase secret:
```bash
firebase functions:secrets:set OPENAI_API_KEY
```

## 9. Security Checklist

Before going public, verify:

- [ ] `FIREBASE_TOKEN` is set as GitHub secret (not in code)
- [ ] `.env` files are in `.gitignore`
- [ ] `android/app/google-services.json` is in `.gitignore`
- [ ] No API keys or credentials in code
- [ ] `.firebaserc` is in `.gitignore` (contains project ID)
- [ ] Firebase security rules are deployed and tested

## 10. Next Steps

- [ ] Set up branch protection rules
- [ ] Configure dependabot for security updates
- [ ] Set up code owners (optional)
- [ ] Create issue templates
- [ ] Set up PR template
- [ ] Configure GitHub Pages for docs (optional)

---

## Quick Commands Reference

```bash
# Deploy manually
firebase deploy

# Deploy only functions
firebase deploy --only functions

# Deploy only hosting
firebase deploy --only hosting

# View logs
firebase functions:log

# Check deploy status
firebase deploy:status

# Run CI locally (requires Docker)
act -j flutter
act -j functions
```

## Support

For questions or issues:
- **Email**: privacy@edaptia.io
- **GitHub Issues**: https://github.com/Edaptia/Edaptia/issues
