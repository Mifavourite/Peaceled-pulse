# Testing Guide - Security & Android APK

## 🔒 Security Checks

### 1. Run Dependency Audit

**Windows (PowerShell)**:
```powershell
cd secure_flutter_app
flutter pub audit
```

**Linux/Mac (Bash)**:
```bash
cd secure_flutter_app
flutter pub audit
```

**What it checks**:
- Known vulnerabilities in dependencies
- Outdated packages with security issues
- Recommendations for updates

---

### 2. Check for Hardcoded Secrets

**Automated Check**:
```powershell
# Windows
.\scripts\security_check.ps1

# Linux/Mac
bash scripts/security_check.sh
```

**Manual Check**:
- Search for: `password =`, `api_key =`, `secret =`
- Verify no credentials in code
- Check all `.dart` files in `lib/`

**Fixed Issues**:
- ✅ Database password now derived from device (not hardcoded)
- ✅ All secrets use FlutterSecureStorage
- ✅ No API keys or tokens in code

---

### 3. Verify Encryption is Working

**Create a test screen or use encryption test service**:

```dart
import 'package:secure_flutter_app/services/encryption_test_service.dart';

final testService = EncryptionTestService();
final results = await testService.testEncryption();

print('AES Encryption: ${results['aes_encryption']}');
print('Secure Storage: ${results['secure_storage']}');
print('Hashing: ${results['hashing']}');
```

**What to verify**:
- ✅ AES encryption/decryption works
- ✅ Secure storage read/write works
- ✅ SHA-256 hashing is consistent
- ✅ Database encryption (SQLCipher) is active

**Test Database Encryption**:
1. Create a test entry in database
2. Try to read database file directly (should be encrypted/unreadable)
3. Verify data is encrypted at rest

---

### 4. Test on Android Device

### Prerequisites

1. **Enable Developer Options**:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Developer options will appear

2. **Enable USB Debugging**:
   - Settings → Developer Options
   - Enable "USB Debugging"

3. **Connect Device**:
   ```bash
   adb devices
   ```
   Should show your device

### Run on Device

```bash
cd secure_flutter_app
flutter run
```

**What to test**:
- ✅ Login/Registration works
- ✅ Database encryption works
- ✅ Secure storage works
- ✅ Camera permissions work
- ✅ All screens function correctly
- ✅ Detection works
- ✅ Chat works offline
- ✅ Data persists after app restart

---

### 5. Build APK for Testing

### Build Release APK

**Windows (PowerShell)**:
```powershell
.\scripts\build_apk.ps1
```

**Linux/Mac (Bash)**:
```bash
bash scripts/build_apk.sh
```

**Manual Build**:
```bash
cd secure_flutter_app
flutter clean
flutter pub get
flutter build apk --release
```

### APK Location

```
build/app/outputs/flutter-apk/app-release.apk
```

### Install APK

**Via ADB**:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Via File Manager**:
1. Copy APK to device
2. Open file manager on device
3. Tap APK file
4. Allow installation from unknown sources if prompted
5. Install

---

## 🧪 Testing Checklist

### Security Tests

- [ ] Run `flutter pub audit` - no critical vulnerabilities
- [ ] Check for hardcoded secrets - none found
- [ ] Test encryption service - all tests pass
- [ ] Verify database encryption - data encrypted at rest
- [ ] Test secure storage - data stored securely
- [ ] Verify HTTPS enforcement - all network calls use HTTPS
- [ ] Check security headers - all headers present

### Functional Tests

- [ ] Login/Registration works
- [ ] Password hashing (bcrypt) works
- [ ] Database operations work
- [ ] Detection screen works
- [ ] Camera preview works
- [ ] Image detection works
- [ ] Values screen saves/loads
- [ ] Victory log works
- [ ] Chat works offline
- [ ] All navigation works

### Android-Specific Tests

- [ ] App installs successfully
- [ ] Permissions requested correctly
- [ ] Camera works
- [ ] Storage works
- [ ] App doesn't crash
- [ ] Performance is acceptable
- [ ] Battery usage is reasonable

---

## 🔍 Security Verification Steps

### 1. Database Encryption Verification

**Test**:
1. Create a user account
2. Add some data (values, victory logs)
3. Close app
4. Try to read database file directly:
   ```bash
   # On device (requires root or adb shell)
   cat /data/data/com.example.secure_flutter_app/databases/secure_app.db
   ```
5. Should see encrypted/unreadable data

**Expected**: Database file is encrypted and unreadable without password

### 2. Secure Storage Verification

**Test**:
1. Store sensitive data (session token, etc.)
2. Check if data is in secure storage:
   - Android: KeyStore
   - iOS: Keychain
3. Verify data persists after app restart

**Expected**: Data stored in platform secure storage

### 3. Password Hashing Verification

**Test**:
1. Register a new user
2. Check database - password should be bcrypt hash
3. Login should work with plain password
4. Database should NOT contain plain password

**Expected**: Only bcrypt hashes in database, never plain passwords

---

## 📱 Android Build Configuration

### Check `android/app/build.gradle`

Ensure:
- `minSdkVersion` is appropriate (recommended: 21+)
- `targetSdkVersion` is current
- ProGuard/R8 enabled for release builds

### Signing Configuration

For release builds, configure signing:
```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
}
```

---

## 🐛 Troubleshooting

### Flutter Not Found
- Add Flutter to PATH
- Or use full path: `C:\path\to\flutter\bin\flutter`

### ADB Not Found
- Install Android SDK Platform Tools
- Add to PATH

### Build Fails
- Run `flutter clean`
- Run `flutter pub get`
- Check for errors in `flutter doctor`

### APK Too Large
- Use `flutter build apk --split-per-abi` for smaller APKs
- Or `flutter build appbundle` for Play Store

---

## ✅ Success Criteria

All tests should pass:
- ✅ No security vulnerabilities in dependencies
- ✅ No hardcoded secrets
- ✅ Encryption working correctly
- ✅ App runs on Android device
- ✅ APK builds successfully
- ✅ All features work as expected

---

**Ready for testing!** 🚀
