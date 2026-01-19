# Build Google Play App Bundle
# This script builds the release App Bundle (.aab) for Google Play Store submission

Write-Host "🚀 Building Google Play App Bundle..." -ForegroundColor Green

# Check if Flutter is installed
$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterPath) {
    Write-Host "❌ Flutter not found. Please install Flutter and add it to PATH." -ForegroundColor Red
    exit 1
}

# Get Flutter version
Write-Host "📱 Flutter version:" -ForegroundColor Cyan
flutter --version

# Clean build
Write-Host "`n🧹 Cleaning build..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "`n📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Check for errors
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get dependencies." -ForegroundColor Red
    exit 1
}

# Build App Bundle
Write-Host "`n🔨 Building App Bundle (.aab)..." -ForegroundColor Yellow
Write-Host "   This may take a few minutes..." -ForegroundColor Gray

flutter build appbundle --release

# Check if build succeeded
if ($LASTEXITCODE -eq 0) {
    $bundlePath = "build\app\outputs\bundle\release\app-release.aab"
    
    if (Test-Path $bundlePath) {
        $fileInfo = Get-Item $bundlePath
        $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
        
        Write-Host "`n✅ Build successful!" -ForegroundColor Green
        Write-Host "`n📦 App Bundle:" -ForegroundColor Cyan
        Write-Host "   Path: $($fileInfo.FullName)" -ForegroundColor White
        Write-Host "   Size: $fileSizeMB MB" -ForegroundColor White
        
        Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
        Write-Host "   1. Go to Google Play Console" -ForegroundColor White
        Write-Host "   2. Create new app (if not already created)" -ForegroundColor White
        Write-Host "   3. Go to Release > Production" -ForegroundColor White
        Write-Host "   4. Create new release" -ForegroundColor White
        Write-Host "   5. Upload: $($fileInfo.FullName)" -ForegroundColor White
        Write-Host "   6. Add release notes" -ForegroundColor White
        Write-Host "   7. Submit for review" -ForegroundColor White
        
        Write-Host "`n📚 Documentation:" -ForegroundColor Yellow
        Write-Host "   See GOOGLE_PLAY_SUBMISSION.md for complete guide" -ForegroundColor White
    } else {
        Write-Host "`n⚠️  Build completed but App Bundle not found at expected path." -ForegroundColor Yellow
        Write-Host "   Expected: $bundlePath" -ForegroundColor Gray
    }
} else {
    Write-Host "`n❌ Build failed. Check errors above." -ForegroundColor Red
    exit 1
}

Write-Host "`n✨ Done!" -ForegroundColor Green
