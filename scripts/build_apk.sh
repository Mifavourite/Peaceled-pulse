#!/bin/bash

# Build APK Script for Testing
# Run: bash scripts/build_apk.sh

echo "📱 Building APK for Testing..."
echo "=============================="
echo ""

# Clean previous builds
echo "1. Cleaning previous builds..."
flutter clean
echo ""

# Get dependencies
echo "2. Getting dependencies..."
flutter pub get
echo ""

# Run security checks
echo "3. Running security checks..."
flutter pub audit
echo ""

# Build APK
echo "4. Building release APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ APK built successfully!"
    echo ""
    echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "To install on device:"
    echo "  adb install build/app/outputs/flutter-apk/app-release.apk"
else
    echo ""
    echo "❌ APK build failed!"
    exit 1
fi
