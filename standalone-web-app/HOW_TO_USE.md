# 🚀 How to Run the Recovery Journey App in Chrome

## ⚠️ IMPORTANT: Why GitHub Doesn't Work Directly

**GitHub displays HTML files as text/code, it does NOT run them as web pages.**

You cannot just click an HTML file on GitHub and have it work. You need to either:
1. Download it and open locally
2. Use GitHub Pages (if enabled)
3. Use the raw file URL

---

## ✅ Method 1: Download and Open Locally (Easiest)

### Step 1: Download the Files
1. Go to: https://github.com/Mifavourite/Peaceled-pulse/tree/main/standalone-web-app
2. Click the green **"Code"** button
3. Select **"Download ZIP"**
4. Extract the ZIP file

### Step 2: Open in Chrome
1. Navigate to the `standalone-web-app` folder
2. **Double-click `index.html`**
3. It will open in your default browser (Chrome)
4. **Done!** Start using the app immediately

---

## ✅ Method 2: Clone Repository (If You Have Git)

```bash
git clone https://github.com/Mifavourite/Peaceled-pulse.git
cd Peaceled-pulse/standalone-web-app
# Then open index.html in Chrome
```

---

## ✅ Method 3: Use GitHub Pages (After Setup)

### Setup GitHub Pages:
1. Go to your repository: https://github.com/Mifavourite/Peaceled-pulse
2. Click **Settings**
3. Scroll to **Pages** (left sidebar)
4. Under **Source**, select **"Deploy from a branch"**
5. Select branch: **main**
6. Select folder: **/standalone-web-app** (or root)
7. Click **Save**

### Access Your App:
After setup, your app will be available at:
```
https://mifavourite.github.io/Peaceled-pulse/standalone-web-app/
```

**Note:** This requires the files to be in the right location and GitHub Pages enabled.

---

## ✅ Method 4: Direct Raw File (Quick Test)

1. Go to: https://raw.githubusercontent.com/Mifavourite/Peaceled-pulse/main/standalone-web-app/index.html
2. **Right-click** → **Save As** → Save as `index.html`
3. Also save `styles.css` and `app.js` from the same folder
4. Open the saved `index.html` in Chrome

---

## 🎯 Recommended: Method 1 (Download ZIP)

**This is the easiest and works immediately:**

1. **Download**: https://github.com/Mifavourite/Peaceled-pulse/archive/refs/heads/main.zip
2. **Extract** the ZIP file
3. **Navigate** to `Peaceled-pulse-main/standalone-web-app/`
4. **Double-click** `index.html`
5. **Start using the app!**

---

## 🔧 Troubleshooting

### "Page doesn't load properly"
- Make sure all 3 files are in the same folder:
  - `index.html`
  - `styles.css`
  - `app.js`

### "Styles don't work"
- Check that `styles.css` is in the same folder as `index.html`
- Check browser console (F12) for errors

### "App doesn't function"
- Check that `app.js` is in the same folder
- Open browser console (F12) to see any errors
- Make sure JavaScript is enabled in your browser

### "I see code instead of app"
- You're viewing it on GitHub (which shows code)
- Download the file and open locally instead

---

## 💡 Quick Start Guide

1. **Download** the standalone-web-app folder
2. **Open** `index.html` in Chrome
3. **Click** "Create Account"
4. **Enter** username and password
5. **Start** logging victories and checking in!

That's it! No installation, no setup - just open and use! 🎉
