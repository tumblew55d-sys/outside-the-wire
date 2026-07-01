# Patrol Character Generator - Deployment Guide
**Last Updated:** December 4, 2025

This guide covers deploying your app to Web, Android Play Store, and iOS App Store.

---

## 📋 Prerequisites

### Required Accounts
- [ ] Google Play Console Account ($25 one-time fee)
- [ ] Apple Developer Account ($99/year)
- [ ] Firebase Project (already set up)
- [ ] Web Hosting (Firebase Hosting, Netlify, Vercel, or custom domain)

### Required Tools
- [ ] Flutter SDK (installed ✅)
- [ ] Android Studio with SDK tools
- [ ] Xcode (Mac required for iOS builds)
- [ ] Git for version control

---

## 🌐 Part 1: Web Deployment

### Option A: Firebase Hosting (Recommended - Free)

#### Step 1: Install Firebase CLI
```powershell
npm install -g firebase-tools
firebase login
```

#### Step 2: Initialize Firebase Hosting
```powershell
cd "c:\Users\tumbl\Desktop\kazmo industry\Application\patrolcharctergen\patrolv4\flutter_application_4patrol"
firebase init hosting
```

Select:
- Use existing project: `patrol-character-generator`
- Public directory: `build/web`
- Single-page app: `Yes`
- Automatic builds with GitHub: `No` (for now)

#### Step 3: Build Web Version
```powershell
flutter build web --release
```

#### Step 4: Deploy to Firebase
```powershell
firebase deploy --only hosting
```

Your app will be live at: `https://patrol-character-generator.web.app`

#### Step 5: Custom Domain (Optional)
1. Go to Firebase Console → Hosting → Add custom domain
2. Follow DNS setup instructions (typically add A records)
3. Example: `patrol.kazmoindustry.com`

### Option B: GitHub Pages (Free)

#### Step 1: Create GitHub Repository
```powershell
cd "c:\Users\tumbl\Desktop\kazmo industry\Application\patrolcharctergen\patrolv4\flutter_application_4patrol"
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/patrol-character-gen.git
git push -u origin main
```

#### Step 2: Build for GitHub Pages
```powershell
flutter build web --release --base-href "/patrol-character-gen/"
```

#### Step 3: Deploy to gh-pages
```powershell
# Install GitHub Pages package
flutter pub add dev:flutter_gh_pages

# Deploy
flutter pub run flutter_gh_pages:deploy
```

Your app will be live at: `https://YOUR_USERNAME.github.io/patrol-character-gen/`

---

## 🤖 Part 2: Android Play Store Deployment

### Step 1: Update App Identity

**File: `android/app/build.gradle.kts`**

Change the application ID from `com.example.flutter_application_4patrol` to your unique identifier:
```kotlin
applicationId = "com.kazmoindustry.patrolchargen"
```

**File: `android/app/src/main/AndroidManifest.xml`**

Add proper app name and permissions.

### Step 2: Create App Icon

#### Option A: Use Android Studio
1. Open `android/` folder in Android Studio
2. Right-click `res` → New → Image Asset
3. Upload your 512x512 app icon
4. Generate all sizes

#### Option B: Use Online Tool
1. Go to https://icon.kitchen or https://romannurik.github.io/AndroidAssetStudio/
2. Upload icon and download asset pack
3. Replace files in `android/app/src/main/res/mipmap-*/`

### Step 3: Create Signing Key

```powershell
# Create keystore (run in PowerShell)
keytool -genkey -v -keystore patrol-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias patrol

# Answer prompts:
# Password: [create strong password]
# Name: Kazmo Industry
# Organization: Kazmo Industry
# City: [your city]
# State: [your state]
# Country Code: US
```

**IMPORTANT:** Save the password securely! You'll need it for all future updates.

### Step 4: Configure Signing

