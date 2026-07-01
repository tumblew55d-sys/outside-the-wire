# Quick Start - Deployment Commands

## 🚀 Quick Deploy

### Windows Users
```powershell
# Run the deployment script
.\deploy.ps1
```

### Mac/Linux Users
```bash
# Make script executable (first time only)
chmod +x deploy.sh

# Run the deployment script
./deploy.sh
```

---

## 📦 Manual Build Commands

### Web (Firebase Hosting)
```bash
flutter build web --release
firebase deploy --only hosting
```

### Android APK (Testing)
```bash
flutter build apk --split-per-abi
# Output: build/app/outputs/flutter-apk/
```

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (Mac only)
```bash
flutter build ios --release
# Then upload via Xcode
```

### Windows Desktop
```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/
```

---

## ⚡ Development Commands

### Run on device
```bash
flutter run -d <device>
```

### Available devices
```bash
flutter devices
```

### Hot reload (during development)
```bash
# Press 'r' in terminal while app is running
```

### Clean build
```bash
flutter clean
flutter pub get
```

### Run tests
```bash
flutter test
```

### Check for issues
```bash
flutter doctor
flutter analyze
```

---

## 🌐 Firebase Commands

### Login
```bash
firebase login
```

### Initialize project
```bash
firebase init hosting
```

### Deploy hosting
```bash
firebase deploy --only hosting
```

### Deploy with custom project
```bash
firebase deploy --only hosting --project patrol-character-generator
```

### View logs
```bash
firebase functions:log
```

---

## 🔑 Android Signing (First Time Setup)

### Generate keystore
```bash
keytool -genkey -v -keystore patrol-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias patrol
```

### Create key.properties
Create `android/key.properties`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=patrol
storeFile=../../patrol-release-key.jks
```

### Add to .gitignore
```
*.jks
*.keystore
android/key.properties
```

---

## 📱 Version Bump

### Update version in pubspec.yaml
```yaml
version: 1.0.1+2  # Major.Minor.Patch+BuildNumber
```

### Android version (auto from pubspec)
- versionName = 1.0.1
- versionCode = 2

### iOS version (auto from pubspec)
- CFBundleShortVersionString = 1.0.1
- CFBundleVersion = 2

---

## 🔍 Useful Checks

### Check app size
```bash
flutter build apk --analyze-size
flutter build appbundle --analyze-size
```

### Check dependencies
```bash
flutter pub outdated
flutter pub upgrade
```

### Performance profile
```bash
flutter run --profile
```

---

## 📝 Pre-Release Checklist

- [ ] Update version in pubspec.yaml
- [ ] Run `flutter clean`
- [ ] Run `flutter test`
- [ ] Build release version
- [ ] Test on real device
- [ ] Update CHANGELOG.md
- [ ] Update store screenshots
- [ ] Update store description
- [ ] Test offline mode
- [ ] Test Firebase sync
- [ ] Test PDF export
- [ ] Verify all features work

---

## 🆘 Troubleshooting

### "Signing not configured"
Create `android/key.properties` and generate keystore

### "Firebase not initialized"
Check `firebase_options.dart` exists and is configured

### "Build failed"
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### "Gradle error"
Delete `android/.gradle` folder and rebuild

### "iOS codesign error"
Open Xcode, verify Team and Bundle ID in Signing & Capabilities

---

For detailed instructions, see **DEPLOYMENT_GUIDE.md**
