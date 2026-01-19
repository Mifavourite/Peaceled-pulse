# Quick Build Guide - Release APK

## Quick Start

### Windows (PowerShell)
```powershell
cd secure_flutter_app
.\scripts\build_release_apk.ps1
```

### Linux/macOS
```bash
cd secure_flutter_app
chmod +x scripts/build_release_apk.sh
./scripts/build_release_apk.sh
```

## What Gets Built

The script builds **optimized release APKs**:
- **Split per ABI**: Separate APKs for arm, arm64, x64 (smaller sizes)
- **Release mode**: Fully optimized, minified code
- **Location**: `build/app/outputs/flutter-apk/`

## Install on Device

### Via ADB
```bash
adb install build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
```

Or for 64-bit:
```bash
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

### Via File Transfer
1. Copy APK to device
2. Enable "Install from Unknown Sources" in Android settings
3. Open APK file on device
4. Install

## Build Options

### Clean Build
```powershell
# Windows
.\scripts\build_release_apk.ps1 -Clean
```

```bash
# Linux/macOS
./scripts/build_release_apk.sh release true
```

### App Bundle (Play Store)
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## Troubleshooting

### Build Fails
1. Run `flutter clean`
2. Run `flutter pub get`
3. Check Flutter doctor: `flutter doctor -v`
4. Ensure Android SDK is installed

### APK Too Large
- Script already splits per ABI
- Consider removing unused assets
- Enable ProGuard/R8 in `android/app/build.gradle`

### Installation Fails
- Check device compatibility (Android 5.0+)
- Ensure enough storage space
- Check for conflicting app installations

## File Sizes (Expected)

After optimization with split APKs:
- **arm64-v8a**: ~25-35 MB
- **armeabi-v7a**: ~23-32 MB
- **x86_64**: ~28-38 MB

## Next Steps

1. **Test on real device** before distribution
2. **Configure signing** for production release
3. **Upload to Play Store** using App Bundle format
4. **Monitor performance** on various devices

For detailed information, see `MOBILE_OPTIMIZATIONS.md`
