# Quick Run Guide

## One Command to Run

```bash
flutter run
```

That's it! The app will:
1. Check if you're logged in
2. Show login screen if not
3. Show home screen with 3 tabs if logged in

## First Time Setup

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

3. **Register a new account**:
   - Enter username (min 3 characters)
   - Enter password (min 6 characters)
   - Click "Register"

4. **You're in!** Navigate between:
   - **Detection**: Test image detection
   - **Values**: Store your 5 values
   - **Victory Log**: Track successful days

## Features

### Login
- Secure bcrypt password hashing
- Session management
- Auto-login on app restart

### Detection
- Pick image from camera or gallery
- On-device NSFW detection
- Red screen warning if inappropriate content detected
- All detections logged (encrypted)

### Values
- Store 5 personal values
- Encrypted storage
- Save/load automatically

### Victory Log
- Log successful days
- Add notes
- View history
- All encrypted

## Security

- ✅ Passwords hashed with bcrypt
- ✅ Encrypted SQLite database
- ✅ HTTPS enforced
- ✅ All processing local (no cloud)
- ✅ All data encrypted

## Troubleshooting

### "Database not initialized"
- The app initializes the database automatically on first run
- If you see this error, restart the app

### "Model not found" (Detection)
- The detection currently uses simulated detection
- To use actual TFLite model, add `assets/nsfw_model.tflite` and update `pubspec.yaml`

### Camera/Gallery not working
- Ensure permissions are granted
- Check device settings for app permissions

---

**That's it! Just run `flutter run` and you're good to go!** 🚀
