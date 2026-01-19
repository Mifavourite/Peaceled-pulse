#!/bin/bash
# Build Google Play App Bundle
# This script builds the release App Bundle (.aab) for Google Play Store submission

set -e

echo "🚀 Building Google Play App Bundle..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter and add it to PATH."
    exit 1
fi

# Get Flutter version
echo "📱 Flutter version:"
flutter --version

# Clean build
echo ""
echo "🧹 Cleaning build..."
flutter clean

# Get dependencies
echo ""
echo "📦 Getting dependencies..."
flutter pub get

# Build App Bundle
echo ""
echo "🔨 Building App Bundle (.aab)..."
echo "   This may take a few minutes..."
flutter build appbundle --release

# Check if build succeeded
if [ $? -eq 0 ]; then
    BUNDLE_PATH="build/app/outputs/bundle/release/app-release.aab"
    
    if [ -f "$BUNDLE_PATH" ]; then
        FILE_SIZE=$(du -h "$BUNDLE_PATH" | cut -f1)
        
        echo ""
        echo "✅ Build successful!"
        echo ""
        echo "📦 App Bundle:"
        echo "   Path: $(pwd)/$BUNDLE_PATH"
        echo "   Size: $FILE_SIZE"
        
        echo ""
        echo "📋 Next Steps:"
        echo "   1. Go to Google Play Console"
        echo "   2. Create new app (if not already created)"
        echo "   3. Go to Release > Production"
        echo "   4. Create new release"
        echo "   5. Upload: $(pwd)/$BUNDLE_PATH"
        echo "   6. Add release notes"
        echo "   7. Submit for review"
        
        echo ""
        echo "📚 Documentation:"
        echo "   See GOOGLE_PLAY_SUBMISSION.md for complete guide"
    else
        echo ""
        echo "⚠️  Build completed but App Bundle not found at expected path."
        echo "   Expected: $BUNDLE_PATH"
    fi
else
    echo ""
    echo "❌ Build failed. Check errors above."
    exit 1
fi

echo ""
echo "✨ Done!"
