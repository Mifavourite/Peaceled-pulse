# Web Support for Recovery Journey App

## ✅ Web Support Enabled

Your Flutter app can now run in Chrome and other browsers on your laptop!

## 🚀 How to Run on Web

### Option 1: Run in Chrome (Development)
```bash
flutter run -d chrome
```

### Option 2: Build for Web
```bash
flutter build web
```
Then serve the `build/web` directory using any web server.

## ⚠️ Platform Differences

### ✅ What Works on Web:
- Login and authentication
- User registration
- Basic app navigation
- Most UI screens
- Shared preferences storage

### ⚠️ Limited/Not Available on Web:
- **Camera access**: Web browsers have limited camera API support. The detection screen may not work fully.
- **Biometric authentication**: `local_auth` doesn't work on web - password login only
- **SQLite database**: Uses SharedPreferences fallback on web (less feature-rich)
- **Some security features**: VPN detection, hardware keys, etc. are mobile-only

### 📝 Notes:
- The app will automatically detect if it's running on web and use appropriate storage
- Orientation lock is disabled on web (browsers handle this)
- Some mobile-specific features gracefully degrade on web

## 🔧 Technical Details

- **Database**: On web, uses `SharedPreferences` instead of SQLite
- **Storage**: Web uses browser's localStorage via SharedPreferences
- **Platform detection**: Uses `kIsWeb` from Flutter foundation

## 🎯 Next Steps

To fully support web, consider:
1. Adding web-compatible camera/image picker
2. Implementing full web database support (IndexedDB)
3. Adding web-specific UI adjustments for larger screens