**Create file: `android/key.properties`**
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=patrol
storeFile=../../patrol-release-key.jks
```

**Add to `.gitignore`:**
```
android/key.properties
patrol-release-key.jks
```

**Update `android/app/build.gradle.kts`:**
Add before `android {` block:
```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Update `buildTypes` section:
```kotlin
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
    }
}

signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

### Step 5: Build Release APK/AAB

```powershell
# Build App Bundle (required for Play Store)
flutter build appbundle --release

# Or build APK (for direct distribution)
flutter build apk --release --split-per-abi
```

Output locations:
- **App Bundle:** `build/app/outputs/bundle/release/app-release.aab`
- **APKs:** `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`

### Step 6: Google Play Console Setup

1. **Go to:** https://play.google.com/console
2. **Create Account** ($25 one-time fee)
3. **Create New App:**
   - Name: "Patrol Character Generator"
   - Default language: English
   - App/Game: Game (or App)
   - Free/Paid: Free

4. **Complete Store Listing:**
   - Short description (80 chars): "Military character creation tool for tabletop RPGs"
   - Full description (4000 chars): [Write detailed description]
   - Screenshots: Minimum 2 (1024x500 or phone screenshots)
   - Feature graphic: 1024x500 banner image
   - App icon: 512x512 PNG
   - Category: Productivity or Entertainment
   - Content rating: Fill out questionnaire
   - Target audience: 13+ or 18+
   - Privacy policy: Required (create simple one)

5. **Upload App Bundle:**
   - Go to Production → Create new release
   - Upload `app-release.aab`
   - Add release notes
   - Review and rollout

6. **Review Process:**
   - Takes 1-7 days for first review
   - Check for rejection emails
   - Fix any issues and resubmit

---

## 🍎 Part 3: iOS App Store Deployment

### Prerequisites
- **Mac computer required** (or Mac virtual machine)
- Xcode 15+ installed
- Apple Developer Account ($99/year)

### Step 1: Update iOS Configuration

**File: `ios/Runner/Info.plist`**

Update bundle identifier:
```xml
<key>CFBundleIdentifier</key>
<string>com.kazmoindustry.patrolchargen</string>
```

Update display name:
```xml
<key>CFBundleDisplayName</key>
<string>Patrol Character Gen</string>
```

### Step 2: Open Xcode

```bash
cd ios
open Runner.xcworkspace
```

### Step 3: Configure Signing in Xcode

1. Select `Runner` in project navigator
2. Go to `Signing & Capabilities` tab
3. Check "Automatically manage signing"
4. Select your Apple Developer Team
5. Verify Bundle Identifier matches: `com.kazmoindustry.patrolchargen`

### Step 4: Create App Icon

1. Open `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
2. Create icons in required sizes (20x20 to 1024x1024)
3. Or use online tool: https://appicon.co/

### Step 5: Build iOS App

```bash
flutter build ios --release
```

### Step 6: App Store Connect Setup

1. **Go to:** https://appstoreconnect.apple.com
2. **Create New App:**
   - Platform: iOS
   - Name: "Patrol Character Generator"
   - Language: English
   - Bundle ID: Select your registered ID
   - SKU: `patrol-chargen-001`

3. **Complete App Information:**
   - Category: Productivity or Games
   - Content rights: You own or have rights
   - Age rating: Fill out questionnaire
   - Privacy policy URL: Required

4. **Add Screenshots:**
   - iPhone 6.7": 1290x2796 (required)
   - iPhone 6.5": 1242x2688 (required)
   - iPad Pro 12.9": 2048x2732 (optional)
   - Use simulator or real device

### Step 7: Upload Build with Xcode

1. In Xcode, select `Product` → `Archive`
2. When archive completes, click `Distribute App`
3. Select `App Store Connect`
4. Select `Upload`
5. Follow prompts to upload

### Step 8: Submit for Review

1. In App Store Connect, select your build
2. Add screenshots and descriptions
3. Set pricing (Free)
4. Submit for review
5. Review takes 1-3 days

---

## 📝 Part 4: Privacy Policy & Terms

### Create Privacy Policy

**Required for both Play Store and App Store**

Create file: `PRIVACY_POLICY.md`

```markdown
# Privacy Policy for Patrol Character Generator

Last updated: December 4, 2025

## Information We Collect

### User Account Information
- Email address (for authentication)
- User ID (automatically generated)

### Character Data
- Character names, attributes, and game statistics
- Portrait images (optional, user-uploaded)
- PDF exports

## How We Use Your Information

- Authentication and account management
- Character data storage and synchronization
- PDF generation and export

## Data Storage

- Local storage: Hive database on your device
- Cloud storage: Firebase (encrypted)
- Portrait images: Firebase Storage

## Data Sharing

We do not sell or share your personal information with third parties.

## Your Rights

- Access your data
- Delete your account and all associated data
- Export your character data

## Contact

For privacy concerns: [your-email@example.com]
```

Host this on:
- GitHub Pages: `https://username.github.io/patrol-privacy-policy`
- Firebase Hosting: `https://patrol-character-generator.web.app/privacy`
- Your website: `https://kazmoindustry.com/patrol-privacy`

### Create Terms of Service (Optional but Recommended)

Similar format, covering:
- Acceptable use
- User responsibilities
- Intellectual property
- Liability limitations

---

## 🔐 Part 5: Security Checklist

### Before Publishing:

- [ ] Remove all debug logging from production builds
- [ ] Verify Firebase security rules
- [ ] Test offline functionality
- [ ] Test on real devices (Android & iOS)
- [ ] Check for memory leaks
- [ ] Verify all API keys are secure
- [ ] Test character save/load/export
- [ ] Test PDF generation
- [ ] Test portrait upload
- [ ] Verify user data isolation (userId filtering)

### Firebase Security Rules

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /characters/{characterId} {
      allow read, write: if request.auth != null && 
                         request.resource.data.userId == request.auth.uid;
    }
  }
}
```

**Storage Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /portraits/{userId}/{characterId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /character_sheets/{characterId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 📊 Part 6: Analytics & Monitoring (Optional)

### Add Firebase Analytics

**pubspec.yaml:**
```yaml
dependencies:
  firebase_analytics: ^11.0.0
