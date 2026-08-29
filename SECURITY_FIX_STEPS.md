# Security Fix: Exposed Google API Key

## Status: URGENT - ACTION REQUIRED

### Step 1: Revoke the Exposed Key (DO THIS NOW)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: `patrol-character-generator`
3. Navigate to: **APIs & Services** → **Credentials**
4. Find the exposed API key: `AIzaSyBx3tBiL-XgM14DcHfNdM6azTTRU5MrqC0`
5. Click on it and select **DELETE** or **RESTRICT**

### Step 2: Generate New Firebase Configuration
Run these commands in your terminal:

```powershell
# Install FlutterFire CLI if not already installed
dart pub global activate flutterfire_cli

# Reconfigure Firebase (this will generate new keys)
flutterfire configure --project=patrol-character-generator
```

This will regenerate:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

### Step 3: Restrict Your New API Keys
After generating new keys, restrict them in Google Cloud Console:

1. Go to **APIs & Services** → **Credentials**
2. For each API key, click **Edit**
3. Add **Application restrictions**:
   - For Android: Add your app's package name and SHA-1 certificate fingerprint
   - For Web: Add authorized domains (e.g., `patrol-character-generator.firebaseapp.com`)
   - For iOS: Add your iOS bundle ID
4. Add **API restrictions**: Enable only the APIs you need:
   - Firebase Installations API
   - Firebase Cloud Messaging API
   - Identity Toolkit API (for Auth)
   - Cloud Firestore API

### Step 4: Update .gitignore (Optional but Recommended for Sensitive Config)
While Firebase API keys are designed to be public (security is handled by Firestore Rules), you may want to add extra protection:

```gitignore
# Firebase configuration files (if you want to keep them private)
# Note: You'll need to share these securely with your team
# google-services.json
# GoogleService-Info.plist
```

### Step 5: Clean Git History (Important!)
The exposed key is in your Git history. You have two options:

#### Option A: Remove from history (recommended if public repo)
```powershell
# Install git-filter-repo
pip install git-filter-repo

# Remove the sensitive files from history
git filter-repo --path lib/firebase_options.dart --invert-paths
git filter-repo --path android/app/google-services.json --invert-paths

# Force push (WARNING: This rewrites history)
git push --force --all
```

#### Option B: Accept the key is compromised (if you've revoked it)
If you've already revoked the old key, you can simply:
1. Commit the new firebase_options.dart with new keys
2. Close the GitHub security alert as "Revoked"

### Step 6: Close the GitHub Alert
1. Go to your repository's **Security** → **Secret scanning alerts**
2. Find the alert for the Google API Key
3. Click **Close alert** → **Revoked** (after you've revoked the old key)

## Important Notes:

### About Firebase API Keys:
- **Firebase API keys are NOT traditional secrets** - they identify your Firebase project
- **Security comes from Firebase Security Rules**, not from hiding the API key
- Firebase API keys are meant to be included in your client code
- However, you should ALWAYS restrict them in Google Cloud Console

### Best Practices Going Forward:
1. ✅ Always restrict API keys to specific platforms/domains
2. ✅ Use Firebase Security Rules to protect your data
3. ✅ Enable Firebase App Check for additional security
4. ✅ Monitor usage in Google Cloud Console
5. ✅ Never commit other secrets (service account keys, private keys, etc.)

### What Makes Firebase Different:
Unlike traditional API keys, Firebase API keys are safe to include in client apps because:
- They only identify which Firebase project to connect to
- They don't grant access to data (Security Rules do that)
- They're designed to be embedded in apps
- The real security layer is your Firestore Security Rules

## Files Affected:
- ✅ `lib/firebase_options.dart` - Contains API keys for all platforms
- ✅ `android/app/google-services.json` - Contains Android configuration
- ⚠️  Git history - Contains the exposed key

## Timeline:
- **Detected**: Jul 1, 2026
- **Status**: Open (needs immediate action)
- **Priority**: HIGH

## Resources:
- [Firebase API Key Security](https://firebase.google.com/docs/projects/api-keys)
- [Google Cloud API Key Best Practices](https://cloud.google.com/docs/authentication/api-keys)
- [FlutterFire CLI Documentation](https://firebase.flutter.dev/docs/cli/)
