# Firebase Hosting Deployment Guide

## Prerequisites
# Install Firebase CLI: npm install -g firebase-tools

## Steps:

# 1. Login to Firebase
firebase login

# 2. Initialize Firebase in your project
firebase init hosting

# When prompted:
# - Select "Use an existing project" or create new
# - Set public directory to: build/web
# - Configure as single-page app: Yes
# - Set up automatic builds: No

# 3. Build your Flutter app
flutter build web --release

# 4. Deploy to Firebase
firebase deploy --only hosting

# Your app will be live at: https://your-project-id.web.app