```

**main.dart:**
```dart
import 'package:firebase_analytics/firebase_analytics.dart';

FirebaseAnalytics analytics = FirebaseAnalytics.instance;

// Track events
await analytics.logEvent(
  name: 'character_created',
  parameters: {'specialty': 'SOF'},
);
```

---

## 🚀 Quick Command Reference

### Web Deployment
```powershell
flutter build web --release
firebase deploy --only hosting
```

### Android Build
```powershell
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS Build
```bash
flutter build ios --release
# Then upload via Xcode
```

### Test Builds
```powershell
# Android Debug
flutter run -d android

# iOS Simulator
flutter run -d ios

# Web Browser
flutter run -d chrome

# Windows Desktop
flutter run -d windows
```

---

## 📞 Support & Resources

### Official Documentation
- Flutter deployment: https://docs.flutter.dev/deployment
- Play Store: https://support.google.com/googleplay/android-developer
- App Store: https://developer.apple.com/app-store/review/guidelines/

### Common Issues

**Issue:** "Execution failed for task ':app:lintVitalRelease'"
**Fix:** Add to `android/app/build.gradle.kts`:
```kotlin
lintOptions {
    checkReleaseBuilds false
}
```

**Issue:** iOS build fails with "Provisioning profile error"
**Fix:** In Xcode, go to Signing & Capabilities and reselect team

**Issue:** Web app shows blank screen
**Fix:** Check browser console for errors, verify `index.html` base href

---

## ✅ Pre-Launch Checklist

### Android
- [ ] Unique applicationId set
- [ ] App signed with release key
- [ ] Version code incremented
- [ ] Screenshots added (minimum 2)
- [ ] Store listing complete
- [ ] Privacy policy URL added
- [ ] Content rating completed
- [ ] Target API level 34+ (Android 14)

### iOS
- [ ] Bundle ID registered in Apple Developer
- [ ] App signed with distribution certificate
- [ ] Version/build number set
- [ ] Screenshots for all required sizes
- [ ] App Store listing complete
- [ ] Privacy policy URL added
- [ ] Age rating set
- [ ] Export compliance completed

### Web
- [ ] Built with --release flag
- [ ] Firebase hosting configured
- [ ] Custom domain set (optional)
- [ ] HTTPS enabled
- [ ] SEO meta tags added

---

## 🎯 Next Steps

1. **Immediate:** Deploy web version (easiest, fastest)
2. **Short-term:** Prepare Android release (1-2 weeks)
3. **Long-term:** Prepare iOS release (requires Mac)

Would you like me to:
1. Set up Firebase Hosting configuration?
2. Update Android configuration files with proper app ID?
3. Create the Privacy Policy page?
4. Generate app icons in all required sizes?

Let me know which deployment target to prioritize!
