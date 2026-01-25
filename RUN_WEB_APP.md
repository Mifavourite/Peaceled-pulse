# How to Run the Web App in Chrome

## ⚠️ Important: GitHub vs Running the App

**What you're seeing on GitHub**: That's just the README file - it's documentation, not the running app.

**To actually USE the app in Chrome**, you need to run it locally or deploy it.

## 🚀 Option 1: Run Locally (Easiest)

### Step 1: Make sure Flutter is installed
```bash
flutter --version
```

### Step 2: Install dependencies
```bash
flutter pub get
```

### Step 3: Run in Chrome
```bash
flutter run -d chrome
```

This will:
- Compile the Flutter web app
- Open Chrome automatically
- Show your interactive app (with clickable buttons, etc.)

## 🌐 Option 2: Build and Deploy to GitHub Pages

If you want the app to be accessible online (not just locally):

### Step 1: Build for web
```bash
flutter build web
```

### Step 2: Deploy to GitHub Pages
1. Go to your repository (e.g. https://github.com/Mifavourite/Peaceled-pulse)
2. Go to **Settings → Pages**
3. Under **Build and deployment**, set **Source** to **GitHub Actions**
4. Use the workflow in this repo (`.github/workflows/deploy.yml`). Ensure that workflow exists in the repo you’re deploying (e.g. copy it into Peaceled-pulse if you deploy from there)

**Important:** If you see 404s for `manifest.json`, `flutter_service_worker.js`, or `main.dart.js`, the site is not being built/deployed correctly. Fix by:
- Setting Pages source to **GitHub Actions** (not “Deploy from a branch”).
- Using the deploy workflow that runs `flutter build web --base-href "/Peaceled-pulse/"` and uploads the full `build/web` folder.
- Re-running the workflow (push a commit or “Run workflow” in the Actions tab) so a fresh build is deployed.

### Step 3: After deployment
Your app will be available at:
`https://mifavourite.github.io/Peaceled-pulse/`

## 🔍 Troubleshooting

### "Flutter not found"
- Install Flutter: https://docs.flutter.dev/get-started/install
- Add Flutter to your PATH

### "Nothing clickable" in browser
- Make sure you ran `flutter run -d chrome` (not just viewing GitHub)
- Check browser console for errors (F12)
- Try `flutter clean` then `flutter pub get` again

### App doesn't load
- Make sure you're running it locally with `flutter run -d chrome`
- GitHub README is NOT the app - it's just documentation

## ✅ Quick Test

Run this to verify everything works:
```bash
flutter doctor
flutter pub get
flutter run -d chrome
```

You should see the login screen with clickable buttons!
