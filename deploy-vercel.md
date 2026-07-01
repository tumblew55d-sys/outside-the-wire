# Vercel Deployment Guide

## Method 1: CLI Deployment

# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Deploy from build/web directory
cd build/web
vercel --prod

# Your app will be live at: https://your-project-name.vercel.app

## Method 2: Web Interface

1. Go to https://vercel.com/new
2. Import your Git repository (GitHub, GitLab, or Bitbucket)
3. Framework Preset: Other
4. Build Command: `flutter build web --release`
5. Output Directory: `build/web`
6. Click Deploy!

# Features:
# - Automatic HTTPS
# - Global CDN
# - Auto-deploys on git push
# - Free SSL certificates
# - Custom domains supported
