1 Patrol Character Generator - PowerShell Deployment Script
# Run this on Windows to build and deploy your app

Write-Host "🎯 Patrol Character Generator - Deployment Script" -ForegroundColor Cyan
Write-Host "==================================================`n" -ForegroundColor Cyan

# Check Flutter installation
$flutterCheck = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCheck) {
    Write-Host "❌ Flutter is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

$flutterVersion = flutter --version 2>&1 | Select-Object -First 1
Write-Host "✅ Flutter found: $flutterVersion`n" -ForegroundColor Green

# Menu
Write-Host "Select deployment target:"
Write-Host "1) 🌐 Webfirebase login (Firebase Hosting)"
Write-Host "2) 🤖 Android (APK - for testing)"
Write-Host "3) 🤖 Android (App Bundle - for Play Store)"
Write-Host "4) 🪟 Windows Desktop"
Write-Host "5) 🧪 Run all tests"
Write-Host "6) 🧹 Clean build artifacts"
Write-Host ""

$choice = Read-Host "Enter choice [1-6]"

switch ($choice) {
    "1" {
        Write-Host "`n📱 Building Web Version..." -ForegroundColor Yellow
        flutter clean
        flutter pub get
        flutter build web --release
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n✅ Web build successful!" -ForegroundColor Green
            Write-Host "`nNext steps:"
            Write-Host "1) Install Firebase CLI: npm install -g firebase-tools"
            Write-Host "2) Login: firebase login"
            Write-Host "3) Initialize: firebase init hosting"
            Write-Host "4) Deploy: firebase deploy --only hosting"
            Write-Host "`nBuild location: build\web\"
            
            # Ask if user wants to test locally
            $test = Read-Host "`nTest locally? (y/n)"
            if ($test -eq "y") {
                Write-Host "`nStarting local server on http://localhost:8080..."
                Set-Location build\web
                python -m http.server 8080
            }
        } else {
            Write-Host "❌ Web build failed" -ForegroundColor Red
            exit 1
        }
    }
    
    "2" {
        Write-Host "`n🤖 Building Android APK..." -ForegroundColor Yellow
        flutter clean
        flutter pub get
        flutter build apk --split-per-abi
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n✅ Android APK build successful!" -ForegroundColor Green
            Write-Host "`nAPK locations:"
            Write-Host "  ARM 64-bit: build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
            Write-Host "  ARM 32-bit: build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk"
            Write-Host "  x86 64-bit: build\app\outputs\flutter-apk\app-x86_64-release.apk"
            Write-Host "`n⚠️  These APKs are signed with debug keys."
            Write-Host "For Play Store submission, use option 3 (App Bundle)."
            
            # Open folder
            $open = Read-Host "`nOpen APK folder? (y/n)"
            if ($open -eq "y") {
                explorer "build\app\outputs\flutter-apk"
            }
        } else {
            Write-Host "❌ Android build failed" -ForegroundColor Red
            exit 1
        }
    }
    
    "3" {
        Write-Host "`n🤖 Building Android App Bundle for Play Store..." -ForegroundColor Yellow
        
        # Check if signing is configured
        if (-not (Test-Path "android\key.properties")) {
            Write-Host "❌ Signing not configured!" -ForegroundColor Red
            Write-Host "`nTo create a release build, you need:"
            Write-Host "1) Generate signing key:"
            Write-Host '   keytool -genkey -v -keystore patrol-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias patrol'
            Write-Host "`n2) Create android\key.properties with:"
            Write-Host "   storePassword=YOUR_PASSWORD"
            Write-Host "   keyPassword=YOUR_PASSWORD"
            Write-Host "   keyAlias=patrol"
            Write-Host "   storeFile=../../patrol-release-key.jks"
            Write-Host "`nSee DEPLOYMENT_GUIDE.md for detailed instructions."
            exit 1
        }
        
        flutter clean
        flutter pub get
        flutter build appbundle --release
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n✅ App Bundle build successful!" -ForegroundColor Green
            Write-Host "`nApp Bundle: build\app\outputs\bundle\release\app-release.aab"
            Write-Host "`nNext steps:"
            Write-Host "1) Go to: https://play.google.com/console"
            Write-Host "2) Create or select your app"
            Write-Host "3) Go to Production or Testing"
            Write-Host "4) Create new release and upload app-release.aab"
            
            # Open folder
            $open = Read-Host "`nOpen bundle folder? (y/n)"
            if ($open -eq "y") {
                explorer "build\app\outputs\bundle\release"
            }
        } else {
            Write-Host "❌ App Bundle build failed" -ForegroundColor Red
            exit 1
        }
    }
    
    "4" {
        Write-Host "`n🪟 Building Windows Desktop..." -ForegroundColor Yellow
        flutter clean
        flutter pub get
        flutter build windows --release
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n✅ Windows build successful!" -ForegroundColor Green
            Write-Host "`nExecutable: build\windows\x64\runner\Release\flutter_application_4patrol.exe"
            Write-Host "`nYou can distribute the entire Release folder as a portable app."
            Write-Host "Users need Visual C++ Redistributable installed."
            
            # Ask to run
            $run = Read-Host "`nRun the app now? (y/n)"
            if ($run -eq "y") {
                Start-Process "build\windows\x64\runner\Release\flutter_application_4patrol.exe"
            }
            
            # Ask to open folder
            $open = Read-Host "`nOpen build folder? (y/n)"
            if ($open -eq "y") {
                explorer "build\windows\x64\runner\Release"
            }
        } else {
            Write-Host "❌ Windows build failed" -ForegroundColor Red
            exit 1
        }
    }
    
    "5" {
        Write-Host "`n🧪 Running tests..." -ForegroundColor Yellow
        flutter test
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n✅ All tests passed!" -ForegroundColor Green
        } else {
            Write-Host "❌ Some tests failed" -ForegroundColor Red
            exit 1
        }
    }
    
    "6" {
        Write-Host "`n🧹 Cleaning build artifacts..." -ForegroundColor Yellow
        flutter clean
        
        if (Test-Path "build") {
            Remove-Item -Recurse -Force "build"
        }
        
        Write-Host "✅ Clean complete!" -ForegroundColor Green
    }
    
    default {
        Write-Host "Invalid choice" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n✨ Done!" -ForegroundColor Green
