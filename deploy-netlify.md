# Netlify Deployment Guide

## Method 1: Drag and Drop (Easiest)

1. Go to https://app.netlify.com/drop
2. Drag your `build/web` folder onto the page
3. Your site is live instantly!
4. You get a random URL like: https://random-name-123.netlify.app
5. You can customize the domain in settings

## Method 2: CLI Deployment

# Install Netlify CLI
npm install -g netlify-cli

# Login to Netlify
netlify login

# Initialize your site
netlify init

# Deploy
netlify deploy --prod --dir=build/web

## Method 3: Continuous Deployment (Advanced)

1. Push your code to GitHub
2. Connect repository to Netlify
3. Set build command: `flutter build web --release`
4. Set publish directory: `build/web`
5. Auto-deploys on every push!

# Your app will be live at: https://your-site-name.netlify.app
