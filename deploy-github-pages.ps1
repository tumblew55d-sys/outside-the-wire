# GitHub Pages Deployment Script
# Run this from the project root directory

# Build the Flutter web app
flutter build web --release --base-href "/your-repo-name/"

# Navigate to build/web
cd build/web

# Initialize git if needed
git init

# Add all files
git add .

# Commit
git commit -m "Deploy Flutter web app"

# Add your GitHub repository as remote
git remote add origin https://github.com/yourusername/your-repo-name.git

# Push to gh-pages branch
git push -u origin main:gh-pages --force

# Go back to project root
cd ../..

Write-Host "Deployed to GitHub Pages!"
Write-Host "Enable GitHub Pages in repository settings (Settings > Pages > Source: gh-pages branch)"
