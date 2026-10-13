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

# The existing patrol-character-generator Hosting site is already provisioned;
# current manual deployments need no change. For a new project provisioned by
# an automated pipeline after October 15, 2026, create its site before first deploy:
firebase hosting:sites:create <site-id> --project=<project-id>
# The project ID is usually a suitable site ID; use a unique ID if already reserved.

# 3. Build your Flutter app
flutter build web --release --pwa-strategy=none

# 4. Deploy to Firebase
firebase deploy --only hosting

# Your app will be live at: https://your-project-id.web.app
