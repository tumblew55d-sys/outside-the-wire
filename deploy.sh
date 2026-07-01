#!/bin/bash

# Patrol Character Generator - Quick Deployment Script
# This script helps deploy your app to different platforms

echo "🎯 Patrol Character Generator - Deployment Script"
echo "=================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Flutter installation
if ! command_exists flutter; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter found: $(flutter --version | head -n 1)${NC}"
echo ""

# Menu
echo "Select deployment target:"
echo "1) 🌐 Web (Firebase Hosting)"
echo "2) 🤖 Android (APK - for testing)"
echo "3) 🤖 Android (App Bundle - for Play Store)"
echo "4) 🍎 iOS (requires Mac)"
echo "5) 🪟 Windows Desktop"
echo "6) 🧪 Run all tests"
echo ""
read -p "Enter choice [1-6]: " choice

case $choice in
    1)
        echo -e "${YELLOW}📱 Building Web Version...${NC}"
        flutter clean
        flutter pub get
        flutter build web --release
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Web build successful!${NC}"
            echo ""
            echo "Next steps:"
            echo "1) Install Firebase CLI: npm install -g firebase-tools"
            echo "2) Login: firebase login"
            echo "3) Deploy: firebase deploy --only hosting"
            echo ""
            echo "Build location: build/web/"
        else
            echo -e "${RED}❌ Web build failed${NC}"
            exit 1
        fi
        ;;
    
    2)
        echo -e "${YELLOW}🤖 Building Android APK (Debug mode for testing)...${NC}"
        flutter clean
        flutter pub get
        flutter build apk --split-per-abi
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Android APK build successful!${NC}"
            echo ""
            echo "APK locations:"
            echo "  ARM 64-bit: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
            echo "  ARM 32-bit: build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk"
            echo "  x86 64-bit: build/app/outputs/flutter-apk/app-x86_64-release.apk"
            echo ""
            echo "⚠️  These APKs are signed with debug keys. For Play Store, use option 3."
        else
            echo -e "${RED}❌ Android build failed${NC}"
            exit 1
        fi
        ;;
    
    3)
        echo -e "${YELLOW}🤖 Building Android App Bundle (for Play Store)...${NC}"
        
        # Check if signing is configured
        if [ ! -f "android/key.properties" ]; then
            echo -e "${RED}❌ Signing not configured!${NC}"
            echo ""
            echo "Please create signing key first:"
            echo "1) Run: keytool -genkey -v -keystore patrol-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias patrol"
            echo "2) Create android/key.properties with your credentials"
            echo ""
            echo "See DEPLOYMENT_GUIDE.md for detailed instructions."
            exit 1
        fi
        
        flutter clean
        flutter pub get
        flutter build appbundle --release
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ App Bundle build successful!${NC}"
            echo ""
            echo "App Bundle location: build/app/outputs/bundle/release/app-release.aab"
            echo ""
            echo "Next steps:"
            echo "1) Go to Google Play Console: https://play.google.com/console"
            echo "2) Create new app or select existing"
            echo "3) Upload app-release.aab to Production or Internal Testing"
        else
            echo -e "${RED}❌ App Bundle build failed${NC}"
            exit 1
        fi
        ;;
    
    4)
        if [[ "$OSTYPE" != "darwin"* ]]; then
            echo -e "${RED}❌ iOS builds require macOS${NC}"
            exit 1
        fi
        
        echo -e "${YELLOW}🍎 Building iOS App...${NC}"
        flutter clean
        flutter pub get
        flutter build ios --release
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ iOS build successful!${NC}"
            echo ""
            echo "Next steps:"
            echo "1) Open ios/Runner.xcworkspace in Xcode"
            echo "2) Select Product > Archive"
            echo "3) Upload to App Store Connect"
        else
            echo -e "${RED}❌ iOS build failed${NC}"
            exit 1
        fi
        ;;
    
    5)
        echo -e "${YELLOW}🪟 Building Windows Desktop...${NC}"
        flutter clean
        flutter pub get
        flutter build windows --release
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Windows build successful!${NC}"
            echo ""
            echo "Executable location: build/windows/x64/runner/Release/"
            echo "You can distribute the entire Release folder as a portable app"
        else
            echo -e "${RED}❌ Windows build failed${NC}"
            exit 1
        fi
        ;;
    
    6)
        echo -e "${YELLOW}🧪 Running tests...${NC}"
        flutter test
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ All tests passed!${NC}"
        else
            echo -e "${RED}❌ Some tests failed${NC}"
            exit 1
        fi
        ;;
    
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✨ Done!${NC}"
