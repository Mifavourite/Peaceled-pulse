#!/bin/bash
# Build Release APK Script for Linux/macOS
# Optimized for mobile: battery, memory, and performance

set -e

BUILD_TYPE=${1:-release}
CLEAN=${2:-false}
SIGN=${3:-false}

echo "🚀 Building Release APK..."
echo ""

# Change to project directory
cd "$(dirname "$0")/.."

# Step 1: Clean (optional)
if [ "$CLEAN" = "true" ]; then
    echo "🧹 Cleaning build files..."
    flutter clean
    rm -rf build
    echo "✓ Clean complete"
    echo ""
fi

# Step 2: Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Failed to get dependencies"
    exit 1
fi
echo "✓ Dependencies installed"
echo ""

# Step 3: Build APK
echo "🔨 Building $BUILD_TYPE APK..."

BUILD_CMD="flutter build apk --release"
BUILD_CMD="$BUILD_CMD --split-per-abi"  # Build separate APKs per ABI (smaller size)
BUILD_CMD="$BUILD_CMD --target-platform android-arm,android-arm64,android-x64"

if [ "$SIGN" = "true" ]; then
    echo "   (Including signing - ensure keystore is configured)"
fi

eval $BUILD_CMD

if [ $? -ne 0 ]; then
    echo "❌ APK build failed"
    exit 1
fi

echo "✓ APK build successful!"
echo ""

# Step 4: Locate APK files
echo "📱 APK Location:"
find build/app/outputs/flutter-apk -name "*.apk" -type f | while read apk; do
    size=$(du -h "$apk" | cut -f1)
    echo "   $apk"
    echo "   Size: $size"
done

echo ""
echo "✅ Release APK build complete!"
echo ""
echo "Installation:"
echo "   adb install build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "App Bundle (recommended for Play Store):"
echo "   flutter build appbundle --release"
