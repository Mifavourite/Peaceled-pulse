# Beta APK Build Instructions

## Quick Build for Beta Testing

### Prerequisites
- Flutter SDK installed
- Android SDK configured
- Device connected or emulator running

### Step 1: Update Version

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Change to 1.0.0-beta+1
```

### Step 2: Clean Build

**Windows:**
```powershell
cd secure_flutter_app
flutter clean
flutter pub get
```

**Linux/macOS:**
```bash
cd secure_flutter_app
flutter clean
flutter pub get
```

### Step 3: Build Release APK

**Windows:**
```powershell
.\scripts\build_release_apk.ps1 -Clean
```

**Linux/macOS:**
```bash
chmod +x scripts/build_release_apk.sh
./scripts/build_release_apk.sh release true
```

**Manual Build:**
```bash
flutter build apk --release --split-per-abi
```

### Step 4: Locate APK Files

APK files will be in:
```
build/app/outputs/flutter-apk/
```

Files:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM) **RECOMMENDED**
- `app-x86_64-release.apk` (x86_64)

### Step 5: Test Installation

```bash
# Install on connected device
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Or install multiple versions
adb install-multiple build/app/outputs/flutter-apk/*-release.apk
```

### Step 6: Verify Beta Features

- [ ] Feedback button appears in home screen
- [ ] Feedback can be submitted
- [ ] Feedback can be exported
- [ ] All core features work

## Beta APK Distribution

### Option 1: Direct Download
1. Upload APK to file sharing service
2. Share download link with beta testers
3. Provide installation instructions

### Option 2: Email Distribution
1. Attach APK to email
2. Include `BETA_TESTING_GUIDE.md`
3. Send to beta testers

### Option 3: Internal Testing (Play Store)
1. Build App Bundle: `flutter build appbundle --release`
2. Upload to Play Console
3. Add beta testers
4. Distribute via Play Store

## Beta Checklist

Before distributing:
- [ ] Version number updated
- [ ] APK builds successfully
- [ ] APK installs on test devices
- [ ] Feedback feature works
- [ ] Core features functional
- [ ] Beta guide included
- [ ] Test accounts created (if needed)

## Post-Beta Build

After beta testing:
1. Review feedback
2. Fix critical bugs
3. Implement improvements
4. Build release version
5. Update version number

## Troubleshooting

### Build Fails
```bash
flutter doctor -v  # Check Flutter setup
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
```

### Installation Fails
- Check device compatibility (Android 5.0+)
- Ensure "Unknown Sources" enabled
- Check storage space
- Try uninstalling previous version

### APK Too Large
- Already optimized with split-per-abi
- Consider removing unused assets
- Enable ProGuard/R8 in build.gradle

## Beta Version Notes

**Version**: 1.0.0-beta+1
**Build Date**: [Date]
**Features**:
- Core detection functionality
- Enhanced overlay screen
- Lock timer (1-5 minutes)
- Recovery flow
- Beta feedback system
- Scripture images rotation (if assets included)
- Shofar sound (if asset included)

**Known Issues**:
- [List any known issues]

**Tested On**:
- [Device 1]
- [Device 2]
- [Device 3]

## Next Steps

1. Distribute APK to 5 beta testers
2. Share `BETA_TESTING_GUIDE.md`
3. Collect feedback for [duration]
4. Review and prioritize feedback
5. Build next version with fixes
